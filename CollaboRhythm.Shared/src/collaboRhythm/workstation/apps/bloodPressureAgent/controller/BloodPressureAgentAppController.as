package collaboRhythm.workstation.apps.bloodPressureAgent.controller
{
	import collaboRhythm.workstation.apps.bloodPressureAgent.view.BloodPressureAgentFullView;
	import collaboRhythm.workstation.apps.bloodPressureAgent.view.BloodPressureAgentWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	import collaboRhythm.workstation.controller.apps.WorkstationAppEvent;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	public class BloodPressureAgentAppController extends WorkstationAppControllerBase
	{
		private var _bloodPressureFullViewController:BloodPressureAgentFullViewController;
		private var _widgetView:BloodPressureAgentWidgetView;
		private var _fullView:BloodPressureAgentFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as BloodPressureAgentWidgetView;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as BloodPressureAgentFullView;
		}
		
		public function BloodPressureAgentAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:BloodPressureAgentWidgetView = new BloodPressureAgentWidgetView();
//			if (_user != null)
//				newWidgetView.initializeClock(_user.scheduleModel);
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:BloodPressureAgentFullView = new BloodPressureAgentFullView();
//			if (_user != null)
//				newFullView.initializeControllerModel(null, _user.scheduleModel);
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
//			(_widgetView as BloodPressureWidgetView).initializeClock(_user.scheduleModel);
			_bloodPressureFullViewController = new BloodPressureAgentFullViewController(_fullView as BloodPressureAgentFullView);
			_bloodPressureFullViewController.addEventListener(WorkstationAppEvent.SHOW_FULL_VIEW, launchBloodPressureFullViewHandler);
			_fullView.initializeControllerModel(_bloodPressureFullViewController, user.bloodPressureModel);
		}
		
		private function launchBloodPressureFullViewHandler(event:WorkstationAppEvent):void
		{
			dispatchEvent(new WorkstationAppEvent(WorkstationAppEvent.SHOW_FULL_VIEW, null, null, event.applicationName));
		}
		
		public override function close():void
		{
			super.close();
		}
		
		override public function reloadUserData():void
		{
			_fullView.refresh();
		}
	}
}