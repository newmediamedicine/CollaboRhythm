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
package collaboRhythm.shared.model
{
	import castle.flexbridge.kernel.IKernel;
	
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import collaboRhythm.shared.model.settings.Settings;

	import flash.events.NetStatusEvent;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * 
	 * @author jom
	 * 
	 * Keeps track of all of the remoteUsers actively collaborating with the localUser.  It also keeps a reference to the videoOutput, as this is part of any collaboration.
	 * Considering that only userNames are sent over the netConnection with the FMS, the retrieveCollaboratingRemoteUser function allows a collaboratingRemoteUser to be resolved from its userName.
	 * 
	 */
	[Bindable]
	public class CollaborationModel
	{
		public static const COLLABORATION_INACTIVE:String = "CollaborationInactive";
		public static const INVITATION_SENT:String = "InvitationSent";
		public static const INVITATION_RECEIVED:String = "InvitationReceived";
		public static const COLLABORATION_ACTIVE:String = "CollaborationActive";
		public static const INVITATION_REJECTED:String = "InvitationRejected";
		
		private var _collaborationState:String = COLLABORATION_INACTIVE;

		private var _active:Boolean = false;
        private var _activeAccount:Account;
        private var _activeRecordAccount:Account;

		private var _subjectAccount:Account;
		private var _peerAccount:Account;
		private var _creatingAccount:Account;
		private var _invitedAccounts:Vector.<Account> = new Vector.<Account>();
		private var _sourceAccount:Account;

		private var _controllingAccount:Account;
		private var _roomID:String;
		private var _passWord:String;
		private var _audioVideoOutput:AudioVideoOutput;
		private var _collaborationRoomAccounts:ArrayCollection;
		private var _collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService;
		private var _collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService;
		private var _recordVideo:Boolean = false;

		public function CollaborationModel(settings:Settings, activeAccount:Account)
		{
			_activeAccount = activeAccount;
			_collaborationRoomAccounts = new ArrayCollection();
			
			_collaborationLobbyNetConnectionService = new CollaborationLobbyNetConnectionService(_activeAccount,
					settings.rtmpBaseURI, this);
			_collaborationRoomNetConnectionService = new CollaborationRoomNetConnectionService(_activeAccount,
					settings.rtmpBaseURI, this);
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function get roomID():String
		{
			return _roomID;
		}
		
		public function set roomID(value:String):void
		{
			_roomID = value;
		}
		
		public function get passWord():String
		{
			return _passWord;
		}
		
		public function set passWord(value:String):void
		{
			_passWord = value;
		}
		
		public function get collaborationLobbyNetConnectionService():CollaborationLobbyNetConnectionService
		{
			return _collaborationLobbyNetConnectionService;
		}
		
		public function get collaborationRoomNetConnectionService():CollaborationRoomNetConnectionService
		{
			return _collaborationRoomNetConnectionService;
		}
		
		public function get recordVideo():Boolean
		{
			return _recordVideo;
		}
		
		public function set recordVideo(value:Boolean):void
		{
			_recordVideo = value;
		}
		
		public function get collaborationRoomAccounts():ArrayCollection
		{
			return _collaborationRoomAccounts;
		}
		
		public function get audioVideoOutput():AudioVideoOutput
		{
			if (!_audioVideoOutput)
			{
				_audioVideoOutput = new AudioVideoOutput();
			}
			return _audioVideoOutput;
		}

        public function set audioVideoOutput(value:AudioVideoOutput):void
        {
            _audioVideoOutput = value;
        }
		
		public function addInvitedUser(invitedAccount:Account):void
		{
			if (_invitedAccounts.indexOf(invitedAccount) == -1)
			{
				_invitedAccounts.push(invitedAccount);
			}
			if (_collaborationRoomAccounts.getItemIndex(invitedAccount) == -1)
			{
				_collaborationRoomAccounts.addItem(invitedAccount);
			}
		}
		
		public function closeCollaborationRoom():void
		{
			while (_collaborationRoomAccounts.length > 0)
			{	
//				var collaborationRoomUser:User = User(_collaborationRoomAccounts.getItemAt(_collaborationRoomAccounts.length - 1));
//				_collaborationRoomNetConnectionService.sharingAccountExitedCollaborationRoom(collaborationRoomUser.accountId);
//				_collaborationRoomAccounts.removeItemAt(_collaborationRoomAccounts.length - 1);
			}
			_collaborationRoomNetConnectionService.exitCollaborationRoom();
			_roomID = "";
			_passWord = "";
//			localUser.collaborationColor = "0x000000";
		}

        public function set collaborationLobbyNetConnectionService(value:CollaborationLobbyNetConnectionService):void
        {
            _collaborationLobbyNetConnectionService = value;
        }

        public function get activeRecordAccount():Account
        {
            return _activeRecordAccount;
        }

        public function set activeRecordAccount(value:Account):void
        {
            _activeRecordAccount = value;
        }

		public function get creatingAccount():Account
		{
			return _creatingAccount;
		}

		public function set creatingAccount(value:Account):void
		{
			_creatingAccount = value;
		}

		public function get subjectAccount():Account
		{
			return _subjectAccount;
		}

		public function set subjectAccount(value:Account):void
		{
			_subjectAccount = value;
		}

		public function get invitedAccounts():Vector.<Account>
		{
			return _invitedAccounts;
		}

		public function set invitedAccounts(value:Vector.<Account>):void
		{
			_invitedAccounts = value;
		}

		public function get sourceAccount():Account
		{
			return _sourceAccount;
		}

		public function set sourceAccount(value:Account):void
		{
			_sourceAccount = value;
		}

		public function get controllingAccount():Account
		{
			return _controllingAccount;
		}

		public function set controllingAccount(value:Account):void
		{
			_controllingAccount = value;
		}

		public function get peerAccount():Account
		{
			return _peerAccount;
		}

		public function set peerAccount(value:Account):void
		{
			_peerAccount = value;
		}

		public function get collaborationState():String
		{
			return _collaborationState;
		}

		public function set collaborationState(value:String):void
		{
			_collaborationState = value;
		}
	}
}