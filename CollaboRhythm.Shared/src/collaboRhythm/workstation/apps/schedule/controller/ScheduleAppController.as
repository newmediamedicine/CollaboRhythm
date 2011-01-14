package collaboRhythm.workstation.apps.schedule.controller
{
	import collaboRhythm.workstation.apps.schedule.view.ScheduleFullView;
	import collaboRhythm.workstation.apps.schedule.view.ScheduleWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ScheduleAppController extends WorkstationAppControllerBase
	{
		private var _scheduleFullViewController:ScheduleFullViewController;
		private var _widgetView:ScheduleWidgetView;
		private var _fullView:ScheduleFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ScheduleWidgetView;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as ScheduleFullView;
		}
		
		public function ScheduleAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:ScheduleWidgetView = new ScheduleWidgetView();
			if (_user != null)
				newWidgetView.initializeClock(_user.scheduleModel);
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ScheduleFullView = new ScheduleFullView();
			if (_user != null)
				newFullView.initializeControllerModel(null, _user.scheduleModel);
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (!_user.medicationsModel.initialized && !_user.medicationsModel.isLoading)
			{
				_healthRecordService.loadMedications(_user);
			}
			(_widgetView as ScheduleWidgetView).initializeClock(_user.scheduleModel);
			_scheduleFullViewController = new ScheduleFullViewController(_user.scheduleModel, _fullView as ScheduleFullView, _collaborationRoomNetConnectionServiceProxy.localUserName, _collaborationRoomNetConnectionServiceProxy);
			_fullView.initializeControllerModel(_scheduleFullViewController, _user.scheduleModel);
		}
		
		public override function close():void
		{
			super.close();
//			for each (var adherenceGroupView:AdherenceGroupView in _fullView.adherenceGroupViews)
//			{
//				adherenceGroupView.unwatchAll();
//				adherenceGroupView.adherenceWindowView.unwatchAll();
//			}
//			for each (var medicationView:MedicationView in _fullView.medicationViews)
//			{
//				medicationView.unwatchAll();
//			}
		}
	}
}