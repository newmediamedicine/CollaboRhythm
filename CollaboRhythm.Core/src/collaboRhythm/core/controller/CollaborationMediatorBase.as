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
package collaboRhythm.core.controller
{
	import castle.flexbridge.kernel.IKernel;
	
	import collaboRhythm.core.controller.apps.WorkstationAppControllersMediator;
	import collaboRhythm.plugins.problems.model.ProblemsHealthRecordService;
	import collaboRhythm.shared.controller.CollaborationController;
	import collaboRhythm.shared.controller.CollaborationEvent;
	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.healthRecord.CommonHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import collaboRhythm.shared.model.settings.Settings;

	import collaboRhythm.shared.model.settings.SettingsFileStore;

	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

    // TODO: Completely Eliminate the CollaborationMediatorBase class and all of its subclasses
	public class CollaborationMediatorBase
	{
		protected var _remoteUsersController:RemoteUserController;
		protected var _collaborationController:CollaborationController;
		protected var _appControllersMediator:WorkstationAppControllersMediator;
		protected var _demographicsController:DemographicsController;
		protected var _kernel:IKernel;
		protected var logger:ILogger;
		private var _settings:Settings;
		private var _settingsFileStore:SettingsFileStore;
		protected var healthRecordService:CommonHealthRecordService;
		protected var usersModel:UsersModel;
		protected var _subjectUser:User;
        protected var _account:Account;

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
		
		public function CollaborationMediatorBase(account:Account)
		{
			logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
            _account = account;
			_kernel = WorkstationKernel.instance;
			
			_settings = applicationController.settings;
			_settingsFileStore = applicationController.settingsFileStore;
			
			if (_settings.isPatientMode)
				prepareForPatientMode();
			
//			healthRecordService = new CommonHealthRecordService(_settings.chromeConsumerKey, _settings.chromeConsumerSecret, _settings.indivoServerBaseURL);
//
//			healthRecordService.addEventListener(HealthRecordServiceEvent.LOGIN_COMPLETE, loginCompleteHandler);
//			healthRecordService.login(_settings.chromeConsumerKey, _settings.chromeConsumerSecret, _settings.username, _settings.password);
		}
		
		protected function prepareForPatientMode():void
		{
			// override in subclasses
		}
		
		private function loginCompleteHandler(event:HealthRecordServiceEvent):void
		{
//			logger.info("Login complete.");
//			usersModel = new UsersModel(_settings, healthRecordService);
//			usersModel.usersHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, usersHealthRecordService_completeHandler);
//			usersModel.usersHealthRecordService.addEventListener(HealthRecordServiceEvent.UPDATE, usersHealthRecordService_updateHandler);
//			usersModel.usersHealthRecordService.populateRemoteUsers();
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

				var problemsHealthRecordService:ProblemsHealthRecordService = new ProblemsHealthRecordService(_settings.oauthChromeConsumerKey, _settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _account);
//				problemsHealthRecordService.copyLoginResults(healthRecordService);
				problemsHealthRecordService.loadProblems(user);
			}
			
			if (_remoteUsersController)
				_remoteUsersController.updateView();
		}
		
		private function loadUserData():void
		{
//            TODO: Determine if this check is necessary
//            healthRecordService.isLoginComplete &&
			if (usersModel.remoteUsersPopulated && _collaborationController == null)
			{
//				_collaborationController = new CollaborationController(applicationController.collaborationRoomView, applicationController.recordVideoView, usersModel, _settings);
//				logger.info("CollaborationController created");
//
//				initializeControllersForUser();
//
//				_appControllersMediator = new WorkstationAppControllersMediator(
//					applicationController.widgetsContainer,
//					applicationController.scheduleWidgetContainer,
//					applicationController.fullContainer,
//					_settings,
//					healthRecordService,
//					_collaborationController.collaborationModel.collaborationRoomNetConnectionService,
//					applicationController.componentContainer
//				);
//
//				healthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, healthRecordService_completeHandler);
//				healthRecordService.loadAllDemographics(usersModel);
//				healthRecordService.loadAllContact(usersModel);
//
//				// problems are needed for the users list
//				var problemsHealthRecordService:ProblemsHealthRecordService = new ProblemsHealthRecordService(_settings.oauthChromeConsumerKey, _settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _account);
////				problemsHealthRecordService.copyLoginResults(healthRecordService);
//				problemsHealthRecordService.loadAllProblems(usersModel);
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
			
			if (_settings.isPatientMode)
			{
				openRecord(usersModel.localUser);
			}
		}
		
		public function collaborateWithUserHandler(event:CollaborationEvent):void
		{
			var subjectUser:User = event.remoteUser;
			_collaborationController.collaborateWithUserHandler(subjectUser);
		}
		
		public function recordVideoHandler(event:CollaborationEvent):void
		{
			var user:User = event.remoteUser;
			_collaborationController.recordVideoHandler(subjectUser);
		}
		
		public function localUserJoinedCollaborationRoomAnimationCompleteHandler(event:CollaborationEvent):void
		{
		}
		
		public function changeDemoDate():void
		{
			var user:User = subjectUser;
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

					if (_appControllersMediator)
						_appControllersMediator.updateAppGroupSettings();

					// TODO: update the user settings file with any settings that are not included (or differ from) the default application settings
					if (_settingsFileStore)
						_settingsFileStore.encodeToXML();
				}
			}
		}
		
		protected function openValidatedUser(user:User):void
		{
		}
		
		public function closeRecord():void
		{
			appControllersMediator.closeApps();
			if (_subjectUser)
				_subjectUser.clearDocuments();

			_subjectUser = null;
		}
		
		public function reloadPlugins():void
		{
			applicationController.reloadPlugins();
		}

		public function get settings():Settings
		{
			return _settings;
		}

		public function get settingsFileStore():SettingsFileStore
		{
			return _settingsFileStore;
		}

		public function get currentFullView():String
		{
			return _appControllersMediator ? _appControllersMediator.currentFullView : null;
		}

        public function get account():Account {
            return _account;
        }

        public function set account(value:Account):void {
            _account = value;
        }
    }
}
