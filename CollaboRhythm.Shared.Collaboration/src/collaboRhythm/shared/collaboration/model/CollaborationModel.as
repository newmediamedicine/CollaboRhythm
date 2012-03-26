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

	import flash.net.NetStream;

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
	public class CollaborationModel implements ICollaborationModel
	{
		public static const COLLABORATION_ACTIVE:String = "CollaborationActive";
		public static const COLLABORATION_INACTIVE:String = "CollaborationInactive";
		public static const COLLABORATION_INVITATION_SENT:String = "CollaborationInvitationSent";
		public static const COLLABORATION_INVITATION_RECEIVED:String = "CollaborationInvitationReceived";
		public static const COLLABORATION_INVITATION_REJECTED:String = "CollaborationInvitationRejected";

		private var _collaborationState:String;

		private var _active:Boolean = false;
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

		public function endCollaboration():void
		{
			collaborationState = COLLABORATION_INACTIVE;
			collaborationLobbyNetConnectionService.closeCollaborationConnection();
			subjectAccount = null;
			peerAccount = null;
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

		public function set collaborationLobbyNetConnectionService(value:CollaborationLobbyNetConnectionService):void
		{
			_collaborationLobbyNetConnectionService = value;
		}

		public function get recordVideo():Boolean
		{
			return _recordVideo;
		}

		public function set recordVideo(value:Boolean):void
		{
			_recordVideo = value;
		}

		public function get audioVideoOutput():AudioVideoOutput
		{
			return _audioVideoOutput
		}

		public function set audioVideoOutput(value:AudioVideoOutput):void
		{
			_audioVideoOutput = value;
		}

		public function get activeRecordAccount():Account
		{
			return _activeRecordAccount;
		}

		public function set activeRecordAccount(value:Account):void
		{
			_activeRecordAccount = value;
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