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
 package collaboRhythm.workstation.controller
{
	import collaboRhythm.shared.model.*;
	import collaboRhythm.workstation.view.WorkstationWindow;
	
	import flash.display.Screen;
	import flash.filesystem.File;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import spark.components.VideoPlayer;
	import collaboRhythm.core.controller.ApplicationControllerBase;
	import collaboRhythm.core.controller.CollaborationMediatorBase;
	import collaboRhythm.core.controller.DemographicsController;
	import collaboRhythm.core.controller.RemoteUserController;
	import collaboRhythm.core.controller.WorkstationCommandBarController;
	import collaboRhythm.shared.controller.CollaborationEvent;
	
	/**
	 * The collaboration mediator for the workstation (desktop) application. 
	 * @author sgilroy
	 * 
	 */
	public class WorkstationCollaborationMediator extends CollaborationMediatorBase
	{
		private var _workstationController:WorkstationApplicationController;
		private var _workstationCommandBarController:WorkstationCommandBarController;
		private var videoWindows:Vector.<WorkstationWindow>;
		
		protected override function get applicationController():ApplicationControllerBase
		{
			return _workstationController;
		}
		
		public function WorkstationCollaborationMediator(workstationController:WorkstationApplicationController)
		{
			_workstationController = workstationController;
			super();
		}
		
		protected override function prepareForPatientMode():void
		{
			_workstationController.remoteUsersView.hide(true);
		}
		
		protected override function openValidatedUser(user:User):void
		{
			//			_workstationController.topSpace.enableContainerLayout();
			_appControllersMediator.startApps(user);
			_remoteUsersController.hide();
			_workstationCommandBarController.remoteUser = user;
			_workstationCommandBarController.show();
			_demographicsController.remoteUser = user;
			_demographicsController.show();
			
			createDemoVideoWindows(user);
			
			//			var commonClock:ClockView = new ClockView();
			//			commonClock.initializeClock(user.medicationsModel);
			//			_workstationController.topSpace.widgetBar.addElement(commonClock);
			
			_collaborationController.collaborationRoomView.addEventListener(CollaborationEvent.LOCAL_USER_JOINED_COLLABORATION_ROOM_ANIMATION_COMPLETE, localUserJoinedCollaborationRoomAnimationCompleteHandler);
		}
		
		protected override function initializeControllersForUser():void
		{
			_remoteUsersController = new RemoteUserController(applicationController.remoteUsersView, usersModel);
			logger.info("RemoteUserController created");
			
			_workstationCommandBarController = new WorkstationCommandBarController(_workstationController.workstationCommandBarView, usersModel, settings);

			// moved call to initialize _appsControllerMediator
			
			_demographicsController = new DemographicsController(_workstationController.fullContainer);
			
			_remoteUsersController.addEventListener(CollaborationEvent.OPEN_RECORD, openRecordHandler);
			
			_workstationCommandBarController.addEventListener(CollaborationEvent.COLLABORATE_WITH_USER, collaborateWithUserHandler);
			_workstationCommandBarController.addEventListener(CollaborationEvent.CLOSE_RECORD, closeRecordHandler);
			_workstationCommandBarController.addEventListener(CollaborationEvent.RECORD_CLOSED, recordClosedHandler);
		}
		
		public override function localUserJoinedCollaborationRoomAnimationCompleteHandler(event:CollaborationEvent):void
		{
			if (_collaborationController.collaborationModel.subjectUser != _workstationCommandBarController.remoteUser)
			{
				switchRecords(_collaborationController.collaborationModel.subjectUser);
			}
		}

		private function closeVideoWindows():void
		{
			if (videoWindows != null && videoWindows.length > 0)
			{
				_workstationController.resetingWindows = true;
				while (videoWindows.length > 0)
				{
					var window:WorkstationWindow = videoWindows.pop();
					window.close();
					
					if (_workstationController.windows[_workstationController.windows.length - 1] == window)
					{
						_workstationController.windows.pop();
					}
					else
					{
						throw new Error("Expected window not found in _workstationController.windows");
					}
					
					//					_workstationController.windows = _workstationController.windows.filter(excludeWindow, window);
					//					for (var i:int = 0; i < _workstationController.windows.length; i++)
					//					{
					//						if (_workstationController.windows[i] == window)
					//						{
					//						}
					//					}
				}
				_workstationController.resetingWindows = false;
			}
		}

		private function createDemoVideoWindows(user:User):void
		{
			closeVideoWindows();
			
			if (Screen.screens.length > 1)
			{
				var userVideoDirectory:File = File.applicationDirectory.resolvePath("resources").resolvePath("video").resolvePath(user.contact.userName);
				if (userVideoDirectory.exists)
				{
					videoWindows = new Vector.<WorkstationWindow>();
					var files:Array = userVideoDirectory.getDirectoryListing();
					
					var screenIndex:int = 0;
					
					for each (var videoFile:File in files)
					{
						var screen:Screen = Screen.screens[screenIndex];
						
						var window:WorkstationWindow = _workstationController.createWorkstationWindow();
						window.initializeForScreen(screen);
						_workstationController.initializeWindowCommon(window);
						videoWindows.push(window);

						var videoPlayer:VideoPlayer = new VideoPlayer();
						
						window.addSpace(videoPlayer);
						
						videoPlayer.percentWidth = 100;
						videoPlayer.percentHeight = 100;
						videoPlayer.loop = true;
						videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, videoPlayer_mediaPlayerStateChange);
						videoPlayer.source = videoFile.nativePath;

						// TODO: ensure that the video windows are placed on empty screens
						screenIndex += 2;
					}
				}
			}
		}
		
		private function videoPlayer_mediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{
			if (event.state == "ready")
			{
				var videoPlayer:VideoPlayer = event.currentTarget as VideoPlayer;
				if (videoPlayer != null)
				{
					videoPlayer.muted = true;
					videoPlayer.play();
				}
			}
		}
		
		private function closeRecordHandler(event:CollaborationEvent):void
		{
			closeRecord();
		}
		
		public override function closeRecord():void
		{
			super.closeRecord();
			
			// TODO: add support for closing/opening records in patient mode (or some mode for families/friends).
			// This will probably require separating remote users into two lists: those who have access to the local user's record and those who the local user has access to.  
			
			_subjectUser = null;
			closeVideoWindows();
			_appControllersMediator.closeApps();
			_remoteUsersController.show();
			_workstationCommandBarController.hide();
			_demographicsController.hide();
		}
		
		public function switchRecords(user:User):void
		{
//			_appControllersMediator.closeApps();
//			_appControllersMediator.startApps(user);
//			_workstationCommandBarController.remoteUser = user;
//			_demographicsController.remoteUser = user;
			closeRecord();
			openRecord(user);
		}
		
		public function recordClosedHandler(event:CollaborationEvent):void
		{
			_workstationCommandBarController.remoteUser = null;
		}
		
	}
}