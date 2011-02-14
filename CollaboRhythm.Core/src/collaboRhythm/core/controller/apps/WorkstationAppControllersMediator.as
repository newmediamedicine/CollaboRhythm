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
package collaboRhythm.core.controller.apps
{
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.workstation.apps.allergies.controller.AllergiesAppController;
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
	import collaboRhythm.workstation.apps.schedule.controller.ScheduleAppController;
	import collaboRhythm.workstation.apps.socialHistory.controller.SocialHistoryAppController;
	import collaboRhythm.workstation.apps.vitals.controller.VitalsAppController;
	import collaboRhythm.workstation.controller.apps.AppControllerInfo;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerFactory;
	import collaboRhythm.workstation.controller.apps.WorkstationAppEvent;
	import collaboRhythm.workstation.model.*;
	
	import com.theory9.data.types.OrderedMap;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

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
		private var _workstationApps:OrderedMap;
		protected var _healthRecordService:CommonHealthRecordService;
		private var _collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService;
		private var _factory:WorkstationAppControllerFactory;
		private var _componentContainer:IComponentContainer;
		
		public function WorkstationAppControllersMediator(
			widgetParentContainer:IVisualElementContainer,
			scheduleWidgetParentContainer:IVisualElementContainer,
			fullParentContainer:IVisualElementContainer,
			settings:Settings,
			healthRecordService:CommonHealthRecordService,
			collabortionNetConnectionService:CollaborationRoomNetConnectionService,
			componentContainer:IComponentContainer
		)
		{
			_widgetParentContainer = widgetParentContainer;
			_scheduleWidgetParentContainer = scheduleWidgetParentContainer;
			_fullParentContainer = fullParentContainer;
			_settings = settings;
			_healthRecordService = healthRecordService;
			_collaborationRoomNetConnectionService = collabortionNetConnectionService;
			_componentContainer = componentContainer;
			
			_collaborationRoomNetConnectionService.netConnection.client.showFullView = showFullView;
		}
		
		protected function get componentContainer():IComponentContainer
		{
			return _componentContainer;
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
		
		public function get workstationApps():OrderedMap
		{
			return _workstationApps;
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
			app = createApp(BloodPressureAgentAppController, "Blood Pressure Agent");
//			app = createApp(BloodPressureAppController, "Blood Pressure Review");
			
			createDynamicApps();
			
//			app = createApp(RichTextAppController);
//			(app as RichTextAppController).text =
//				"Medical Equipment" + 
//				"<p>The quick brown <b>fox jumps over</b> the lazy dogg.</p>"
			
			for each (app in _workstationApps.values())
			{
				app.showWidget();
			}
		}
		
		public function createDynamicApps():void
		{
			var infoArray:Array = componentContainer.resolveAll(AppControllerInfo);
			
			for each (var info:AppControllerInfo in infoArray)
			{
				createApp(info.appControllerClass);
			}
		}
		
		public function initializeForUser(user:User):void
		{
			closeApps();
			
			_workstationApps = new OrderedMap();
			_factory = new WorkstationAppControllerFactory();
			_factory.widgetParentContainer = _widgetParentContainer;
			_factory.fullParentContainer = _fullParentContainer;
			_factory.healthRecordService = _healthRecordService;
			_factory.user = user;
			_factory.collaborationRoomNetConnectionServiceProxy = _collaborationRoomNetConnectionService.createProxy();
		}
		
		public function reloadUserData(user:User):void
		{
			for each (var app:WorkstationAppControllerBase in _workstationApps.values())
			{
				app.reloadUserData();
			}
		}
		
		public function createApp(appClass:Class, appName:String=null):WorkstationAppControllerBase
		{
			var app:WorkstationAppControllerBase = _factory.createApp(appClass, appName);
			appName = app.name;
			app.addEventListener(WorkstationAppEvent.SHOW_FULL_VIEW, showFullViewHandler);
			_workstationApps.addKeyValue(appName, app);
			return app;
		}
		
		private function showFullViewHandler(event:WorkstationAppEvent):void
		{	
			if (event.workstationAppController == null)
			{
				// TODO: use constant instead of magic string
				showFullView(event.applicationName, "local");
			}
			else
			{
				showFullViewResolved(event.workstationAppController, "local");
			}
		}
		
		private function showFullView(applicationName:String, source:String):void
		{
			var workstationAppController:WorkstationAppControllerBase = _workstationApps.getValueByKey(applicationName);
			if (workstationAppController != null)
				showFullViewResolved(workstationAppController, source);
		}
		
		private function showFullViewResolved(workstationAppController:WorkstationAppControllerBase, source:String):void
		{
			for each (var app:WorkstationAppControllerBase in _workstationApps.values())
			{
				if (app != workstationAppController)
					app.hideFullView();
				else
					app.showFullView(null);
			}
			
			(_widgetParentContainer as UIComponent).validateNow();
			
			if (source == "local")
			{
				_collaborationRoomNetConnectionService.netConnection.call("showFullView", null, _collaborationRoomNetConnectionService.localUserName, workstationAppController.name);
			}
		}
		
		public function closeApps():void
		{
			if (_workstationApps != null)
			{
				for each (var app:WorkstationAppControllerBase in _workstationApps.values())
				{
					app.close();
				}
			}
		}
	}
}