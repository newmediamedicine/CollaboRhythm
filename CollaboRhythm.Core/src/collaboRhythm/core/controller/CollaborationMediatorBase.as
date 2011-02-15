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
package collaboRhythm.core.controller
{
	import castle.flexbridge.kernel.IKernel;
	
	import collaboRhythm.core.controller.apps.WorkstationAppControllersMediator;
	import collaboRhythm.plugins.problems.model.ProblemsHealthRecordService;
	import collaboRhythm.shared.controller.CollaborationController;
	import collaboRhythm.shared.controller.CollaborationEvent;
	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	public class CollaborationMediatorBase
	{
		protected var _remoteUsersController:RemoteUserController;
		protected var _collaborationController:CollaborationController;
		protected var _appControllersMediator:WorkstationAppControllersMediator;
		protected var _demographicsController:DemographicsController;
		protected var _kernel:IKernel;
		protected var logger:ILogger;
		protected var settings:Settings;
		protected var healthRecordService:CommonHealthRecordService;
		protected var usersModel:UsersModel;
		protected var _subjectUser:User;

		public function get subjectUser():User
		{
			return _subjectUser;
		}

		public function get appControllersMediator():WorkstationAppControllersMediator
		{
			return _appControllersMediator;
		}

		protected function get applicationController():ApplicationControllerBase
		{
			throw Error("virtual function must be overriden in subclass");
		}
		
		public function CollaborationMediatorBase()
		{
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_kernel = WorkstationKernel.instance;
			
			settings = applicationController.settings;
			
			if (settings.isPatientMode)
				prepareForPatientMode();
			
			healthRecordService = new CommonHealthRecordService(settings.chromeConsumerKey, settings.chromeConsumerSecret, settings.indivoServerBaseURL);
			
			healthRecordService.addEventListener(HealthRecordServiceEvent.LOGIN_COMPLETE, loginCompleteHandler);
			healthRecordService.login(settings.chromeConsumerKey, settings.chromeConsumerSecret, settings.userName, settings.password);
		}
		
		protected function prepareForPatientMode():void
		{
			// override in subclasses
		}
		
		private function loginCompleteHandler(event:HealthRecordServiceEvent):void
		{
			usersModel = new UsersModel(settings, healthRecordService);
			usersModel.usersHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, usersHealthRecordService_completeHandler);
			usersModel.usersHealthRecordService.addEventListener(HealthRecordServiceEvent.UPDATE, usersHealthRecordService_updateHandler);
			usersModel.usersHealthRecordService.populateRemoteUsers();
		}
		
		private function usersHealthRecordService_completeHandler(event:HealthRecordServiceEvent):void
		{
			loadUserData();
		}
		
		private function usersHealthRecordService_updateHandler(event:HealthRecordServiceEvent):void
		{
			var user:User = event.user;
			if (user != null)
			{
				healthRecordService.loadDemographics(user);
				healthRecordService.loadContact(user);

				var problemsHealthRecordService:ProblemsHealthRecordService = new ProblemsHealthRecordService(healthRecordService.consumerKey, healthRecordService.consumerSecret, healthRecordService.baseURL);
				problemsHealthRecordService.copyLoginResults(healthRecordService);
				problemsHealthRecordService.loadProblems(user);
			}
			
			if (_remoteUsersController)
				_remoteUsersController.updateView();
		}
		
		private function loadUserData():void
		{
			if (healthRecordService.isLoginComplete && usersModel.remoteUsersPopulated && _collaborationController == null)
			{
				_collaborationController = new CollaborationController(applicationController.collaborationRoomView, usersModel, settings);
				logger.info("CollaborationController created");
				
				initializeControllersForUser();
				
				_appControllersMediator = new WorkstationAppControllersMediator(
					applicationController.widgetsContainer,
					applicationController.scheduleWidgetContainer,
					applicationController.fullContainer,
					settings,
					healthRecordService,
					_collaborationController.collaborationModel.collaborationRoomNetConnectionService,
					applicationController.componentContainer
				);
				
				healthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, healthRecordService_completeHandler);
				healthRecordService.loadAllDemographics(usersModel);
				healthRecordService.loadAllContact(usersModel);
				
				// problems are needed for the users list
				var problemsHealthRecordService:ProblemsHealthRecordService = new ProblemsHealthRecordService(healthRecordService.consumerKey, healthRecordService.consumerSecret, healthRecordService.baseURL);
				problemsHealthRecordService.copyLoginResults(healthRecordService);
				problemsHealthRecordService.loadAllProblems(usersModel);
			}
		}
		
		protected function initializeControllersForUser():void
		{
		}
		
		private function healthRecordService_completeHandler(event:HealthRecordServiceEvent):void
		{
			if (_remoteUsersController)
			{
				_remoteUsersController.sortView();
			}
			
			if (settings.isPatientMode)
			{
				openRecord(usersModel.localUser);
			}
		}
		
		public function collaborateWithUserHandler(event:CollaborationEvent):void
		{
			var subjectUser:User = event.remoteUser;
			_collaborationController.collaborateWithUserHandler(subjectUser);
		}
		
		public function localUserJoinedCollaborationRoomAnimationCompleteHandler(event:CollaborationEvent):void
		{
		}
		
		public function changeDemoDate():void
		{
			var user:User = _demographicsController.remoteUser;
			if (user != null)
			{
				_appControllersMediator.reloadUserData(user);
			}
			
			//			user.demographics.dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, PropertyChangeEventKind.UPDATE, "age", 0, user.demographics.age));
			user.demographics.dispatchAgeChangeEvent();
		}
		
		public function cancelAllCollaborations():void
		{
			if (_collaborationController != null)
			{
				_collaborationController.exitCollaborationLobby();
				_collaborationController.closeCollaborationRoom();
			}
		}
		
		public function openRecordHandler(event:CollaborationEvent):void
		{
			var user:User = event.remoteUser;
			openRecord(user);
		}
		
		public function openRecord(user:User):void
		{
			// make sure we have a valid record
			if (user.recordId != null && user.contact.givenName != null)
			{
				// make sure the user/record isn't already open
				if (subjectUser != user)
				{
					_subjectUser = user;
					
					openValidatedUser(user);
				}
			}
		}
		
		protected function openValidatedUser(user:User):void
		{
		}
		
		public function closeRecord():void
		{
			appControllersMediator.closeApps();
			_subjectUser = null;
		}
		
		public function reloadPlugins():void
		{
			applicationController.reloadPlugins();
		}
	}
}