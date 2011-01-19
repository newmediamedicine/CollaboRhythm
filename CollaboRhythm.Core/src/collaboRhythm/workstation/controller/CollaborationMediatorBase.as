package collaboRhythm.workstation.controller
{
	import castle.flexbridge.kernel.IKernel;
	
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllersMediator;
	import collaboRhythm.workstation.model.*;
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	import collaboRhythm.workstation.view.WorkstationWindow;
	
	import flash.display.Screen;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IVisualElementContainer;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.states.AddChild;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	
	import spark.components.VideoPlayer;
	
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
		protected var subjectUser:User;

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
				healthRecordService.loadProblems(user);
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
					_collaborationController.collaborationModel.collaborationRoomNetConnectionService);
				
				healthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, healthRecordService_completeHandler);
				healthRecordService.loadAllDemographics(usersModel);
				healthRecordService.loadAllContact(usersModel);
				healthRecordService.loadAllProblems(usersModel);
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
					subjectUser = user;
					
					openValidatedUser(user);
				}
			}
		}
		
		protected function openValidatedUser(user:User):void
		{
		}
	}
}