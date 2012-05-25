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
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionEvent;
	import collaboRhythm.shared.collaboration.model.CollaborationMessageEvent;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.view.CollaborationView;
	import collaboRhythm.shared.controller.ICollaborationController;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.VideoMessage;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;

	import flash.events.EventDispatcher;
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
	[Bindable]
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
			_collaborationView = collaborationView;

			_collaborationModel.collaborationLobbyNetConnectionService.addEventListener(CollaborationMessageEvent.MESSAGE_RECEIVED, collaborationMessageReceived_eventHandler);

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		private function collaborationMessageReceived_eventHandler(event:CollaborationMessageEvent):void
		{
			_collaborationModel.receiveCollaborationMessage(event.messageType, event.subjectAccountId, event.sourceAccountId, event.sourcePeerId, event.passWord);
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

		public function get collaborationModel():CollaborationModel
		{
			return _collaborationModel;
		}

		public function set collaborationModel(value:CollaborationModel):void
		{
			_collaborationModel = value;
		}

		public function sendCollaborationInvitation(subjectAccount:Account, targetAccount:Account):void
		{
			_collaborationModel.sendCollaborationInvitation(subjectAccount, targetAccount);
		}

		public function acceptCollaborationInvitation():void
		{
			_collaborationModel.acceptCollaborationInvitation();
		}

		public function rejectCollaborationInvitation():void
		{
			_collaborationModel.rejectCollaborationInvitation();
		}

		public function cancelCollaborationInvitation():void
		{
			_collaborationModel.cancelCollaborationInvitation();
		}

		public function endCollaboration():void
		{
			_collaborationModel.endCollaboration();
		}

		public function prepareToExit():void
		{
			_collaborationModel.prepareToExit();
		}

		private function localUserJoinedCollaborationRoomAnimationCompleteHandler(event:CollaborationMessageEvent):void
		{
//			_collaborationModel.collaborationRoomNetConnectionService.connectActiveAccountVideoStream();
		}

		public function joinCollaborationRoom():void
		{
//			_collaborationModel.collaborationRoomNetConnectionService.joinCollaborationRoom();
		}

		public function closeCollaborationRoom():void
		{
//			_collaborationModel.closeCollaborationRoom();
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