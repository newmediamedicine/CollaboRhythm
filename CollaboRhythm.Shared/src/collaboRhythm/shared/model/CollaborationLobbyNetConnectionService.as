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
	
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	
	import mx.collections.ArrayCollection;

	/**
	 * 
	 * @author jom
	 * 
	 * This class is coordinates communication with the FMS to keep track of what remoteUsers are online and to handle the sending and receiving of
	 * collaboration requests, cancellations, and acceptances.
	 * 
	 */
	public class CollaborationLobbyNetConnectionService extends EventDispatcher
	{		
		private var _localUserName:String;
		private var _rtmpURI:String; 	
		
		private var _netConnection:NetConnection;
		private var _usersModel:UsersModel;
		private var _collaborationModel:CollaborationModel;
		
		public function CollaborationLobbyNetConnectionService(localUserName:String, rtmpBaseURI:String, collaborationModel:CollaborationModel, usersModel:UsersModel)
		{
			_localUserName = localUserName;
			_rtmpURI = rtmpBaseURI + "/CollaboRhythmServer/_definst_";
			
			_netConnection = new NetConnection();
			_collaborationModel = collaborationModel
			_usersModel = usersModel;
		}
		
		public function enterCollaborationLobby():void
		{
			_netConnection.client = new Object();
			_netConnection.client.localUserCollaborationLobbyConnectionStatusChanged = localUserCollaborationLobbyConnectionStatusChanged;
			_netConnection.client.remoteUserCollaborationLobbyConnectionStatusChanged = remoteUserCollaborationLobbyConnectionStatusChanged;
			_netConnection.client.receiveCollaborationRequest = receiveCollaborationRequest;
			
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, collaborationLobbyConnectionHandler);
			_netConnection.connect(_rtmpURI, _localUserName, User.COLLABORATION_LOBBY_AVAILABLE, _usersModel.remoteUsers.keys.toArray());
		}
		
		public function updateCollaborationLobbyConnectionStatus(collaborationLobbyConnectionStatus:String):void
		{
			_netConnection.call("updateCollaborationLobbyConnectionStatus", null, _localUserName, collaborationLobbyConnectionStatus);
		}
		
		public function exitCollaborationLobby():void
		{
			updateCollaborationLobbyConnectionStatus(User.COLLABORATION_LOBBY_NOT_CONNECTED);
			_netConnection.close();
		}
		
		private function localUserCollaborationLobbyConnectionStatusChanged(collaborationLobbyConnectionStatus:String):void
		{
			_usersModel.localUser.collaborationLobbyConnectionStatus = collaborationLobbyConnectionStatus;
		}
		
		private function remoteUserCollaborationLobbyConnectionStatusChanged(userAccountId:String, collaborationLobbyConnectionStatus:String):void
		{
			var remoteUser:User = _usersModel.retrieveUserByAccountId(userAccountId);
			if (remoteUser != null) 
			{
				remoteUser.collaborationLobbyConnectionStatus = collaborationLobbyConnectionStatus;
			}
		}
		
		public function getCollaborationRoomID():void
		{
			_netConnection.call("getCollaborationRoomID", new Responder(getCollaborationRoomIDSucceeded, getCollaborationRoomIDFailed));
		}
		
		public function getCollaborationRoomIDSucceeded(roomID:String):void
		{
			_collaborationModel.roomID = roomID;
			_collaborationModel.passWord = String(Math.round(Math.random() * 10000));
			_collaborationModel.collaborationRoomNetConnectionService.enterCollaborationRoom(_collaborationModel.roomID, _collaborationModel.passWord, _collaborationModel.subjectUser.accountId);
		}
		
		public function getCollaborationRoomIDFailed(info:Object):void
		{
			trace(info);
		}
		
		public function sendCollaborationRequest(remoteUserName:String, roomID:String, passWord:String, creatingUserName:String, subjectUserName:String):void
		{
//			var remoteUser:User = _usersModel.retrieveUser(remoteUserName);
//			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_REQUEST_SENT;
			_netConnection.call("sendCollaborationRequest", null, _localUserName, remoteUserName, roomID, passWord, creatingUserName, subjectUserName);
		}
		
		public function receiveCollaborationRequest(invitingUserName:String, roomID:String, passWord:String, creatingUserName:String, subjectUserName:String):void
		{
//			remoteUser.collaborationRoomConnectionStatus = User.COLLABORATION_REQUEST_RECEIVED;
			_collaborationModel.collaborationRoomNetConnectionService.enterCollaborationRoom(roomID, passWord, subjectUserName);
			_collaborationModel.invitingUser = _usersModel.retrieveUserByAccountId(invitingUserName);
			_collaborationModel.creatingUser = _usersModel.retrieveUserByAccountId(creatingUserName);
			_collaborationModel.subjectUser = _usersModel.retrieveUserByAccountId(subjectUserName);
			_collaborationModel.roomID = roomID;
			_collaborationModel.passWord = passWord;		
		}
		
		private function collaborationLobbyConnectionHandler (event:NetStatusEvent):void
		{
			trace(event.info.code);
		}
	}
}