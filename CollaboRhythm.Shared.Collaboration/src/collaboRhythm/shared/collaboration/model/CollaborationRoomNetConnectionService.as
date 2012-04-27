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
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * 
	 * @author jom
	 * 
	 * Handles communication with the room.asc application on the FMS. The room.asc application is responsible for private collaborations between local and remote users.
	 * This class allows users to start a collaboration or to join an existing collaboration. It also defines the client side functions for connecting video streams and
	 * playing video streams at the request of the room.asc application.
	 * 
	 */
	public class CollaborationRoomNetConnectionService extends EventDispatcher
	{
		private var _activeAccount:Account;
		private var _rtmpURI:String; 	
		private var _collaborationModel:CollaborationModel;
		
		private var _netConnection:NetConnection;
		
		public function CollaborationRoomNetConnectionService(activeAccount:Account, rtmpBaseURI:String,
															  collaborationModel:CollaborationModel)
		{
			_activeAccount = activeAccount;
			_rtmpURI = "rtmfp://18.85.55.246/CollaboRhythm.CollaborationServer/";
			_collaborationModel = collaborationModel;
			
			_netConnection = new NetConnection();
			_netConnection.client = new Object();
		}

		public function createProxy():CollaborationRoomNetConnectionServiceProxy
		{
			var proxy:CollaborationRoomNetConnectionServiceProxy = new CollaborationRoomNetConnectionServiceProxy(this);
			return proxy;
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}
		
		public function set activeAccount(value:Account):void
		{
			_activeAccount = value;
		}
		
		public function get netConnection():NetConnection
		{
			return _netConnection;
		}
		
		public function set netConnection(value:NetConnection):void
		{
			_netConnection = value;
		}
		
		public function get collaborationModel():CollaborationModel
		{
			return _collaborationModel;
		}
		
		public function set collaborationModel(value:CollaborationModel):void
		{
			_collaborationModel = value;
		}
		
		public function enterCollaborationRoom(roomID:String, passWord:String, subjectAccountId:String):void
		{
			var rtmpRoomURI:String = _rtmpURI + roomID;

			_netConnection.client.activeAccountEnteredCollaborationRoom = activeAccountEnteredCollaborationRoom;
			_netConnection.client.activeAccountJoinedCollaborationRoom = activeAccountJoinedCollaborationRoom;
			_netConnection.client.activeAccountExitedCollaborationRoom = activeAccountExitedCollaborationRoom;
			_netConnection.client.sharingAccountEnteredCollaborationRoom = sharingAccountEnteredCollaborationRoom;
			_netConnection.client.sharingAccountJoinedCollaborationRoom = sharingAccountJoinedCollaborationRoom;
			_netConnection.client.sharingAccountExitedCollaborationRoom = sharingAccountExitedCollaborationRoom;
			_netConnection.client.invitedUserAdded = invitedUserAdded;
			_netConnection.client.playSharingAccountVideoStream = playSharingAccountVideoStream;
			_netConnection.client.reconnectActiveAccountVideoStream = reconnectActiveAccountVideoStream;
			
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, collaborationRoomNetStatusHandler);
			_netConnection.connect(rtmpRoomURI, _activeAccount.accountId, passWord, subjectAccountId);
		}
					
		public function joinCollaborationRoom():void
		{
			_netConnection.call("joinCollaborationRoom", null, _activeAccount.accountId);
		}
		
		public function exitCollaborationRoom():void
		{
			_netConnection.call("exitCollaborationRoom", null, _activeAccount.accountId);
		}
		
		public function addInvitedUser(invitedUserName:String):void
		{
			_netConnection.call("addInvitedUser", null, _activeAccount.accountId, invitedUserName);
		}
		
		public function activeAccountEnteredCollaborationRoom(collaborationColor:String, invitedAccountIds:Array):void
		{
//			_collaborationModel.active = true;
//
//			_collaborationModel.collaborationLobbyNetConnectionService.updateCollaborationLobbyConnectionStatus(Account.COLLABORATION_LOBBY_AWAY);
//			_collaborationModel.activeAccount.collaborationRoomConnectionStatus = Account.COLLABORATION_ROOM_ENTERED;
		}
		
		public function activeAccountJoinedCollaborationRoom():void
		{
			_collaborationModel.activeAccount.collaborationRoomConnectionStatus = Account.COLLABORATION_ROOM_JOINED;
			connectActiveAccountVideoStream();
		}
		
		public function activeAccountExitedCollaborationRoom():void
		{
//			_collaborationModel.collaborationLobbyNetConnectionService.updateCollaborationLobbyConnectionStatus(Account.COLLABORATION_LOBBY_AVAILABLE);
//			_collaborationModel.activeAccount.collaborationRoomConnectionStatus = Account.COLLABORATION_ROOM_EXITED;
//			stopPublishingLocalUserVideoStream();
//			_netConnection.close();
//			_collaborationModel.active = false;
		}
				
		private function sharingAccountEnteredCollaborationRoom(sharingAccountId:String, collaborationColor:String):void
		{
			var sharingAccount:Account = _collaborationModel.activeAccount.allSharingAccounts[sharingAccountId];
			sharingAccount.collaborationRoomConnectionStatus = Account.COLLABORATION_ROOM_ENTERED;
		}
		
		private function sharingAccountJoinedCollaborationRoom(sharingAccountId:String):void
		{
			var sharingAccount:Account = _collaborationModel.activeAccount.allSharingAccounts[sharingAccountId];
			sharingAccount.collaborationRoomConnectionStatus = Account.COLLABORATION_ROOM_JOINED;
		}
		
		public function sharingAccountExitedCollaborationRoom(sharingAccountId:String):void
		{
			var sharingAccount:Account = _collaborationModel.activeAccount.allSharingAccounts[sharingAccountId];
			sharingAccount.collaborationRoomConnectionStatus = Account.COLLABORATION_ROOM_EXITED;
//			sharingAccount.collaborationColor = "0xFFFFFF";
			stopPlayingRemoteUserVideoStream(sharingAccount);
		}
		
		private function invitedUserAdded(remoteUserName:String):void
		{
//			var remoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(remoteUserName);
//			_collaborationModel.addInvitedUser(remoteUser);
		}
		
		public function connectActiveAccountVideoStream():void
		{
			if (_netConnection && _netConnection.connected)
			{
				publishActiveAccountVideoStream();
				_netConnection.call("videoStreamConnected", null, _activeAccount.accountId);
			}
		}
		
		private function reconnectActiveAccountVideoStream():void
		{		
			publishActiveAccountVideoStream();
		}
		
		public function publishActiveAccountVideoStream():void
		{		
			var netStreamOut:NetStream = new NetStream(_netConnection, NetStream.DIRECT_CONNECTIONS);
			netStreamOut.addEventListener(StatusEvent.STATUS, netStreamOutHandler);
			netStreamOut.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			netStreamOut.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			netStreamOut.publish(_activeAccount.accountId, "live");

			var microphone:Microphone = Microphone.getMicrophone(0);
			microphone.codec = SoundCodec.SPEEX;
			microphone.setSilenceLevel(0);
			microphone.framesPerPacket = 1;
			netStreamOut.attachAudio(microphone);
			var camera:Camera = Camera.getCamera("1");
			camera.setMode(320,240,15);
			camera.setQuality(0,70);
			netStreamOut.attachCamera(camera);

//			_collaborationModel.localUser.video.attachCamera(_collaborationModel.audioVideoOutput.camera);
			_activeAccount.netStream = netStreamOut;
		}
		
		public function stopPublishingLocalUserVideoStream():void
		{
//			if (_collaborationModel.activeAccount.netStream != null)
//			{
//				_collaborationModel.activeAccount.netStream.close();
//				_collaborationModel.activeAccount.netStream = null;
//			}
		}
		
		private function playSharingAccountVideoStream(accountId:String, peerId:String):void
		{
			var netStreamIn:NetStream = new NetStream(_netConnection, peerId);
			netStreamIn.addEventListener(NetStatusEvent.NET_STATUS, netStreamInHandler);
			netStreamIn.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			netStreamIn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			netStreamIn.play(accountId);

			var sharingAccount:Account = _collaborationModel.activeAccount.allSharingAccounts[accountId];
			sharingAccount.netStream = netStreamIn;

//			var collaboratingRemoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(accountId);
//			collaboratingRemoteUser.video.attachNetStream(netStreamIn);
//			collaboratingRemoteUser.netStream = netStreamIn;
		}
		
		public function stopPlayingRemoteUserVideoStream(sharingAccount:Account):void
		{
//			if (sharingAccount.netStream != null)
//			{
//				sharingAccount.netStream.close();
//				sharingAccount.netStream = null;
//			}
		}
		
		private function collaborationRoomNetStatusHandler(event:NetStatusEvent):void 
		{
			trace(event.info.code);
		}
		
		private function netStreamInHandler(event:NetStatusEvent):void
		{
			trace(event.info.code);
			if (event.info.code == "NetStream.Play.UnpublishNotify")
			{
//				for each(var collaboratingRemoteUser:User in _collaborationModel.collaborationRoomAccounts)
//				{
//					if (collaboratingRemoteUser.video == event.target)
//					{
//						var now:Date = new Date();
//						_netConnection.call("videoStreamInterrupted", null, collaboratingRemoteUser.accountId, now.getTime());
//					}
//				}
			}
		}
		
		private function netStreamOutHandler(event:NetStatusEvent):void
		{
			trace(event.info.code);
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void
		{
			trace(event.errorID);
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void
		{
			trace(event.errorID);
		}
	}
}