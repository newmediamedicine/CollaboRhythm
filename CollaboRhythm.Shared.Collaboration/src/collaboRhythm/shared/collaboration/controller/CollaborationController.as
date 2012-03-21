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
package collaboRhythm.shared.collaboration.controller
{
	import collaboRhythm.shared.controller.ICollaborationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionEvent;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.model.ICollaborationModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.VideoMessage;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.collaboration.view.CollaborationVideoView;
	import collaboRhythm.shared.collaboration.view.CollaborationView;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	import spark.components.ViewNavigator;

	/**
	 * Coordinates interaction between the CollaborationModel and the CollaborationView and its children the RecordVideoView and CollaborationRoomView.
	 * Currently, it is possible for the user to accept or cancel (this includes reject) collaborations from the CollaboratingRemoteUserViews in the CollaborationBarView.
	 * The CollaborationBarView listens for the events from the CollaboratingRemoteUserViews and calls functions in this class, which update the collaborationModel and dispatch events for interested observers.
	 * Currently, the CollaborationMediator listens for events from this class.  It also calls functions in this class when collaboration functions are called via the RemoteUserNetConnectionService.
	 *
	 * @author jom
	 */
	public class CollaborationController extends EventDispatcher implements ICollaborationController
	{
		private var _activeAccount:Account;
		private var _settings:Settings;
		private var _collaborationModel:CollaborationModel;
		private var _collaborationView:CollaborationView;
		private var _logger:ILogger;
		private var _currentDateSource:ICurrentDateSource;
		private var _viewNavigator:ViewNavigator;

		public function CollaborationController(activeAccount:Account, collaborationView:CollaborationView,
												settings:Settings)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_activeAccount = activeAccount;
			_settings = settings;
			_collaborationModel = new CollaborationModel(settings, _activeAccount);
			_collaborationModel.addEventListener(CollaborationLobbyNetConnectionEvent.SYNCHRONIZE, synchronizeHandler);
			_collaborationView = collaborationView;
//				_collaborationRoomView.addEventListener(CollaborationEvent.LOCAL_USER_JOINED_COLLABORATION_ROOM_ANIMATION_COMPLETE, localUserJoinedCollaborationRoomAnimationCompleteHandler);
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		private function synchronizeHandler(event:CollaborationLobbyNetConnectionEvent):void
		{
			dispatchEvent(new CollaborationLobbyNetConnectionEvent(CollaborationLobbyNetConnectionEvent.SYNCHRONIZE));
		}

		public function setActiveRecordAccount(activeRecordAccount:Account):void
		{
			_collaborationModel.activeRecordAccount = activeRecordAccount;
		}

		public function showRecordVideoView():void
		{
			_collaborationModel.recordVideo = true;
		}

		public function hideRecordVideoView():void
		{
			_collaborationModel.recordVideo = false;
		}

		public function uploadVideoMessage():void
		{
			var record:Record = _collaborationModel.activeRecordAccount.primaryRecord;
			var videoMessage:VideoMessage = record.videoMessagesModel.createVideoMessage(activeAccount,
					_currentDateSource);
			record.addDocument(videoMessage, true);
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function get collaborationModel():ICollaborationModel
		{
			return _collaborationModel;
		}

		public function set collaborationModel(value:ICollaborationModel):void
		{
			_collaborationModel = value as CollaborationModel;
		}

		public function sendCollaborationInvitation(subjectAccount:Account, targetAccount:Account):void
		{
			_collaborationModel.subjectAccount = subjectAccount;
			_collaborationModel.peerAccount = targetAccount;
			_collaborationModel.passWord = String(Math.round(Math.random() * 10000));
			_collaborationModel.collaborationLobbyNetConnectionService.sendMessage(CollaborationLobbyNetConnectionService.INVITE,
					_collaborationModel.subjectAccount.accountId, _activeAccount.accountId, _activeAccount.peerId,
					_collaborationModel.peerAccount.accountId, null, _collaborationModel.passWord);
			_collaborationModel.collaborationState = CollaborationModel.INVITATION_SENT;
		}

		public function receiveCollaborationInvitation(subjectAccountId:String, sourceAccountId:String,
													   sourcePeerId:String, passWord:String):void
		{
			if (_activeAccount.accountId == subjectAccountId)
			{
				_collaborationModel.subjectAccount = _activeAccount;
			}
			else
			{
				_collaborationModel.subjectAccount = _activeAccount.allSharingAccounts[subjectAccountId];
			}
			_collaborationModel.peerAccount = _activeAccount.allSharingAccounts[sourceAccountId];
			_collaborationModel.peerAccount.peerId = sourcePeerId;
			_collaborationModel.passWord = passWord;
			_collaborationModel.collaborationState = CollaborationModel.INVITATION_RECEIVED;
		}

		public function sendCollaborationInvitationAccepted():void
		{
			_collaborationModel.collaborationLobbyNetConnectionService.sendMessage(CollaborationLobbyNetConnectionService.ACCEPT,
					_collaborationModel.subjectAccount.accountId, _activeAccount.accountId, _activeAccount.peerId,
					_collaborationModel.peerAccount.accountId, _collaborationModel.peerAccount.peerId,
					_collaborationModel.passWord);
			_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_ACTIVE;
			_collaborationModel.collaborationLobbyNetConnectionService.createCommunicationConnection();
		}

		public function receiveCollaborationInvitationAccepted(subjectAccountId:String, sourceAccountId:String,
															   sourcePeerId:String, passWord:String):void
		{
			if (_collaborationModel.passWord == passWord)
			{
				_collaborationModel.peerAccount.peerId = sourcePeerId;
				_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_ACTIVE;
				_collaborationModel.collaborationLobbyNetConnectionService.createCommunicationConnection();
			}
			else
			{
				//TODO: Logging potential security issue
			}
		}

		public function sendCollaborationInvitationRejected():void
		{
			popCollaborationVideoView();
			_collaborationModel.collaborationLobbyNetConnectionService.sendMessage(CollaborationLobbyNetConnectionService.REJECT,
					_collaborationModel.subjectAccount.accountId, _activeAccount.accountId, _activeAccount.peerId,
					_collaborationModel.peerAccount.accountId, _collaborationModel.peerAccount.peerId,
					_collaborationModel.passWord);
			_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_INACTIVE;
		}

		public function receiveCollaborationInvitationRejected(subjectAccountId:String, sourceAccountId:String,
															   sourcePeerId:String, passWord:String):void
		{
			if (_collaborationModel.passWord == passWord)
			{
				_collaborationModel.collaborationState = CollaborationModel.INVITATION_REJECTED;
				var invitationRejectedTimer:Timer = new Timer(1000, 1);
				invitationRejectedTimer.addEventListener(TimerEvent.TIMER_COMPLETE,
						invitationRejectedTimer_completeEventHandler);
				invitationRejectedTimer.start();
			}
			else
			{
				//TODO: Logging potential security issue
			}
		}

		private function invitationRejectedTimer_completeEventHandler(event:TimerEvent):void
		{
			popCollaborationVideoView();
			_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_INACTIVE;
		}

		public function sendCollaborationInvitationCancelled():void
		{
			popCollaborationVideoView();
			_collaborationModel.collaborationLobbyNetConnectionService.sendMessage(CollaborationLobbyNetConnectionService.CANCEL,
					_collaborationModel.subjectAccount.accountId, _activeAccount.accountId, _activeAccount.peerId,
					_collaborationModel.peerAccount.accountId, _collaborationModel.peerAccount.peerId,
					_collaborationModel.passWord);
			_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_INACTIVE;
		}

		public function receiveCollaborationInvitationCancelled(subjectAccountId:String, sourceAccountId:String,
																sourcePeerId:String, passWord:String):void
		{
			if (_collaborationModel.passWord == passWord)
			{
				popCollaborationVideoView();
				_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_INACTIVE;
			}
			else
			{
				//TODO: Logging potential security issue
			}
		}

		public function sendCollaborationEnd():void
		{
			popCollaborationVideoView();
			_collaborationModel.collaborationLobbyNetConnectionService.sendMessage(CollaborationLobbyNetConnectionService.END,
					_collaborationModel.subjectAccount.accountId, _activeAccount.accountId, _activeAccount.peerId,
					_collaborationModel.peerAccount.accountId, _collaborationModel.peerAccount.peerId,
					_collaborationModel.passWord);
			_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_INACTIVE;
		}

		public function receiveCollaborationEnded(subjectAccountId:String, sourceAccountId:String, sourcePeerId:String,
												  passWord:String):void
		{
			if (_collaborationModel.passWord == passWord)
			{
				popCollaborationVideoView();
				_collaborationModel.collaborationState = CollaborationModel.COLLABORATION_INACTIVE;
			}
			else
			{
				//TODO: Logging potential security issue
			}
		}

		private function popCollaborationVideoView():void
		{
			var collaborationVideoView:CollaborationVideoView = _viewNavigator.activeView as CollaborationVideoView;
			if (collaborationVideoView)
			{
				_viewNavigator.popView();
			}
		}

		private function localUserJoinedCollaborationRoomAnimationCompleteHandler(event:CollaborationEvent):void
		{
			_collaborationModel.collaborationRoomNetConnectionService.connectActiveAccountVideoStream();
		}

		public function joinCollaborationRoom():void
		{
			_collaborationModel.collaborationRoomNetConnectionService.joinCollaborationRoom();
		}

		public function closeCollaborationRoom():void
		{
			_collaborationModel.closeCollaborationRoom();
		}

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator;
		}

		public function set viewNavigator(value:ViewNavigator):void
		{
			_viewNavigator = value;
		}
	}
}