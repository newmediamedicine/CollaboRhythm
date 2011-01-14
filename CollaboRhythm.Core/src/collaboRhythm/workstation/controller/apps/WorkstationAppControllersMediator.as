package collaboRhythm.workstation.controller.apps
{
	import collaboRhythm.workstation.apps.allergies.controller.AllergiesAppController;
	import collaboRhythm.workstation.apps.bloodPressure.controller.BloodPressureAppController;
	import collaboRhythm.workstation.apps.bloodPressureAgent.controller.BloodPressureAgentAppController;
	import collaboRhythm.workstation.apps.equipment.controller.EquipmentAppController;
	import collaboRhythm.workstation.apps.familyHistory.controller.FamilyHistoryAppController;
	import collaboRhythm.workstation.apps.genetics.controller.GeneticsAppController;
	import collaboRhythm.workstation.apps.imaging.controller.ImagingAppController;
	import collaboRhythm.workstation.apps.immunizations.controller.ImmunizationsAppController;
	import collaboRhythm.workstation.apps.labs.controller.LabsAppController;
	import collaboRhythm.workstation.apps.medications.controller.MedicationsAppController;
	import collaboRhythm.workstation.apps.problems.controller.ProblemsAppController;
	import collaboRhythm.workstation.apps.procedures.controller.ProceduresAppController;
	import collaboRhythm.workstation.apps.procedures.view.ProceduresWidgetView;
	import collaboRhythm.workstation.apps.schedule.controller.ScheduleAppController;
	import collaboRhythm.workstation.apps.socialHistory.controller.SocialHistoryAppController;
	import collaboRhythm.workstation.apps.vitals.controller.VitalsAppController;
	import collaboRhythm.workstation.model.*;
	
	import flash.net.NetConnection;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	import org.indivo.client.Pha;
	
	import spark.components.Group;
	import spark.components.TileGroup;

	/**
	 * Responsible for creating the collection of workstation apps and adding them to the parent container. 
	 * 
	 */
	public class WorkstationAppControllersMediator
	{
		protected var _widgetParentContainer:IVisualElementContainer;
		protected var _scheduleWidgetParentContainer:IVisualElementContainer;
		private var _fullParentContainer:IVisualElementContainer;
		private var _settings:Settings;
		private var _workstationApps:Vector.<WorkstationAppControllerBase>;
		private var _workstationAppNames:Vector.<String>
		protected var _healthRecordService:CommonHealthRecordService;
		private var _collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService;
		private var _factory:WorkstationAppControllerFactory;
		
		public function WorkstationAppControllersMediator(widgetParentContainer:IVisualElementContainer, scheduleWidgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer, settings:Settings, healthRecordService:CommonHealthRecordService, collabortionNetConnectionService:CollaborationRoomNetConnectionService)
		{
			_widgetParentContainer = widgetParentContainer;
			_scheduleWidgetParentContainer = scheduleWidgetParentContainer;
			_fullParentContainer = fullParentContainer;
			_settings = settings;
			_healthRecordService = healthRecordService;
			_collaborationRoomNetConnectionService = collabortionNetConnectionService;
			
			_collaborationRoomNetConnectionService.netConnection.client.showFullView = showFullView;
		}
		
		public function get fullParentContainer():IVisualElementContainer
		{
			return _fullParentContainer;
		}

		public function set fullParentContainer(value:IVisualElementContainer):void
		{
			_fullParentContainer = value;
			if (_factory)
				_factory.fullParentContainer = value;
		}

		public function get widgetParentContainer():IVisualElementContainer
		{
			return _widgetParentContainer;
		}

		public function set widgetParentContainer(value:IVisualElementContainer):void
		{
			_widgetParentContainer = value;
			if (_factory)
				_factory.widgetParentContainer = value;
		}

		public function startApps(user:User):void
		{
			initializeForUser(user);
			
			var app:WorkstationAppControllerBase;
			
			app = createApp(ProblemsAppController, "Problems");
			app = createApp(MedicationsAppController, "Medications");
			app = createApp(EquipmentAppController, "Equipment");
			app = createApp(ProceduresAppController, "Procedures");
			app = createApp(AllergiesAppController, "Allergies");
			app = createApp(ImmunizationsAppController, "Immunizations");
			app = createApp(GeneticsAppController, "Genetics");
			app = createApp(FamilyHistoryAppController, "Family History");
			app = createApp(SocialHistoryAppController, "Social History");
			app = createApp(VitalsAppController, "Vitals");
			app = createApp(LabsAppController, "Labs");
			app = createApp(ImagingAppController, "Imaging");
			
			_factory.widgetParentContainer = _scheduleWidgetParentContainer;
			app = createApp(ScheduleAppController, "Schedule");
			app = createApp(BloodPressureAgentAppController, "Blood Pressure");
			app = createApp(BloodPressureAppController, "Blood Pressure Review");
			
//			app = createApp(RichTextAppController);
//			(app as RichTextAppController).text =
//				"Medical Equipment" + 
//				"<p>The quick brown <b>fox jumps over</b> the lazy dogg.</p>"
			
			for each (app in _workstationApps)
			{
				app.showWidget();
			}
		}
		
		public function initializeForUser(user:User):void
		{
			closeApps();
			
			_workstationApps = new Vector.<WorkstationAppControllerBase>();
			_workstationAppNames = new Vector.<String>();
			_factory = new WorkstationAppControllerFactory();
			_factory.widgetParentContainer = _widgetParentContainer;
			_factory.fullParentContainer = _fullParentContainer;
			_factory.healthRecordService = _healthRecordService;
			_factory.user = user;
			_factory.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionService.createProxy();
		}
		
		public function reloadUserData(user:User):void
		{
			for each (var app:WorkstationAppControllerBase in _workstationApps)
			{
				app.reloadUserData();
			}
		}
		
		public function createApp(appClass:Class, appName:String):WorkstationAppControllerBase
		{
			var app:WorkstationAppControllerBase = _factory.createApp(appClass);
			app.addEventListener(WorkstationAppEvent.SHOW_FULL_VIEW, showFullViewHandler);
			_workstationApps.push(app);
			_workstationAppNames.push(appName);
			return app;
		}
		
		private function showFullViewHandler(event:WorkstationAppEvent):void
		{	
			//TODO: Fix this hack, did this so that could launch the blood pressure app from the blood pressure agent app
			var applicationName:String;
			if (event.applicationName == null)
			{
				var applicationIndex:Number = _workstationApps.indexOf(event.workstationAppController);
				applicationName = _workstationAppNames[applicationIndex];
			}
			else
			{
				applicationName = event.applicationName;
			}
			showFullView(applicationName, "local");
		}
		
		private function showFullView(applicationName:String, source:String):void
		{
			var applicationIndex:Number = _workstationAppNames.indexOf(applicationName);
			var application:WorkstationAppControllerBase = _workstationApps[applicationIndex];
			
			for each (var app:WorkstationAppControllerBase in _workstationApps)
			{
				if (app != application)
					app.hideFullView();
				else
					app.showFullView(null);
			}
			
			(_widgetParentContainer as UIComponent).validateNow();
			
			
			if (source == "local")
			{
				_collaborationRoomNetConnectionService.netConnection.call("showFullView", null, _collaborationRoomNetConnectionService.localUserName, applicationName);
			}
		}
		
		public function closeApps():void
		{
			if (_workstationApps != null)
			{
				for each (var app:WorkstationAppControllerBase in _workstationApps)
				{
					app.close();
				}
			}
		}
	}
}