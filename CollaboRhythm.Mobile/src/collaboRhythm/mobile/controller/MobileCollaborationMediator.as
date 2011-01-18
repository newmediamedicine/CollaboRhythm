package collaboRhythm.mobile.controller
{
	import collaboRhythm.workstation.apps.bloodPressure.controller.BloodPressureAppController;
	import collaboRhythm.workstation.apps.problems.controller.ProblemsAppController;
	import collaboRhythm.workstation.apps.schedule.controller.ScheduleAppController;
	import collaboRhythm.workstation.controller.ApplicationControllerBase;
	import collaboRhythm.workstation.controller.CollaborationMediatorBase;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.workstation.model.User;
	
	import flash.utils.flash_proxy;

	public class MobileCollaborationMediator extends CollaborationMediatorBase
	{
		private var _mobileApplicationController:MobileApplicationController;
	
		protected override function get applicationController():ApplicationControllerBase
		{
			return _mobileApplicationController;
		}
		
		public function MobileCollaborationMediator(mobileApplicationController:MobileApplicationController)
		{
			_mobileApplicationController = mobileApplicationController;
			super();
		}
		
		protected override function prepareForPatientMode():void
		{
		}
		
		protected override function openValidatedUser(user:User):void
		{
			_appControllersMediator.initializeForUser(user);
			var app:WorkstationAppControllerBase;
			app = _appControllersMediator.createApp(ScheduleAppController, "Schedule");
			app = _appControllersMediator.createApp(BloodPressureAppController, "Blood Pressure");
			app = _appControllersMediator.createApp(ProblemsAppController, "Problems");
			
			_mobileApplicationController.initializeActiveView();
		}
	}
}