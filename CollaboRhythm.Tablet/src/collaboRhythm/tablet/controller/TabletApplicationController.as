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
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.collaboration.view.CollaborationInvitationPopUp;
	import collaboRhythm.shared.collaboration.view.CollaborationInvitationPopUpEvent;
	import collaboRhythm.shared.collaboration.view.CollaborationVideoView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.view.tablet.TabletViewBase;
	import collaboRhythm.tablet.model.ViewNavigatorExtended;
	import collaboRhythm.tablet.model.ViewNavigatorExtendedEvent;
	import collaboRhythm.tablet.view.SelectRecordView;
	import collaboRhythm.tablet.view.TabletFullViewContainer;
	import collaboRhythm.tablet.view.TabletHomeView;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import mx.binding.utils.BindingUtils;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;

	public class TabletApplicationController extends ApplicationControllerBase
	{
		private static const SESSION_IDLE_TIMEOUT:int = 60;
		private static const ACCOUNT_ID_SUFFIX:String = "@records.media.mit.edu";

		private var _tabletApplication:CollaboRhythmTabletApplication;
		private var _tabletAppControllersMediator:TabletAppControllersMediator;
		private var _fullContainer:IVisualElementContainer;

		[Embed("/resources/settings.xml", mimeType="application/octet-stream")]
		private var _applicationSettingsEmbeddedFile:Class;
		private var _openingRecordAccount:Boolean = false;

		private var _collaborationInvitationPopUp:CollaborationInvitationPopUp;
		private var _synchronizationService:SynchronizationService;

		private var _sessionIdleTimer:Timer;
		private var _userDefinedValue:String;

		public function TabletApplicationController(collaboRhythmTabletApplication:CollaboRhythmTabletApplication)
		{
			super(collaboRhythmTabletApplication);

			_tabletApplication = collaboRhythmTabletApplication;
			_connectivityView = collaboRhythmTabletApplication.connectivityView;
			_busyView = collaboRhythmTabletApplication.busyView;
			_aboutApplicationView = collaboRhythmTabletApplication.aboutApplicationView;
			initializeConnectivityView();
		}

		override public function main():void
		{
			super.main();

			settings.modality = Settings.MODALITY_TABLET;

			initCollaborationController();
			_collaborationController.viewNavigator = navigator;
			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);

			BindingUtils.bindSetter(collaborationState_changeHandler, _collaborationController.collaborationModel,
					"collaborationState");

			_tabletApplication.addEventListener(MouseEvent.MOUSE_DOWN, application_mouseDownHandler);

			navigator.addEventListener(Event.COMPLETE, viewNavigator_transitionCompleteHandler);
			navigator.addEventListener("viewChangeComplete",
					viewNavigator_transitionCompleteHandler);
			navigator.addEventListener(ViewNavigatorExtendedEvent.VIEW_POPPED, viewNavigator_viewPopped);
			navigator.addEventListener(Event.ADDED, viewNavigator_addedHandler);

			initializeActiveView();

			createSession();

			setGoogleAnalyticsUserDefinedValue();
			createGoogleAnalyticsSessionIdleTimer();
		}

		private function collaborationState_changeHandler(collaborationState:String):void
		{
			if (collaborationState == CollaborationModel.COLLABORATION_INVITATION_SENT ||
					collaborationState == CollaborationModel.COLLABORATION_INVITATION_RECEIVED)
			{
				_collaborationInvitationPopUp = new CollaborationInvitationPopUp();
				_collaborationInvitationPopUp.init(_collaborationController, activeRecordAccount);
				_collaborationInvitationPopUp.addEventListener(CollaborationInvitationPopUpEvent.ACCEPT,
						collaborationInvitationPopUp_acceptHandler);
				_collaborationInvitationPopUp.addEventListener(CollaborationInvitationPopUpEvent.REJECT,
						collaborationInvitationPopUp_rejectHandler);
				_collaborationInvitationPopUp.addEventListener(CollaborationInvitationPopUpEvent.CANCEL,
						collaborationInvitationPopUp_cancelHandler);
				_collaborationInvitationPopUp.open(navigator.activeView as TabletViewBase, true);
				PopUpManager.centerPopUp(_collaborationInvitationPopUp);
			}
			else
			{
				if (_collaborationInvitationPopUp && _collaborationInvitationPopUp.isOpen)
				{
					_collaborationInvitationPopUp.close(false);
				}

				if (collaborationState == CollaborationModel.COLLABORATION_ACTIVE)
				{
					navigator.popToFirstView();
					navigator.pushView(CollaborationVideoView);
				}

				if (collaborationState == CollaborationModel.COLLABORATION_INACTIVE &&
						navigator.activeView as CollaborationVideoView)
				{
					navigator.popView();
				}
			}

			trackActiveView();
		}

		private function collaborationInvitationPopUp_acceptHandler(event:CollaborationInvitationPopUpEvent):void
		{
			_collaborationController.acceptCollaborationInvitation();
		}

		private function collaborationInvitationPopUp_rejectHandler(event:CollaborationInvitationPopUpEvent):void
		{
			_collaborationController.rejectCollaborationInvitation();
		}

		private function collaborationInvitationPopUp_cancelHandler(event:CollaborationInvitationPopUpEvent):void
		{
			_collaborationController.cancelCollaborationInvitation();
		}

		private function popCollaborationVideoView():void
		{
			var collaborationVideoView:CollaborationVideoView = navigator.activeView as CollaborationVideoView;
			if (collaborationVideoView)
			{
				navigator.popView();
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

			trackActiveView();
		}

		private function viewNavigator_addedHandler(event:Event):void
		{
			var view:TabletViewBase = event.target as TabletViewBase;
			if (view)
			{
				initializeView(view);
			}
		}

		public function initializeActiveView():void
		{
			var view:TabletViewBase = _tabletApplication.navigator.activeView as TabletViewBase;
			if (view)
			{
				initializeView(view);
			}
		}

		private function initializeView(view:TabletViewBase):void
		{
			view.activeAccount = activeAccount;
			view.activeRecordAccount = activeRecordAccount;
			view.tabletApplicationController = this;
		}

		private function setGoogleAnalyticsUserDefinedValue():void
		{
			if (settings.useGoogleAnalytics)
			{
				var mode:String = settings.mode;
				var accountId:String = settings.username;

				_analyticsTracker.setVar("mode='" + mode + "'&accountId='" + accountId + "'");
			}
		}

		private function createGoogleAnalyticsSessionIdleTimer():void
		{
			if (settings.useGoogleAnalytics)
			{
				_sessionIdleTimer = new Timer(SESSION_IDLE_TIMEOUT * 1000, 1); //milliseconds
				_sessionIdleTimer.addEventListener(TimerEvent.TIMER_COMPLETE,
						sessionIdleTimer_TimerCompleteEventHandler);
				_sessionIdleTimer.start();
			}
		}

		public function sessionIdleTimer_TimerCompleteEventHandler(event:TimerEvent):void
		{
			if (settings.useGoogleAnalytics)
			{
				_sessionIdleTimer.reset();
				trackActiveView("idle");
				_analyticsTracker.resetSession();
			}
		}

		private function application_mouseDownHandler(event:MouseEvent):void
		{
			if (settings.useGoogleAnalytics)
			{
				if (_sessionIdleTimer.running)
				{
					_sessionIdleTimer.reset();
					_sessionIdleTimer.start();
				}
				else
				{
					_sessionIdleTimer.start();
					trackActiveView();
				}

				if (collaborationLobbyNetConnectionServiceProxy.collaborationModel.collaborationState ==
						CollaborationModel.COLLABORATION_ACTIVE)
				{
					_analyticsTracker.trackEvent("activity", "mouseDown", _userDefinedValue);
				}
			}
		}

		override protected function activateTracking():void
		{
			if (settings.useGoogleAnalytics)
			{
				_sessionIdleTimer.start();
				trackActiveView();
			}
		}

		override protected function deactivateTracking():void
		{
			if (settings.useGoogleAnalytics)
			{
				_sessionIdleTimer.reset();
				trackActiveView("deactivated");
				_analyticsTracker.resetSession();
			}
		}

		override protected function exitTracking():void
		{
			if (settings.useGoogleAnalytics)
			{
				trackActiveView("exited");
				_analyticsTracker.resetSession();
			}
		}

		private function trackActiveView(applicationState:String = null):void
		{
			if (settings.useGoogleAnalytics)
			{
				var recordAccountId:String;
				if (settings.mode == Settings.MODE_CLINICIAN)
				{
					if (activeRecordAccount && activeRecordAccount.accountId)
						recordAccountId = activeRecordAccount.accountId;
				}
				else
				{
					recordAccountId = settings.username + ACCOUNT_ID_SUFFIX;
				}

				var collaborationState:String = collaborationLobbyNetConnectionServiceProxy.collaborationModel.collaborationState;
				var peerId:String;
				if (collaborationLobbyNetConnectionServiceProxy.collaborationModel.peerAccount)
				{
					peerId = collaborationLobbyNetConnectionServiceProxy.collaborationModel.peerAccount.accountId;
				}

				var pageName:String;
				if (navigator.activeView as TabletFullViewContainer)
				{
					pageName = navigator.activeView.title;
				}
				else
				{
					pageName = navigator.activeView.className;
				}

				if (!applicationState)
				{
					applicationState = "activated";
				}

				var completePageName:String = "/applicationState=" + applicationState + "/recordAccountId=" + recordAccountId + "/collaborationState=" + collaborationState;
				if (peerId)
				{
					completePageName = completePageName + "/peerId=" + peerId;
				}
				completePageName = completePageName + "/pageName=" + pageName;

				_analyticsTracker.trackPageview(completePageName);
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
				_collaborationController.endCollaboration();
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

			trackActiveView();
		}

		override public function sendCollaborationInvitation():void
		{
			super.sendCollaborationInvitation();
		}

		override public function navigateHome():void
		{
			if (_synchronizationService.synchronize("navigateHome"))
			{
				return;
			}

			navigator.popToFirstView()
		}

		override public function synchronizeBack():void
		{
			if (_synchronizationService.synchronize("synchronizeBack", null, false))
			{
				return;
			}

			(navigator as ViewNavigatorExtended).popViewRemote();
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
				var appControllerConstructorParams:AppControllerConstructorParams = new AppControllerConstructorParams();
				appControllerConstructorParams.collaborationLobbyNetConnectionServiceProxy = _collaborationLobbyNetConnectionServiceProxy;
				appControllerConstructorParams.navigationProxy = _navigationProxy;
				_tabletAppControllersMediator = new TabletAppControllersMediator(tabletHomeView.widgetContainers,
						_fullContainer, _componentContainer, settings, appControllerConstructorParams, this);
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

		public function showCollaborationVideoView():void
		{
			if (_synchronizationService.synchronize("showCollaborationVideoView"))
			{
				return;
			}

			navigator.pushView(CollaborationVideoView);
		}

		public function endCollaboration():void
		{
			_collaborationController.endCollaboration();
		}

		override protected function prepareToExit():void
		{
			_collaborationController.prepareToExit();
		}

		public function setCollaborationLobbyConnectionStatus():void
		{
			if (activeRecordAccount.collaborationLobbyConnectionStatus == Account.COLLABORATION_LOBBY_AVAILABLE)
			{
				activeRecordAccount.collaborationLobbyConnectionStatus = Account.COLLABORATION_LOBBY_AWAY;
				_collaborationController.collaborationModel.collaborationLobbyNetConnectionService.updateCollaborationLobbyConnectionStatus(Account.COLLABORATION_LOBBY_AWAY);
			}
			else if (activeRecordAccount.collaborationLobbyConnectionStatus == Account.COLLABORATION_LOBBY_AWAY)
			{
				activeRecordAccount.collaborationLobbyConnectionStatus = Account.COLLABORATION_LOBBY_AVAILABLE;
				_collaborationController.collaborationModel.collaborationLobbyNetConnectionService.updateCollaborationLobbyConnectionStatus(Account.COLLABORATION_LOBBY_AVAILABLE);
			}
		}

		private function viewNavigator_viewPopped(event:ViewNavigatorExtendedEvent):void
		{
			synchronizeBack();
		}
	}
}
