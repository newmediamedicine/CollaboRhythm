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
	import collaboRhythm.shared.collaboration.controller.CollaborationEvent;
	import collaboRhythm.shared.model.*;

	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	/**
	 *
	 * @author jom
	 *
	 * This class is coordinates communication with the FMS to keep track of what remoteUsers are online and to handle the sending and receiving of
	 * collaboration requests, cancellations, and acceptances.
	 *
	 */
	[Bindable]
	public class CollaborationLobbyNetConnectionService extends EventDispatcher implements ICollaborationLobbyNetConnectionService
	{
		public static const INVITE:String = "invite";
		public static const ACCEPT:String = "accept";
		public static const REJECT:String = "reject";
		public static const CANCEL:String = "cancel";
		public static const END:String = "end";
		public static const SYNCHRONIZE:String = "synchronize";

		private const COLLABORATION_LOBBY:String = "Collaboration Lobby";
		private const NETCONNECTION_STATUS_CALL_FAILED:String = "NetConnection.Call.Failed";
		private const NETCONNECTION_STATUS_CONNECT_APPSHUTDOWN:String = "NetConnection.Connect.AppShutdown";
		private const NETCONNECTION_STATUS_CONNECT_CLOSED:String = "NetConnection.Connect.Closed";
		private const NETCONNECTION_STATUS_CONNECT_FAILED:String = "NetConnection.Connect.Failed";
		private const NETCONNECTION_STATUS_CONNECT_REJECTED:String = "NetConnection.Connect.Rejected";

		private const NETCONNECTION_STATUS_CONNECT_SUCCESS:String = "NetConnection.Connect.Success";
		private var _activeAccount:Account;
		private var _collaborationModel:CollaborationModel;

		private var _rtmpURI:String;
		private const MAX_FAILED_ATTEMPTS:int = 3;

		private var _failedAttempts:uint = 0;
		private var _automaticRetryEnabled:Boolean = true;
		private var _isConnecting:Boolean = false;
		private var _hasConnectionFailed:Boolean = false;
		private var _isConnected:Boolean = false;

		private var _netConnection:NetConnection;

		private var _logger:ILogger;
		private var _retryConnectionTimer:Timer;
		private var _netStreamOut:NetStream;
		private var _netStreamIn:NetStream;

		public function CollaborationLobbyNetConnectionService(activeAccount:Account, rtmpBaseURI:String,
															   collaborationModel:CollaborationModel)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_activeAccount = activeAccount;
			_rtmpURI = rtmpBaseURI + "/CollaboRhythm.CollaborationServer/_definst_";
			_collaborationModel = collaborationModel;

			_netConnection = new NetConnection();

			_netConnection.client = new Object();
			_netConnection.client.activeAccountCollaborationLobbyConnectionStatusChanged = activeAccountCollaborationLobbyConnectionStatusChanged;
			_netConnection.client.sharingAccountCollaborationLobbyConnectionStatusChanged = sharingAccountCollaborationLobbyConnectionStatusChanged;
			_netConnection.client.receiveMessage = receiveMessage;

			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, netConnection_NetStatusHandler);
			_netConnection.addEventListener(IOErrorEvent.IO_ERROR, netConnection_IOErrorHandler);
			_netConnection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, netConnection_AsyncErrorHandler);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, netConneciton_SecurityErrorHandler);
		}

		public function enterCollaborationLobby():void
		{
			if (_failedAttempts == 0)
			{
				_logger.info(COLLABORATION_LOBBY + " initial connection attempt...");
			}
			isConnecting = true;
			_netConnection.connect(_rtmpURI, _activeAccount.accountId, Account.COLLABORATION_LOBBY_AVAILABLE,
					_activeAccount.allSharingAccounts.keys.toArray());
		}

		private function netConnection_NetStatusHandler(event:NetStatusEvent):void
		{
			switch (event.info.code)
			{
				case NETCONNECTION_STATUS_CALL_FAILED:
					_logger.info(COLLABORATION_LOBBY + " status " + NETCONNECTION_STATUS_CALL_FAILED);
					break;
				case NETCONNECTION_STATUS_CONNECT_APPSHUTDOWN:
					_logger.warn(COLLABORATION_LOBBY + " status " + NETCONNECTION_STATUS_CONNECT_APPSHUTDOWN);
					isConnected = false;
					break;
				case NETCONNECTION_STATUS_CONNECT_CLOSED:
					_logger.info(COLLABORATION_LOBBY + " status " + NETCONNECTION_STATUS_CONNECT_CLOSED);
					connectionFailedHandler();
					break;
				case NETCONNECTION_STATUS_CONNECT_FAILED:
					_logger.info(COLLABORATION_LOBBY + " status " + NETCONNECTION_STATUS_CONNECT_FAILED);
					connectionFailedHandler();
					break;
				case NETCONNECTION_STATUS_CONNECT_REJECTED:
					_logger.warn(COLLABORATION_LOBBY + " status " + NETCONNECTION_STATUS_CONNECT_REJECTED + " " +
							event.info);
					break;
				case NETCONNECTION_STATUS_CONNECT_SUCCESS:
					_logger.info(COLLABORATION_LOBBY + " status " + NETCONNECTION_STATUS_CONNECT_SUCCESS);
					connectionSucceededHandler();
					break;
			}
		}

		private function netConnection_IOErrorHandler(error:IOErrorEvent):void
		{
			_logger.warn(IOErrorEvent.IO_ERROR + error.errorID + " " + error.text);
		}

		private function netConnection_AsyncErrorHandler(error:AsyncErrorEvent):void
		{
			_logger.warn(AsyncErrorEvent.ASYNC_ERROR + error.errorID + " " + error.text);
		}

		private function netConneciton_SecurityErrorHandler(error:SecurityErrorEvent):void
		{
			_logger.warn(SecurityErrorEvent.SECURITY_ERROR + error.errorID + " " + error.text);
		}

		private function connectionSucceededHandler():void
		{
			isConnecting = false;
			isConnected = true;
			hasConnectionFailed = false;
			_failedAttempts = 0;
		}

		private function connectionFailedHandler():void
		{
			isConnected = false;
			_failedAttempts += 1;
			if (_failedAttempts <= MAX_FAILED_ATTEMPTS && _automaticRetryEnabled)
			{
				_logger.info(COLLABORATION_LOBBY + " retry {0} of {1}.", _failedAttempts,
						MAX_FAILED_ATTEMPTS.toString());
				startRetryConnectionTimer();
			}
			else
			{
				_logger.warn(COLLABORATION_LOBBY + " failed {0} of {1}. Giving up.", MAX_FAILED_ATTEMPTS.toString(),
						MAX_FAILED_ATTEMPTS.toString());
				hasConnectionFailed = true;
				isConnecting = false;
				_failedAttempts = 0;
			}
		}

		private function startRetryConnectionTimer():void
		{
			_retryConnectionTimer = new Timer(1000, 1);
			_retryConnectionTimer.addEventListener(TimerEvent.TIMER, retryConnectionTimer_timerEventHandler);
			_retryConnectionTimer.start();
		}

		private function retryConnectionTimer_timerEventHandler(event:TimerEvent):void
		{
			enterCollaborationLobby();
		}

		public function updateCollaborationLobbyConnectionStatus(collaborationLobbyConnectionStatus:String):void
		{
			_netConnection.call("updateCollaborationLobbyConnectionStatus", null, _activeAccount.accountId,
					collaborationLobbyConnectionStatus);
		}

		private function activeAccountCollaborationLobbyConnectionStatusChanged(collaborationLobbyConnectionStatus:String,
																				peerId:String):void
		{
			_activeAccount.collaborationLobbyConnectionStatus = collaborationLobbyConnectionStatus;
			_activeAccount.peerId = peerId;
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

		public function exitCollaborationLobby():void
		{
			updateCollaborationLobbyConnectionStatus(Account.COLLABORATION_LOBBY_NOT_CONNECTED);
			_netConnection.close();
		}

		public function sendMessage(messageType:String, method:String = null):void
		{
			if (_collaborationModel && _collaborationModel.peerAccount)
			{
				_netConnection.call("sendMessage", null, messageType, _activeAccount.accountId,
						_activeAccount.accountId,
						_activeAccount.peerId,
						_collaborationModel.peerAccount.accountId, _collaborationModel.peerAccount.peerId,
						_collaborationModel.passWord, method);
			}
		}

		public function receiveMessage(messageType:String, subjectAccountId:String, sourceAccountId:String,
									   sourcePeerId:String, passWord:String, method:String):void
		{
			var eventType:String;
			switch (messageType)
			{
				case INVITE:
					eventType = CollaborationEvent.COLLABORATION_INVITATION_RECEIVED;
					break;
				case ACCEPT:
					eventType = CollaborationEvent.COLLABORATION_INVITATION_ACCEPTED;
					break;
				case REJECT:
					eventType = CollaborationEvent.COLLABORATION_INVITATION_REJECTED;
					break;
				case CANCEL:
					eventType = CollaborationEvent.COLLABORATION_INVITATION_CANCELLED;
					break;
				case END:
					eventType = CollaborationEvent.COLLABORATION_ENDED;
					break;
				case SYNCHRONIZE:
					eventType = CollaborationEvent.SYNCHRONIZE;
					break;
			}

			var collaborationEvent:CollaborationEvent = new CollaborationEvent(eventType,
					subjectAccountId, sourceAccountId, sourcePeerId, passWord, method);
			dispatchEvent(collaborationEvent);
		}

		public function createCommunicationConnection():void
		{
			netStreamOut = new NetStream(_netConnection, NetStream.DIRECT_CONNECTIONS);
			netStreamOut.addEventListener(NetStatusEvent.NET_STATUS, netStreamOut_netStatusHandler);
			netStreamOut.publish(_activeAccount.accountId, "live");

			netStreamOut.attachAudio(_collaborationModel.audioVideoOutput.microphone);

			netStreamIn = new NetStream(_netConnection, _collaborationModel.peerAccount.peerId);
			netStreamIn.addEventListener(NetStatusEvent.NET_STATUS, netStreamIn_netStatusHandler);
			netStreamIn.bufferTime = 0;
			netStreamIn.play(_collaborationModel.peerAccount.accountId);
		}

		public function closeCollaborationConnection():void
		{
			netStreamOut.close();
			netStreamOut = null;

			netStreamIn.close();
			netStreamIn = null;
		}

		private function netStreamOut_netStatusHandler(event:NetStatusEvent):void
		{
			trace("Outgoing stream event: " + event.info.code + "\n");
		}

		private function netStreamIn_netStatusHandler(event:NetStatusEvent):void
		{
			trace("Incoming stream event: " + event.info.code + "\n");
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

		public function get hasConnectionFailed():Boolean
		{
			return _hasConnectionFailed;
		}

		public function set hasConnectionFailed(value:Boolean):void
		{
			_hasConnectionFailed = value;
		}

		public function get isConnecting():Boolean
		{
			return _isConnecting;
		}

		public function set isConnecting(value:Boolean):void
		{
			_isConnecting = value;
		}

		public function get netStreamOut():NetStream
		{
			return _netStreamOut;
		}

		public function set netStreamOut(value:NetStream):void
		{
			_netStreamOut = value;
		}

		public function get netStreamIn():NetStream
		{
			return _netStreamIn;
		}

		public function set netStreamIn(value:NetStream):void
		{
			_netStreamIn = value;
		}

		public function sendSynchronizationMessage():void
		{
			_netConnection.call("sendSynchronizationMessage", null, _collaborationModel.activeRecordAccount.accountId);
		}

		public function receiveSynchronizationMessage():void
		{
			_collaborationModel.dispatchEvent(new CollaborationLobbyNetConnectionEvent(CollaborationLobbyNetConnectionEvent.SYNCHRONIZE));
		}

		public function getCollaborationRoomID():void
		{
			_netConnection.call("getCollaborationRoomID",
					new Responder(getCollaborationRoomIDSucceeded, getCollaborationRoomIDFailed));
		}

		public function getCollaborationRoomIDSucceeded(roomID:String):void
		{
//			_collaborationModel.roomID = roomID;
//			_collaborationModel.passWord = String(Math.round(Math.random() * 10000));
//			for each (var targetAccount:Account in _collaborationModel.invitedAccounts)
//			{
////				sendCollaborationInvitation(targetAccount, _collaborationModel.roomID, _collaborationModel.passWord,
////						_collaborationModel.creatingAccount, _collaborationModel.subjectAccount);
//			}
//			_collaborationModel.collaborationRoomNetConnectionService.enterCollaborationRoom(_collaborationModel.roomID,
//					_collaborationModel.passWord,
//					_collaborationModel.subjectAccount.accountId);
		}

		public function getCollaborationRoomIDFailed(info:Object):void
		{
			trace(info);
		}


	}
}