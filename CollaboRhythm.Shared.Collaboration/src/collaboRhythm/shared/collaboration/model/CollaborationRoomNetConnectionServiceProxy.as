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
	import flash.net.NetConnection;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class CollaborationRoomNetConnectionServiceProxy
	{
		private var _collaborationModel:CollaborationModel;
		private var _collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService;
		private var _netConnection:NetConnection;
		private var _synchronizeHandler:*;
		private var _registeredAliases:Vector.<String>;

		public function CollaborationRoomNetConnectionServiceProxy(collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService)
		{
			_collaborationRoomNetConnectionService = collaborationRoomNetConnectionService;
			_collaborationModel = _collaborationRoomNetConnectionService.collaborationModel;
			_netConnection = _collaborationRoomNetConnectionService.netConnection;
			_netConnection.client.receiveCollaborationSynchronization = receiveCollaborationSynchronization;
			_registeredAliases = new Vector.<String>;
		}

		public function set synchronizeHandler(value:*):void
		{
			_synchronizeHandler = value;
		}

		public function getLocalUserCollaborationColor():String
		{
            return "#FFFFFF";
//			return _collaborationModel.localUser.collaborationColor;
		}

		public function receiveCollaborationSynchronization(userName:String, synchronizeFunction:String, sychronizeDataByteArray:ByteArray, synchronizeDataName:String):void
		{
//			// TODO: use recordId instead of userName
//			var user:User = _collaborationModel.usersModel.retrieveUserByAccountId(userName);
//			var collaborationColor:String = user.collaborationColor;
//			_collaborationModel.controllingUser = user;
//			if (_registeredAliases.indexOf(synchronizeDataName) == -1)
//			{
//				registerClassAlias(synchronizeDataName, getDefinitionByName(synchronizeDataName) as Class);
//				_registeredAliases.push(synchronizeDataName);
//			}
//			var sychronizeData:* = sychronizeDataByteArray.readObject();
//			_synchronizeHandler[synchronizeFunction](sychronizeData, userName, collaborationColor);
		}
		
		public function sendCollaborationSynchronization(synchronizeFunction:String, synchronizeData:*):void
		{
//			_collaborationModel.controllingUser = _collaborationModel.localUser;
//			// object.contructor property is possibly an alternative to get the instance of the class
//			var synchronizeDataName:String = getQualifiedClassName(synchronizeData);
//			if (_registeredAliases.indexOf(synchronizeDataName) == -1)
//			{
//				registerClassAlias(synchronizeDataName, getDefinitionByName(synchronizeDataName) as Class);
//				_registeredAliases.push(synchronizeDataName);
//			}
//			var sychronizeDataByteArray:ByteArray = new ByteArray();
//			sychronizeDataByteArray.writeObject(synchronizeData);
//			sychronizeDataByteArray.position = 0;
//			_netConnection.call("sendCollaborationSynchronization", null, _collaborationRoomNetConnectionService.localUserName, synchronizeFunction, sychronizeDataByteArray, synchronizeDataName);
		}
			
	}
}