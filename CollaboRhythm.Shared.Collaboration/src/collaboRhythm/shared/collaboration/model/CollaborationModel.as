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
package collaboRhythm.shared.collaboration.model
{
	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.settings.Settings;

	/**
	 *
	 * @author jom
	 *
	 * Keeps track of all of the remoteUsers actively collaborating with the localUser.  It also keeps a reference to the videoOutput, as this is part of any collaboration.
	 * Considering that only userNames are sent over the netConnection with the FMS, the retrieveCollaboratingRemoteUser function allows a collaboratingRemoteUser to be resolved from its userName.
	 *
	 */
	[Bindable]
	public class CollaborationModel implements ICollaborationModel
	{
		public static const COLLABORATION_ACTIVE:String = "CollaborationActive";
		public static const COLLABORATION_INACTIVE:String = "CollaborationInactive";
		public static const COLLABORATION_OUT_OF_SYNC:String = "CollaborationOutOfSync";
		public static const COLLABORATION_INVITATION_SENT:String = "CollaborationInvitationSent";
		public static const COLLABORATION_INVITATION_RECEIVED:String = "CollaborationInvitationReceived";
		public static const COLLABORATION_INVITATION_REJECTED:String = "CollaborationInvitationRejected";

		private var _collaborationState:String;

		private var _activeAccount:Account;
		private var _activeRecordAccount:Account;

		private var _audioVideoOutput:AudioVideoOutput;
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;

		private var _subjectAccount:Account;
		private var _peerAccount:Account;

		private var _passWord:String;
		private var _recordVideo:Boolean = false;

		public function CollaborationModel(settings:Settings, activeAccount:Account)
		{
			_activeAccount = activeAccount;

			_audioVideoOutput = new AudioVideoOutput();
			_collaborationLobbyNetConnectionService = new CollaborationLobbyNetConnectionService(_activeAccount,
					settings.rtmpBaseURI, this);

			collaborationState = COLLABORATION_INACTIVE;
		}

		public function receiveCollaborationMessage(messageType:String, subjectAccountId:String, sourceAccountId:String,
													sourcePeerId:String, passWord:String):void
		{
			if (messageType == CollaborationLobbyNetConnectionService.INVITE)
			{
				receiveCollaborationInvitation(subjectAccountId, sourceAccountId, sourcePeerId, passWord);
			}
			else if (messageType == CollaborationLobbyNetConnectionService.OUT_OF_SYNC)
			{
				receiveCollaborationOutOfSync(subjectAccountId, sourceAccountId, sourcePeerId, passWord);
			}
			else if (this.passWord == passWord)
			{
				switch (messageType)
				{
					case CollaborationLobbyNetConnectionService.ACCEPT:
						receiveCollaborationInvitationAccepted(subjectAccountId, sourceAccountId, sourcePeerId,
								passWord);
						break;
					case CollaborationLobbyNetConnectionService.REJECT:
						receiveCollaborationInvitationRejected(subjectAccountId, sourceAccountId, sourcePeerId,
								passWord);
						break;
					case CollaborationLobbyNetConnectionService.CANCEL:
						receiveCollaborationInvitationCancelled(subjectAccountId, sourceAccountId, sourcePeerId,
								passWord);
						break;
					case CollaborationLobbyNetConnectionService.END:
						receiveCollaborationEnded(subjectAccountId, sourceAccountId, sourcePeerId, passWord);
						break;
				}
			}
			else
			{
				//TODO: Logging potential security issue
			}
		}

		public function sendCollaborationInvitation(subjectAccount:Account, targetAccount:Account):void
		{
			this.subjectAccount = subjectAccount;
			peerAccount = targetAccount;
			passWord = String(Math.round(Math.random() * 10000));
			collaborationState = CollaborationModel.COLLABORATION_INVITATION_SENT;

			collaborationLobbyNetConnectionService.sendCollaborationMessage(CollaborationLobbyNetConnectionService.INVITE);
		}

		private function receiveCollaborationInvitation(subjectAccountId:String, sourceAccountId:String,
														sourcePeerId:String, passWord:String):void
		{
			if (_activeAccount.accountId == subjectAccountId)
			{
				subjectAccount = _activeAccount;
			}
			else
			{
				subjectAccount = _activeAccount.allSharingAccounts[subjectAccountId];
			}
			peerAccount = _activeAccount.allSharingAccounts[sourceAccountId];
			peerAccount.peerId = sourcePeerId;
			this.passWord = passWord;
			collaborationState = CollaborationModel.COLLABORATION_INVITATION_RECEIVED;
		}

		public function acceptCollaborationInvitation():void
		{
			collaborationLobbyNetConnectionService.createNetStreamConnections(peerAccount.peerId,
					peerAccount.accountId);
			collaborationState = CollaborationModel.COLLABORATION_ACTIVE;

			collaborationLobbyNetConnectionService.sendCollaborationMessage(CollaborationLobbyNetConnectionService.ACCEPT);
		}

		private function receiveCollaborationInvitationAccepted(subjectAccountId:String, sourceAccountId:String,
																sourcePeerId:String, passWord:String):void
		{
			peerAccount.peerId = sourcePeerId;
			collaborationLobbyNetConnectionService.createNetStreamConnections(peerAccount.peerId,
					peerAccount.accountId);
			collaborationState = CollaborationModel.COLLABORATION_ACTIVE;
		}

		public function rejectCollaborationInvitation():void
		{
			collaborationLobbyNetConnectionService.sendCollaborationMessage(CollaborationLobbyNetConnectionService.REJECT);

			resetCollaborationModel();
		}

		private function receiveCollaborationInvitationRejected(subjectAccountId:String, sourceAccountId:String,
																sourcePeerId:String, passWord:String):void
		{
			resetCollaborationModel();
		}

		public function cancelCollaborationInvitation():void
		{
			collaborationLobbyNetConnectionService.sendCollaborationMessage(CollaborationLobbyNetConnectionService.CANCEL);

			resetCollaborationModel();
		}

		private function receiveCollaborationInvitationCancelled(subjectAccountId:String, sourceAccountId:String,
																 sourcePeerId:String, passWord:String):void
		{
			resetCollaborationModel();
		}

		private function endActiveCollaboration():void
		{
			collaborationLobbyNetConnectionService.sendCollaborationMessage(CollaborationLobbyNetConnectionService.END);

			resetCollaborationModel();
		}

		private function receiveCollaborationEnded(subjectAccountId:String, sourceAccountId:String, sourcePeerId:String,
												   passWord:String):void
		{
			resetCollaborationModel();
		}

		public function sendCollaborationOutOfSync():void
		{
			if (collaborationState == COLLABORATION_INACTIVE || collaborationState == COLLABORATION_OUT_OF_SYNC)
			{
				for each (var recordShareAccount:Account in _activeAccount.recordShareAccounts)
				{
					peerAccount = recordShareAccount;
					collaborationLobbyNetConnectionService.sendCollaborationMessage(CollaborationLobbyNetConnectionService.OUT_OF_SYNC);
				}
			}
		}

		private function receiveCollaborationOutOfSync(subjectAccountId:String, sourceAccountId:String,
													   sourcePeerId:String, passWord:String):void
		{
			if (activeRecordAccount && sourceAccountId == activeRecordAccount.accountId)
			{
				collaborationState = COLLABORATION_OUT_OF_SYNC;
			}
		}

		private function resetCollaborationModel():void
		{
			collaborationLobbyNetConnectionService.closeNetStreamConnections();
			subjectAccount = null;
			peerAccount = null;
			passWord = null;
			collaborationState = COLLABORATION_INACTIVE;
		}

		public function endCollaboration():void
		{
			if (collaborationState == COLLABORATION_ACTIVE)
			{
				endActiveCollaboration();
			}
			else if (collaborationState == COLLABORATION_INVITATION_SENT)
			{
				cancelCollaborationInvitation();
			}
			else if (collaborationState == COLLABORATION_INVITATION_RECEIVED)
			{
				rejectCollaborationInvitation();
			}
			else
			{
				resetCollaborationModel();
			}
		}

		public function prepareToExit():void
		{
			endCollaboration();

			_collaborationLobbyNetConnectionService.exitCollaborationLobby();
		}

		public function get collaborationState():String
		{
			return _collaborationState;
		}

		public function set collaborationState(value:String):void
		{
			_collaborationState = value;
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function get activeRecordAccount():Account
		{
			return _activeRecordAccount;
		}

		public function set activeRecordAccount(value:Account):void
		{
			_activeRecordAccount = value;
		}

		public function get collaborationLobbyNetConnectionService():CollaborationLobbyNetConnectionService
		{
			return _collaborationLobbyNetConnectionService;
		}

		public function set collaborationLobbyNetConnectionService(value:CollaborationLobbyNetConnectionService):void
		{
			_collaborationLobbyNetConnectionService = value;
		}

		public function get subjectAccount():Account
		{
			return _subjectAccount;
		}

		public function set subjectAccount(value:Account):void
		{
			_subjectAccount = value;
		}

		public function get peerAccount():Account
		{
			return _peerAccount;
		}

		public function set peerAccount(value:Account):void
		{
			_peerAccount = value;
		}

		public function get passWord():String
		{
			return _passWord;
		}

		public function set passWord(value:String):void
		{
			_passWord = value;
		}

		public function get recordVideo():Boolean
		{
			return _recordVideo;
		}

		public function set recordVideo(value:Boolean):void
		{
			_recordVideo = value;
		}
	}
}