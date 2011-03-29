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
	import collaboRhythm.shared.controller.CollaborationEvent;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
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
		private var _localUserName:String;
		private var _rtmpURI:String; 	
		private var _collaborationModel:CollaborationModel;
		
		private var _netConnection:NetConnection;
		
		public function CollaborationRoomNetConnectionService(userName:String, rtmpBaseURI:String, collaborationModel:CollaborationModel)
		{
			_localUserName = userName;
			_rtmpURI = rtmpBaseURI + "/CollaboRhythmServer/";
			_collaborationModel = collaborationModel;
			
			_netConnection = new NetConnection();
			_netConnection.client = new Object();
		}

		public function createProxy():CollaborationRoomNetConnectionServiceProxy
		{
			var proxy:CollaborationRoomNetConnectionServiceProxy = new CollaborationRoomNetConnectionServiceProxy(this);
			return proxy;
		}

		public function get localUserName():String
		{
			return _localUserName;
		}
		
		public function set localUserName(value:String):void
		{
			_localUserName = value;
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
		
		public function enterCollaborationRoom(roomID:String, passWord:String, subjectUserName:String):void
		{
			var rtmpRoomURI:String = _rtmpURI + roomID;

			_netConnection.client.localUserEnteredCollaborationRoom = localUserEnteredCollaborationRoom;
			_netConnection.client.localUserJoinedCollaborationRoom = localUserJoinedCollaborationRoom;
			_netConnection.client.localUserExitedCollaborationRoom = localUserExitedCollaborationRoom;
			_netConnection.client.remoteUserEnteredCollaborationRoom = remoteUserEnteredCollaborationRoom;
			_netConnection.client.remoteUserJoinedCollaborationRoom = remoteUserJoinedCollaborationRoom;
			_netConnection.client.remoteUserExitedCollaborationRoom = remoteUserExitedCollaborationRoom;
			_netConnection.client.invitedUserAdded = invitedUserAdded;
			_netConnection.client.playRemoteUserVideoStream = playRemoteUserVideoStream;
			_netConnection.client.reconnectLocalUserVideoStream = reconnectLocalUserVideoStream;
			
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, collaborationRoomNetStatusHandler);
			_netConnection.connect(rtmpRoomURI, _localUserName, passWord, subjectUserName);
		}
					
		public function joinCollaborationRoom():void
		{
			_netConnection.call("joinCollaborationRoom", null, _localUserName);
		}
		
		public function exitCollaborationRoom():void
		{
			_netConnection.call("exitCollaborationRoom", null, _localUserName);
		}
		
		public function addInvitedUser(invitedUserName:String):void
		{
			_netConnection.call("addInvitedUser", null, _localUserName, invitedUserName);
		}
		
		public function localUserEnteredCollaborationRoom(collaborationColor:String, invitedUserNames:Array):void
		{
			_collaborationModel.active = true;
			
			_collaborationModel.collaborationLobbyNetConnectionService.updateCollaborationLobbyConnectionStatus(User.COLLABORATION_LOBBY_AWAY);
			_collaborationModel.localUser.collaborationRoomConnectionStatus = User.COLLABORATION_ROOM_ENTERED;
			_collaborationModel.localUser.collaborationColor = collaborationColor;
			for each (var invitedUserName:String in invitedUserNames)
			{
				var invitedUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(invitedUserName);
				_collaborationModel.addInvitedUser(invitedUser);
			}
			
			if (_collaborationModel.creatingUser == _collaborationModel.localUser)
			{
				_collaborationModel.collaborationLobbyNetConnectionService.sendCollaborationRequest(_collaborationModel.subjectUser.accountId, _collaborationModel.roomID, _collaborationModel.passWord, _collaborationModel.creatingUser.accountId, _collaborationModel.subjectUser.accountId);
				// TODO: if there are other invited users, need to invite them here
			}
		}
		
		public function localUserJoinedCollaborationRoom():void
		{
			_collaborationModel.localUser.collaborationRoomConnectionStatus = User.COLLABORATION_ROOM_JOINED;
		}
		
		public function localUserExitedCollaborationRoom():void
		{
			_collaborationModel.collaborationLobbyNetConnectionService.updateCollaborationLobbyConnectionStatus(User.COLLABORATION_LOBBY_AVAILABLE);
			_collaborationModel.localUser.collaborationRoomConnectionStatus = User.COLLABORATION_ROOM_EXITED;
			stopPublishingLocalUserVideoStream();
			_netConnection.close();
			_collaborationModel.active = false;
		}
				
		private function remoteUserEnteredCollaborationRoom(remoteUserName:String, collaborationColor:String):void
		{
			var remoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(remoteUserName);
			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_ROOM_ENTERED;
			remoteUser.collaborationColor = collaborationColor;
//			_collaborationModel.addCollaboratingRemoteUser(remoteUser);
		}
		
		private function remoteUserJoinedCollaborationRoom(remoteUserName:String):void
		{
			var remoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(remoteUserName);
			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_ROOM_JOINED;
		}
		
		public function remoteUserExitedCollaborationRoom(remoteUserName:String):void
		{
			var remoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(remoteUserName);
			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_ROOM_EXITED;
			remoteUser.collaborationColor = "0xFFFFFF";
			stopPlayingRemoteUserVideoStream(remoteUser);
		}
		
		private function invitedUserAdded(remoteUserName:String):void
		{
			var remoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(remoteUserName);
			_collaborationModel.addInvitedUser(remoteUser);
		}
		
		public function connectLocalUserVideoStream():void
		{
			if (_netConnection && _netConnection.connected)
			{
				publishLocalUserVideoStream();
				_netConnection.call("videoStreamConnected", null, _localUserName);
			}
		}
		
		private function reconnectLocalUserVideoStream():void
		{		
			publishLocalUserVideoStream();
		}
		
		public function publishLocalUserVideoStream():void
		{		
			var netStreamOut:NetStream = new NetStream(_netConnection);
			netStreamOut.attachCamera(_collaborationModel.audioVideoOutput.camera);
//			_nsOut.attachAudio(_videoOutput.microphone);
			netStreamOut.addEventListener(StatusEvent.STATUS, netStreamOutHandler);
			netStreamOut.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			netStreamOut.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			netStreamOut.publish(_localUserName, "live");
			
			_collaborationModel.localUser.video.attachCamera(_collaborationModel.audioVideoOutput.camera);
			_collaborationModel.localUser.netStream = netStreamOut;
		}
		
		public function stopPublishingLocalUserVideoStream():void
		{
			if (_collaborationModel.localUser.netStream != null)
			{
				_collaborationModel.localUser.netStream.close();
				_collaborationModel.localUser.netStream = null;
			}
		}
		
		private function playRemoteUserVideoStream(userName:String):void
		{
			var netStreamIn:NetStream = new NetStream(_netConnection);
			netStreamIn.addEventListener(NetStatusEvent.NET_STATUS, netStreamInHandler);
			netStreamIn.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			netStreamIn.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			netStreamIn.play(userName);
			
			var collaboratingRemoteUser:User = _collaborationModel.usersModel.retrieveUserByAccountId(userName);
			collaboratingRemoteUser.video.attachNetStream(netStreamIn);
			collaboratingRemoteUser.netStream = netStreamIn;
		}
		
		public function stopPlayingRemoteUserVideoStream(remoteUser:User):void
		{
			if (remoteUser.netStream != null)
			{
				remoteUser.netStream.close();
				remoteUser.netStream = null;
			}
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
				for each(var collaboratingRemoteUser:User in _collaborationModel.collaborationRoomUsers)
				{
					if (collaboratingRemoteUser.video == event.target)
					{
						var now:Date = new Date();
						_netConnection.call("videoStreamInterrupted", null, collaboratingRemoteUser.accountId, now.getTime()); 
					}
				}
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