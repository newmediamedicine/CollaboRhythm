/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.tablet.controller
{

	import collaboRhythm.core.controller.ApplicationControllerBase;
	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.tablet.view.ActiveRecordView;
	import collaboRhythm.tablet.view.ConnectivityEvent;
	import collaboRhythm.tablet.view.ConnectivityView;
	import collaboRhythm.tablet.view.TabletApplicationView;

	import flash.desktop.NativeApplication;
	import flash.events.Event;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;

	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	public class TabletApplicationController extends ApplicationControllerBase
	{
		private var _tabletAppControllersMediator:TabletAppControllersMediator;
		private var _fullContainer:IVisualElementContainer;
		private var _activeRecordView:ActiveRecordView;
		private var _connectivityView:ConnectivityView;

		[Embed("/resources/settings.xml", mimeType="application/octet-stream")]
		private var _applicationSettingsEmbeddedFile:Class;

		public function TabletApplicationController(tabletApplicationView:TabletApplicationView)
		{
			_activeRecordView = tabletApplicationView.activeRecordView;
			_connectivityView = tabletApplicationView.connectivityView;
			_connectivityView.addEventListener(ConnectivityEvent.IGNORE, connectivityView_ignoreHandler);
			_connectivityView.addEventListener(ConnectivityEvent.QUIT, connectivityView_quitHandler);
			_connectivityView.addEventListener(ConnectivityEvent.RETRY, connectivityView_retryHandler);
		}

		private function connectivityView_retryHandler(event:ConnectivityEvent):void
		{
			if (_healthRecordServiceFacade.currentRecord)
			{
				_healthRecordServiceFacade.resetFailedOperations();
				_healthRecordServiceFacade.saveAllChanges(_healthRecordServiceFacade.currentRecord);
			}
			if (_collaborationLobbyNetConnectionService.hasConnectionFailed)
			{
				_collaborationLobbyNetConnectionService.enterCollaborationLobby();
			}
		}

		private function connectivityView_quitHandler(event:ConnectivityEvent):void
		{
			_logger.info("Application exit by user (via ConnectivityView Quit button)");
			NativeApplication.nativeApplication.exit();
		}

		private function connectivityView_ignoreHandler(event:ConnectivityEvent):void
		{
			_healthRecordServiceFacade.resetFailedOperations();
		}

		public override function main():void
		{
			super.main();

			_settings.modality = Settings.MODALITY_TABLET;

			initCollaborationController();

			createSession();
		}


		override protected function serviceIsLoading_changeHandler(isLoading:Boolean):void
		{
			super.serviceIsLoading_changeHandler(isLoading);
			updateConnectivityView();
		}

		override protected function serviceHasFailedSaveOperations_changeHandler(hasFailedSaveOperations:Boolean):void
		{
			super.serviceHasFailedSaveOperations_changeHandler(hasFailedSaveOperations);
			updateConnectivityView();
		}

		override protected function serviceIsSaving_changeHandler(isSaving:Boolean):void
		{
			super.serviceIsSaving_changeHandler(isSaving);
			updateConnectivityView();
		}

		override protected function collaborationLobbyIsConnecting_changeHandler(isConnecting:Boolean):void
		{
			super.collaborationLobbyIsConnecting_changeHandler(isConnecting);
			updateConnectivityView();
		}

		override protected function collaborationLobbyHasConnectionFailed_changeHandler(hasConnectionFailed:Boolean):void
		{
			super.collaborationLobbyHasConnectionFailed_changeHandler(hasConnectionFailed);
			updateConnectivityView();
		}

		private function updateConnectivityView():void
		{
			// TODO: perhaps we should have different states for saving vs loading

			var connectivityState:String;
			if ((_healthRecordServiceFacade && _healthRecordServiceFacade.isLoading) || (_collaborationLobbyNetConnectionService && _collaborationLobbyNetConnectionService.isConnecting))
				connectivityState = "connectInProgress";
			else if (_healthRecordServiceFacade && _healthRecordServiceFacade.isSaving)
				connectivityState = "connectInProgress";
			else if ((_healthRecordServiceFacade && _healthRecordServiceFacade.hasFailedSaveOperations) || (_collaborationLobbyNetConnectionService && _collaborationLobbyNetConnectionService.hasConnectionFailed))
				connectivityState = "persistFailed";

			_connectivityView.setCurrentState(connectivityState);
			_connectivityView.visible = (_healthRecordServiceFacade && _healthRecordServiceFacade.isLoading) || (_healthRecordServiceFacade && _healthRecordServiceFacade.isSaving) || (_healthRecordServiceFacade && _healthRecordServiceFacade.hasFailedSaveOperations) || (_collaborationLobbyNetConnectionService && _collaborationLobbyNetConnectionService.isConnecting) || (_collaborationLobbyNetConnectionService && _collaborationLobbyNetConnectionService.hasConnectionFailed);
		}

		public override function openRecordAccount(recordAccount:Account):void
		{
			super.openRecordAccount(recordAccount);
			_activeRecordView.init(this, recordAccount);
			_activeRecordView.visible = true;
		}

		// the apps are not actually loaded immediately when a record is opened
		// only after the active record view has been made visible are they loaded, this makes the UI more responsive
		public function activeRecordView_showHandler(recordAccount:Account):void
		{
			_fullContainer = _activeRecordView.fullViewsGroup;
			_tabletAppControllersMediator = new TabletAppControllersMediator(_activeRecordView.widgetContainers,
																			 _fullContainer, _settings,
																			 _componentContainer,
																			 _collaborationController.collaborationModel.collaborationLobbyNetConnectionService);
			_tabletAppControllersMediator.createAndStartApps(_activeAccount, recordAccount);
			loadDocuments(recordAccount);
		}

		public override function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public override function get applicationSettingsEmbeddedFile():Class
		{
			return _applicationSettingsEmbeddedFile;
		}

		protected override function get appControllersMediator():AppControllersMediatorBase
		{
			return _tabletAppControllersMediator;
		}

		public override function get currentFullView():String
		{
			return _tabletAppControllersMediator.currentFullView;
		}

		// when a record is closed, all of the apps need to be closed and the documents cleared from the record
		public override function closeRecordAccount(recordAccount:Account):void
		{
			_tabletAppControllersMediator.closeApps();
			if (recordAccount)
				recordAccount.primaryRecord.clearDocuments();
			_activeRecordAccount = null;
			_activeRecordView.visible = false;
		}

		public function useDemoPreset(demoPresetIndex:int):void
		{
			if (_settings.demoDatePresets && _settings.demoDatePresets.length > demoPresetIndex)
				targetDate = _settings.demoDatePresets[demoPresetIndex];
		}

		protected override function changeDemoDate():void
		{
			reloadData();

			if (_activeRecordAccount && _activeRecordAccount.primaryRecord && _activeRecordAccount.primaryRecord.demographics)
				_activeRecordAccount.primaryRecord.demographics.dispatchAgeChangeEvent();
		}

		public function exitApplication(exitMethod:String):void
		{
			_logger.info("Application exit by user (via " + exitMethod + ")");
			NativeApplication.nativeApplication.exit();
		}
	}
}
