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
	import collaboRhythm.core.controller.ApplicationExitUtil;
	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.InteractionLogUtil;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.tablet.view.ActiveRecordView;
	import collaboRhythm.tablet.view.TabletApplicationView;

	import flash.desktop.NativeApplication;

	import mx.core.IVisualElementContainer;

	public class TabletApplicationController extends ApplicationControllerBase
	{
		private var _tabletAppControllersMediator:TabletAppControllersMediator;
		private var _fullContainer:IVisualElementContainer;
		private var _activeRecordView:ActiveRecordView;

		[Embed("/resources/settings.xml", mimeType="application/octet-stream")]
		private var _applicationSettingsEmbeddedFile:Class;

		public function TabletApplicationController(tabletApplicationView:TabletApplicationView)
		{
			_activeRecordView = tabletApplicationView.activeRecordView;
			_connectivityView = tabletApplicationView.connectivityView;
			initializeConnectivityView();
		}

		public override function main():void
		{
			super.main();

			_settings.modality = Settings.MODALITY_TABLET;

			initCollaborationController();

			createSession();
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
			super.closeRecordAccount(recordAccount);
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
			InteractionLogUtil.log(_logger, "Application exit", exitMethod);
			ApplicationExitUtil.exit();
		}
	}
}
