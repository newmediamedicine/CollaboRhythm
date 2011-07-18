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

	import collaboRhythm.shared.controller.CollaborationController;
	import collaboRhythm.shared.controller.CollaborationEvent;
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionEvent;

	import flash.events.AsyncErrorEvent;

	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import flash.utils.getQualifiedClassName;

	/**
	 *
	 * @author jom
	 *
	 * This class is coordinates communication with the FMS to keep track of what remoteUsers are online and to handle the sending and receiving of
	 * collaboration requests, cancellations, and acceptances.
	 *
	 */
	[Bindable]
	public class CollaborationLobbyNetConnectionService extends EventDispatcher
	{
		private var _localUserName:String;
		private var _rtmpURI:String;

		private const MAX_FAILED_ATTEMPTS:int = 3;
		private var _failedAttempts:uint = 0;
		private var _automaticRetryEnabled:Boolean = true;

		private const NETCONNECTION_STATUS_CALL_FAILED:String = "NetConnection.Call.Failed";
		private const NETCONNECTION_STATUS_CONNECT_APPSHUTDOWN:String = "NetConnection.Connect.AppShutdown";
		private const NETCONNECTION_STATUS_CONNECT_CLOSED:String = "NetConnection.Connect.Closed";
		private const NETCONNECTION_STATUS_CONNECT_FAILED:String = "NetConnection.Connect.Failed";
		private const NETCONNECTION_STATUS_CONNECT_REJECTED:String = "NetConnection.Connect.Rejected";
		private const NETCONNECTION_STATUS_CONNECT_SUCCESS:String = "NetConnection.Connect.Success";

		private var _isConnected:Boolean = false;
		private var _netConnection:NetConnection;
		private var _activeAccount:Account;
		private var _collaborationModel:CollaborationModel;
		private var _logger:ILogger;

		public function CollaborationLobbyNetConnectionService(localUserName:String, rtmpBaseURI:String,
															   collaborationModel:CollaborationModel,
															   activeAccount:Account)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_localUserName = localUserName;
			_rtmpURI = rtmpBaseURI + "/CollaboRhythm.CollaborationServer/_definst_";
			_collaborationModel = collaborationModel;
			_activeAccount = activeAccount;

			_netConnection = new NetConnection();
			_netConnection.client = new Object();
			_netConnection.client.activeAccountCollaborationLobbyConnectionStatusChanged = activeAccountCollaborationLobbyConnectionStatusChanged;
			_netConnection.client.sharingAccountCollaborationLobbyConnectionStatusChanged = sharingAccountCollaborationLobbyConnectionStatusChanged;
			_netConnection.client.receiveCollaborationRequest = receiveCollaborationRequest;
			_netConnection.client.receiveSynchronizationMessage = receiveSynchronizationMessage;

			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		}

		public function enterCollaborationLobby():void
		{
			if (_failedAttempts == 0)
			{
				_logger.info("Collaboration Lobby NetConnection initial connection attempt...");
			}
			_netConnection.connect(_rtmpURI, _activeAccount.accountId, User.COLLABORATION_LOBBY_AVAILABLE,
								   _activeAccount.allSharingAccounts.keys.toArray());
		}

		private function retryConnection():void
		{
			_failedAttempts += 1;
			if (_failedAttempts <= MAX_FAILED_ATTEMPTS && _automaticRetryEnabled)
			{
				_logger.info("Collection Lobby NetConnection retry {1} of {2}.", _failedAttempts, MAX_FAILED_ATTEMPTS.toString());
				enterCollaborationLobby();
			}
			else
			{
				_logger.warn("Collection Lobby NetConnection failed {1} of {2}. Giving up.", _failedAttempts, MAX_FAILED_ATTEMPTS.toString());
			}
		}

		private function netStatusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NETCONNECTION_STATUS_CALL_FAILED:
					_logger.info("Collaboration Lobby NetConnection status " + NETCONNECTION_STATUS_CALL_FAILED);
					break;
				case NETCONNECTION_STATUS_CONNECT_APPSHUTDOWN:
					_logger.warn("Collaboration Lobby NetConnection status " + NETCONNECTION_STATUS_CONNECT_APPSHUTDOWN);
					isConnected = false;
					break;
				case NETCONNECTION_STATUS_CONNECT_CLOSED:
					_logger.info("Collaboration Lobby NetConnection status " + NETCONNECTION_STATUS_CONNECT_CLOSED);
					isConnected = false;
					retryConnection();
					break;
				case NETCONNECTION_STATUS_CONNECT_FAILED:
					_logger.info("Collaboration Lobby NetConnection status " + NETCONNECTION_STATUS_CONNECT_FAILED);
					retryConnection();
					break;
				case NETCONNECTION_STATUS_CONNECT_REJECTED:
					_logger.warn("Collaboration Lobby NetConnection status " + NETCONNECTION_STATUS_CONNECT_REJECTED + " " + event.info);
					break;
				case NETCONNECTION_STATUS_CONNECT_SUCCESS:
					_logger.info("Collaboration Lobby NetConnection status " + NETCONNECTION_STATUS_CONNECT_SUCCESS);
					isConnected = true;
					break;
			}
		}

		private function ioErrorHandler(error:IOErrorEvent):void
		{
			_logger.warn(IOErrorEvent.IO_ERROR + error.errorID + " " + error.text);
		}

		private function asyncErrorHandler(error:AsyncErrorEvent):void
		{
			_logger.warn(AsyncErrorEvent.ASYNC_ERROR + error.errorID + " " + error.text);
		}

		private function securityErrorHandler(error:SecurityErrorEvent):void
		{
			_logger.warn(SecurityErrorEvent.SECURITY_ERROR + error.errorID + " " + error.text);
		}

		public function updateCollaborationLobbyConnectionStatus(collaborationLobbyConnectionStatus:String):void
		{
			_netConnection.call("updateCollaborationLobbyConnectionStatus", null, _localUserName,
								collaborationLobbyConnectionStatus);
		}

		public function exitCollaborationLobby():void
		{
			updateCollaborationLobbyConnectionStatus(User.COLLABORATION_LOBBY_NOT_CONNECTED);
			_netConnection.close();
		}

		private function activeAccountCollaborationLobbyConnectionStatusChanged(collaborationLobbyConnectionStatus:String):void
		{
			_activeAccount.collaborationLobbyConnectionStatus = collaborationLobbyConnectionStatus;
		}

		private function sharingAccountCollaborationLobbyConnectionStatusChanged(accountId:String,
																				 collaborationLobbyConnectionStatus:String):void
		{
			var account:Account = _activeAccount.allSharingAccounts[accountId];
			if (account != null)
			{
				account.collaborationLobbyConnectionStatus = collaborationLobbyConnectionStatus;
			}
		}

		public function getCollaborationRoomID():void
		{
			_netConnection.call("getCollaborationRoomID",
								new Responder(getCollaborationRoomIDSucceeded, getCollaborationRoomIDFailed));
		}

		public function getCollaborationRoomIDSucceeded(roomID:String):void
		{
			_collaborationModel.roomID = roomID;
			_collaborationModel.passWord = String(Math.round(Math.random() * 10000));
			_collaborationModel.collaborationRoomNetConnectionService.enterCollaborationRoom(_collaborationModel.roomID,
																							 _collaborationModel.passWord,
																							 _collaborationModel.subjectUser.accountId);
		}

		public function getCollaborationRoomIDFailed(info:Object):void
		{
			trace(info);
		}

		public function sendCollaborationRequest(remoteUserName:String, roomID:String, passWord:String,
												 creatingUserName:String, subjectUserName:String):void
		{
//			var remoteUser:User = _usersModel.retrieveUser(remoteUserName);
//			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_REQUEST_SENT;
			_netConnection.call("sendCollaborationRequest", null, _localUserName, remoteUserName, roomID, passWord,
								creatingUserName, subjectUserName);
		}

		public function receiveCollaborationRequest(invitingUserName:String, roomID:String, passWord:String,
													creatingUserName:String, subjectUserName:String):void
		{
//			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_REQUEST_RECEIVED;

//			_collaborationModel.collaborationRoomNetConnectionService.enterCollaborationRoom(roomID, passWord, subjectUserName);
//			_collaborationModel.invitingUser = _usersModel.retrieveUserByAccountId(invitingUserName);
//			_collaborationModel.creatingUser = _usersModel.retrieveUserByAccountId(creatingUserName);
//			_collaborationModel.subjectUser = _usersModel.retrieveUserByAccountId(subjectUserName);
//			_collaborationModel.roomID = roomID;
//			_collaborationModel.passWord = passWord;
		}

		public function sendSynchronizationMessage():void
		{
			_netConnection.call("sendSynchronizationMessage", null, _activeAccount.accountId);
		}

		public function receiveSynchronizationMessage():void
		{
			_collaborationModel.dispatchEvent(new CollaborationLobbyNetConnectionEvent(CollaborationLobbyNetConnectionEvent.SYNCHRONIZE));
		}

		public function get isConnected():Boolean
		{
			return _isConnected;
		}

		public function set isConnected(value:Boolean):void
		{
			_isConnected = value;
		}

		public function get netConnection():NetConnection
		{
			return _netConnection;
		}

		public function set netConnection(value:NetConnection):void
		{
			_netConnection = value;
		}

		public function get automaticRetryEnabled():Boolean
		{
			return _automaticRetryEnabled;
		}

		public function set automaticRetryEnabled(value:Boolean):void
		{
			_automaticRetryEnabled = value;
		}
	}
}