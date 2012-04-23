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
	import collaboRhythm.shared.collaboration.controller.CollaborationEvent;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.view.CollaborationVideoView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.view.tablet.TabletViewBase;
	import collaboRhythm.tablet.view.SelectRecordView;
	import collaboRhythm.tablet.view.TabletFullViewContainer;
	import collaboRhythm.tablet.view.TabletHomeView;

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
		private var _openingRecordAccount:Boolean = false;

		public function TabletApplicationController(collaboRhythmTabletApplication:CollaboRhythmTabletApplication)
		{
			_tabletApplication = collaboRhythmTabletApplication;
			_connectivityView = collaboRhythmTabletApplication.connectivityView;
			_aboutApplicationView = collaboRhythmTabletApplication.aboutApplicationView;
			initializeConnectivityView();
		}

		override public function main():void
		{
			super.main();

			settings.modality = Settings.MODALITY_TABLET;

			initCollaborationController();
			_collaborationController.viewNavigator = navigator;
			_collaborationController.collaborationModel.collaborationLobbyNetConnectionService.addEventListener(CollaborationEvent.SYNCHRONIZE,
								synchronizeHandler);

			navigator.addEventListener(Event.COMPLETE, viewNavigator_transitionCompleteHandler);
			navigator.addEventListener("viewChangeComplete",
					viewNavigator_transitionCompleteHandler);
			navigator.addEventListener(Event.ADDED, viewNavigator_addedHandler);

			initializeActiveView();

			createSession();
		}

		private function synchronizeHandler(event:CollaborationEvent):void
		{
			if (event.method == "showCollaborationVideoView")
			{
				showCollaborationVideoView("remote");
			}
		}

		private function viewNavigator_transitionCompleteHandler(event:Event):void
		{
			if (tabletHomeView)
			{
				if (_openingRecordAccount)
				{
					showWidgets(activeRecordAccount);
					_openingRecordAccount = false;
				}
			}
			else if (_tabletAppControllersMediator)
			{
				_tabletAppControllersMediator.destroyWidgetViews();
			}

			if (_reloadWithFullView)
			{
				appControllersMediator.showFullView(_reloadWithFullView);
				_reloadWithFullView = null;
			}
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
			view.activeAccount = activeAccount;
			view.activeRecordAccount = activeRecordAccount;
		}

		public function initializeActiveView():void
		{
			var view:TabletViewBase = _tabletApplication.navigator.activeView as TabletViewBase;
			if (view)
			{
				initializeView(view);
			}
		}

		override public function showSelectRecordView():void
		{
			_tabletApplication.navigator.pushView(SelectRecordView);
		}

		override public function openRecordAccount(recordAccount:Account):void
		{
			if (activeRecordAccount)
			{
				closeRecordAccount(activeRecordAccount);
			}
			super.openRecordAccount(recordAccount);
			if (tabletHomeView)
			{
				initializeActiveView();
				tabletHomeView.init();
				showWidgets(recordAccount);
			}
			else
			{
				_openingRecordAccount = true;
				navigator.popToFirstView();
			}
		}

		override public function sendCollaborationInvitation():void
		{
			super.sendCollaborationInvitation();
			navigator.popToFirstView();
			navigator.pushView(CollaborationVideoView);
		}

		override protected function collaborationInvitationReceived_eventHandler(event:CollaborationEvent):void
		{
			_collaborationController.receiveCollaborationInvitation(event.subjectAccountId, event.sourceAccountId,
					event.sourcePeerId, event.passWord);
			navigator.popToFirstView();
			navigator.pushView(CollaborationVideoView);
		}

		override protected function collaborationInvitationAccepted_eventHandler(event:CollaborationEvent):void
		{
			_collaborationController.receiveCollaborationInvitationAccepted(event.subjectAccountId,
					event.sourceAccountId,
					event.sourcePeerId, event.passWord);
		}

		override protected function collaborationInvitationRejected_eventHandler(event:CollaborationEvent):void
		{
			_collaborationController.receiveCollaborationInvitationRejected(event.subjectAccountId,
					event.sourceAccountId,
					event.sourcePeerId, event.passWord);
		}

		override protected function collaborationInvitationCancelled_eventHandler(event:CollaborationEvent):void
		{
			_collaborationController.receiveCollaborationInvitationCancelled(event.subjectAccountId,
					event.sourceAccountId,
					event.sourcePeerId, event.passWord);
		}

		override protected function collaborationEnded_eventHandler(event:CollaborationEvent):void
		{
			_collaborationController.receiveCollaborationEnded(event.subjectAccountId, event.sourceAccountId, event.sourcePeerId, event.passWord);
		}

		private function get tabletHomeView():TabletHomeView
		{
			return _tabletApplication.tabletHomeView;
		}

		private function get selectRecordView():SelectRecordView
		{
			return _tabletApplication.selectRecordView;
		}

		// the apps are not actually loaded immediately when a record is opened
		// only after the active record view has been made visible are they loaded, this makes the UI more responsive
		public function showWidgets(recordAccount:Account):void
		{
			if (_tabletAppControllersMediator == null)
			{
				_tabletAppControllersMediator = new TabletAppControllersMediator(tabletHomeView.widgetContainers,
						_fullContainer, settings,
						_componentContainer,
						_collaborationController.collaborationModel.collaborationLobbyNetConnectionService as CollaborationLobbyNetConnectionService,
						this,
						_navigationProxy);
			}
			_tabletAppControllersMediator.createAndStartApps(activeAccount, recordAccount);
		}

		public override function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public override function get applicationSettingsEmbeddedFile():Class
		{
			return _applicationSettingsEmbeddedFile;
		}

		public override function get appControllersMediator():AppControllersMediatorBase
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
			activeRecordAccount = null;
			if (tabletHomeView)
				tabletHomeView.visible = false;
		}

		protected override function changeDemoDate():void
		{
			reloadData();

			if (activeRecordAccount && activeRecordAccount.primaryRecord &&
					activeRecordAccount.primaryRecord.demographics)
				activeRecordAccount.primaryRecord.demographics.dispatchAgeChangeEvent();
		}

		protected override function restoreFocus():void
		{
			if (tabletHomeView)
				tabletHomeView.setFocus();
		}

		public function pushFullView(appController:AppControllerBase):void
		{
			if (appController.fullView)
			{
				backgroundProcessModel.updateProcess("fullViewUpdate", "Updating...", true);
				appController.fullView.addEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler,
						false, 0, true);
			}
			_tabletApplication.navigator.pushView(TabletFullViewContainer, appController, new SlideViewTransition());
		}

		private function fullView_updateCompleteHandler(event:FlexEvent):void
		{
			event.target.removeEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler);
			backgroundProcessModel.updateProcess("fullViewUpdate", "Updating...", false);
		}

		public function useWidgetContainers():void
		{
			if (_tabletAppControllersMediator)
			{
				_tabletAppControllersMediator.widgetContainers = tabletHomeView.widgetContainers;
				_tabletAppControllersMediator.showWidgetsInNewContainers();
			}
		}

		override public function get navigator():ViewNavigator
		{
			return _tabletApplication ? _tabletApplication.navigator : null;
		}

		public function get tabletAppControllersMediator():TabletAppControllersMediator
		{
			return _tabletAppControllersMediator;
		}

		public function showCollaborationVideoView(source:String):void
		{
			if (source == "local" && _collaborationController.collaborationModel.collaborationState ==
								CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationController.collaborationModel.collaborationLobbyNetConnectionService.sendMessage(CollaborationLobbyNetConnectionService.SYNCHRONIZE,
						"showCollaborationVideoView");
			}
			navigator.pushView(CollaborationVideoView);
		}
	}
}
