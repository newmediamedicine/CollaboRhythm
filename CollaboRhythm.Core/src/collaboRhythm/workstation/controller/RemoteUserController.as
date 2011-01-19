/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.workstation.controller
{
	import castle.flexbridge.reflection.Void;
	
	import collaboRhythm.workstation.model.Settings;
	import collaboRhythm.workstation.model.User;
	import collaboRhythm.workstation.model.UsersModel;
	import collaboRhythm.workstation.view.RemoteUserView;
	import collaboRhythm.workstation.view.RemoteUsersListView;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElementContainer;
	
	import spark.effects.Move;
	
	/**
	 * 
	 * @author jom
	 * 
	 * Coordinates interaction between the RemoteUserList view and the UserModel classes.
	 * It listens for events from the RemotUserNetConnection class including receiving collaboration requests, cancellations (including rejections), and acceptances. 
	 * It updates the status of the corresponding remote user on receiving these events and dispatches events to interested observers.
	 * Currently, the CollaborationMediator listens for events from this class.  It also calls functions in this class to coordinate activity with the CollaborationController and WorkstationCommandBarController.
	 * This includes sending collaboration requests, cancellations (including rejections), and acceptances.
	 * 
	 */
	public class RemoteUserController extends EventDispatcher
	{
		private var _usersModel:UsersModel;
		private var _remoteUserListView:RemoteUsersListView;
		
		public function RemoteUserController(remoteUserListView:RemoteUsersListView, usersModel:UsersModel)
		{
			_usersModel = usersModel;
			
			_remoteUserListView = remoteUserListView;
			_remoteUserListView.initializeControllerModel(this, _usersModel);
		}	
		
		public function get usersModel():UsersModel
		{
			return _usersModel;
		}
		
		public function get remoteUserListView():RemoteUsersListView
		{
			return _remoteUserListView;
		}
		
		public function openRecord(remoteUser:User):void
		{
			dispatchEvent(new CollaborationEvent(CollaborationEvent.OPEN_RECORD, remoteUser));
		}
		
		public function hide(isImmediately:Boolean=false):void
		{
			_remoteUserListView.hide(isImmediately);
		}
		
		public function show():void
		{
			_remoteUserListView.show();
		}
		
		public function updateView():void
		{
			_remoteUserListView.remoteUserList.dataProvider = _usersModel.remoteUsers.values();
		}
		
		public function sortView():void
		{
			_remoteUserListView.sortListByName();
		}
	}
}