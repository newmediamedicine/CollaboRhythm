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
	import collaboRhythm.shared.model.healthRecord.CommonHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;

	import flash.errors.IllegalOperationError;
	
	import j2as3.collection.HashMap;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * 
	 * @author jom
	 * 
	 * Keeps track of the local user and all of the remote users by using the UserDataBaseService and the RemoteUserNetConnectionService.
	 * Considering that only userNames are sent over the netConnection with the FMS, the retrieveRemoteUser function allows a remoteUser to be resolved from its userName.
	 * 
	 */
	public class UsersModel
	{
		private var _localUserName:String;
		private var _localUser:User;
//		private var _remoteUserNames:Vector.<String> = new Vector.<String>;
		private var _remoteUsers:HashMap = new HashMap;
		
//		private var _usersDatabaseService:UserDatabaseService;
		private var _usersHealthRecordService:UsersHealthRecordService;
		private var _healthRecordService:CommonHealthRecordService;
		private var _remoteUsersPopulated:Boolean;
		
		public function UsersModel(settings:Settings, healthRecordService:CommonHealthRecordService)
		{		
			_localUserName = settings.userName;
			
//			_usersDatabaseService = new UserDatabaseService(this);
			_usersHealthRecordService = new UsersHealthRecordService(this, healthRecordService.consumerKey, healthRecordService.consumerSecret, healthRecordService.baseURL);
			_usersHealthRecordService.copyLoginResults(healthRecordService);
			_healthRecordService = healthRecordService;
			
//			_usersDatabaseService.addEventListener(UserDatabaseEvent.COMPLETE, userDatabaseService_completeHandler);
			_usersHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, usersHealthRecordService_completeHandler);
		}
		
		public function get remoteUsersPopulated():Boolean
		{
			return _remoteUsersPopulated;
		}

		public function get usersHealthRecordService():UsersHealthRecordService
		{
			return _usersHealthRecordService;
		}

		private function usersHealthRecordService_completeHandler(event:HealthRecordServiceEvent):void
		{
//			_healthRecordService.loadAllDemographics(this);
//			_healthRecordService.loadAllContact(this);
//			_healthRecordService.loadAllProblems(this);
			_remoteUsersPopulated = true;
		}
		
		public function addRemoteUser(remoteUser:User):void
		{
			if (remoteUser == null)
				throw new ArgumentError("remoteUser must not be null");
			if (remoteUser.accountId == null)
				throw new ArgumentError("remoteUser.accountId must not be null");
			
			if (!_remoteUsers.keys.contains(remoteUser.accountId))
				_remoteUsers[remoteUser.accountId] = remoteUser;
		}
		
//		public function retrieveUser(userName:String):User
//		{
//			if (userName == _localUserName)
//			{
//				return _localUser;
//			}
//			else
//			{
//				var location:Number = _remoteUserNames.indexOf(userName);
//				if (location != -1)
//				{
//					var remoteUser:User = _remoteUsers[location];
//					
//					return remoteUser;
//				}
//				return null;
//			}
//		}
		
//		public function get localUserName():String
//		{
//			return _localUserName;
//		}
		
		public function get localUser():User
		{
			return _localUser;
		}
		
		public function set localUser(value:User):void
		{
			_localUser = value;
		}

//		public function get remoteUserNames():Vector.<String>
//		{
//			return _remoteUserNames;
//		}
		
		[Bindable]
		public function get remoteUsers():HashMap
		{
			return _remoteUsers;
		}
		
		public function set remoteUsers(value:HashMap):void
		{
			throw new IllegalOperationError("remoteUsers is read-only; property set only exists to enable data binding");
		}
		
		public function get healthRecordService():CommonHealthRecordService
		{
			return _healthRecordService;
		}
		
		public function retrieveUserByAccountId(accountId:String):User
		{
			if (accountId == _localUser.accountId)
			{
				return _localUser;
			}
			else
			{
				if (_remoteUsers.keys.contains(accountId))
					return _remoteUsers[accountId];
				else
					return null;
			}
		}
	}
}