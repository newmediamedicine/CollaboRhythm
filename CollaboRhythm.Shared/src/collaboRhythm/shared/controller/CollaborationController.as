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
package collaboRhythm.shared.controller
{
	import collaboRhythm.shared.model.CollaborationModel;
	import collaboRhythm.shared.model.Settings;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
	import collaboRhythm.shared.view.CollaborationRoomView;
	
	import flash.events.EventDispatcher;
	import flash.media.Video;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IVisualElementContainer;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import spark.effects.Animate;
	import spark.effects.Move;
	
	/**
	 * Coordinates interaction between the CollaborationModel and CollaborationBarView classes.
	 * Currently, it is possible for the user to accept or cancel (this includes reject) collaborations from the CollaboratingRemoteUserViews in the CollaborationBarView.
	 * The CollaborationBarView listens for the events from the CollaboratingRemoteUserViews and calls functions in this class, which update the collaborationModel and dispatch events for interested observers.
	 * Currently, the CollaborationMediator listens for events from this class.  It also calls functions in this class when collaboration functions are called via the RemoteUserNetConnectionService.
	 * 
	 * @author jom
	 */
	public class CollaborationController extends EventDispatcher
	{
		private var _usersModel:UsersModel;
		private var _collaborationModel:CollaborationModel;
		private var _collaborationRoomView:CollaborationRoomView;
		private var _settings:Settings;
		private var logger:ILogger;
		
		public function CollaborationController(collaborationRoomView:CollaborationRoomView, usersModel:UsersModel, settings:Settings)
		{		
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			logger.info("Creating CollaborationController");
			_settings = settings;
			_usersModel = usersModel;
			logger.info("Creating CollaborationModel");
			_collaborationModel = new CollaborationModel(settings, usersModel);
			_collaborationRoomView = collaborationRoomView;
			if (_settings.isWorkstationMode)
			{
				_collaborationRoomView.y = _collaborationRoomView.y + (-_collaborationRoomView.height);
				_collaborationRoomView.initializeModel(this, _collaborationModel);
				
				_collaborationRoomView.addEventListener(CollaborationEvent.LOCAL_USER_JOINED_COLLABORATION_ROOM_ANIMATION_COMPLETE, localUserJoinedCollaborationRoomAnimationCompleteHandler);
			}
		}

		public function get usersModel():UsersModel
		{
			return _usersModel;
		}
		
		public function get collaborationModel():CollaborationModel
		{
			return _collaborationModel;
		}
		
		public function get collaborationRoomView():CollaborationRoomView
		{
			return _collaborationRoomView;
		}
		
		public function exitCollaborationLobby():void
		{
			_collaborationModel.collaborationLobbyNetConnectionService.exitCollaborationLobby();
		}
		
		public function collaborateWithUserHandler(subjectUser:User):void
		{
			_collaborationModel.creatingUser = _usersModel.localUser;
			_collaborationModel.subjectUser = subjectUser;
			_collaborationModel.collaborationLobbyNetConnectionService.getCollaborationRoomID();
		}
		
		private function localUserJoinedCollaborationRoomAnimationCompleteHandler(event:CollaborationEvent):void
		{
			_collaborationModel.collaborationRoomNetConnectionService.connectLocalUserVideoStream();
		}
		
		public function joinCollaborationRoom():void
		{
			_collaborationModel.collaborationRoomNetConnectionService.joinCollaborationRoom();
		}
		
		public function inviteUserToCollaborationRoom():void
		{
			// TODO: This is a hack that just invites Alice Green, need to make an interface for choosing the remote user that is from the subject user's list
			_collaborationModel.collaborationRoomNetConnectionService.addInvitedUser("agreen");
			_collaborationModel.collaborationLobbyNetConnectionService.sendCollaborationRequest("agreen", _collaborationModel.roomID, _collaborationModel.passWord, _collaborationModel.creatingUser.recordId, _collaborationModel.subjectUser.recordId);
		}
		
		public function closeCollaborationRoom():void
		{
			_collaborationModel.closeCollaborationRoom();
		}
		
		public function hideCollaborationBar():void
		{		
			_collaborationRoomView.hide();
		}
		
		public function showCollaborationBar():void
		{		
			_collaborationRoomView.show();
		}
	}
}