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
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.tablet.view.ActiveRecordView;
	import collaboRhythm.tablet.view.TabletFullViewContainer;
	import collaboRhythm.tablet.view.TabletViewBase;
	import collaboRhythm.tablet.view.TabletWidgetViewContainer;

	import flash.events.Event;

	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;

	import spark.components.ViewNavigator;

	import spark.transitions.SlideViewTransition;

	public class TabletApplicationController extends ApplicationControllerBase
	{
		private var _tabletApplication:CollaboRhythmTabletApplication;
		private var _tabletAppControllersMediator:TabletAppControllersMediator;
		private var _fullContainer:IVisualElementContainer;

		[Embed("/resources/settings.xml", mimeType="application/octet-stream")]
		private var _applicationSettingsEmbeddedFile:Class;

		public function TabletApplicationController(collaboRhythmTabletApplication:CollaboRhythmTabletApplication)
		{
			_tabletApplication = collaboRhythmTabletApplication;
			_connectivityView = collaboRhythmTabletApplication.connectivityView;
			_aboutApplicationView = collaboRhythmTabletApplication.aboutApplicationView;
			initializeConnectivityView();
		}

		public override function main():void
		{
			super.main();

			_settings.modality = Settings.MODALITY_TABLET;

			initCollaborationController();

			_tabletApplication.navigator.addEventListener(Event.COMPLETE, viewNavigator_transitionCompleteHandler);
			_tabletApplication.navigator.addEventListener("viewChangeComplete",
														  viewNavigator_transitionCompleteHandler);
			_tabletApplication.navigator.addEventListener(Event.ADDED, viewNavigator_addedHandler);

			initializeActiveView();

			createSession();
		}

		private function viewNavigator_transitionCompleteHandler(event:Event):void
		{
			if (!(_tabletApplication.navigator.activeView is TabletWidgetViewContainer))
				_tabletAppControllersMediator.destroyWidgetViews();
		}

		private function viewNavigator_addedHandler(event:Event):void
		{
			var view:TabletViewBase = event.target as TabletViewBase;
			if (view)
			{
				initializeView(view);
			}
		}

		private function initializeView(view:TabletViewBase):void
		{
			view.tabletApplicationController = this;
			view.activeRecordAccount = _activeRecordAccount;
		}

		public function initializeActiveView():void
		{
			var view:TabletViewBase = _tabletApplication.navigator.activeView as TabletViewBase;
			if (view)
			{
				initializeView(view);
			}
		}

		public override function openRecordAccount(recordAccount:Account):void
		{
			super.openRecordAccount(recordAccount);
			initializeActiveView();
			activeRecordView.init(this, recordAccount);
			activeRecordView.visible = true;
		}

		private function get activeRecordView():ActiveRecordView
		{
			return _tabletApplication.activeRecordView;
		}

		// the apps are not actually loaded immediately when a record is opened
		// only after the active record view has been made visible are they loaded, this makes the UI more responsive
		public function openRecordAndShowWidgets(recordAccount:Account):void
		{
			_tabletAppControllersMediator = new TabletAppControllersMediator(activeRecordView.widgetContainers,
																			 _fullContainer, _settings,
																			 _componentContainer,
																			 _collaborationController.collaborationModel.collaborationLobbyNetConnectionService,
			this);
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
			activeRecordView.visible = false;
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

		protected override function restoreFocus():void
		{
			if (activeRecordView)
				activeRecordView.setFocus();
		}

		public function pushFullView(workstationAppController:WorkstationAppControllerBase):void
		{
			if (workstationAppController.fullView)
			{
				backgroundProcessModel.updateProcess("fullViewUpdate", "Updating...", true);
				workstationAppController.fullView.addEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler, false, 0, true);
			}
			_tabletApplication.navigator.pushView(TabletFullViewContainer, workstationAppController, new SlideViewTransition());
		}

		private function fullView_updateCompleteHandler(event:FlexEvent):void
		{
			event.target.removeEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler);
			backgroundProcessModel.updateProcess("fullViewUpdate", "Updating...", false);
		}

		public function useWidgetContainers():void
		{
			_tabletAppControllersMediator.widgetContainers = activeRecordView.widgetContainers;
			_tabletAppControllersMediator.showWidgetsInNewContainers();
			activeRecordView.visible = true;
		}

		public function get navigator():ViewNavigator
		{
			return _tabletApplication ? _tabletApplication.navigator : null;
		}
	}
}
