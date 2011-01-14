package collaboRhythm.workstation.apps.medications.controller
{
	import collaboRhythm.workstation.apps.medications.view.MedicationsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;

	import flash.display.DisplayObject;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	public class MedicationsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:MedicationsWidgetView;
//		private var _fullView:MedicationsTimelineFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;			
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as MedicationsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as MedicationsTimelineFullView;
//		}
		
		public function MedicationsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}

		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:MedicationsWidgetView = new MedicationsWidgetView();
			if (_user != null)
				newWidgetView.model = _user.medicationsModel;
			return newWidgetView;
		}
		
//		protected override function createFullView():UIComponent
//		{
//			var newFullView:MedicationsTimelineFullView = new MedicationsTimelineFullView();
//			if (_user != null)
//				newFullView.initializeControllerModel(null, _user.medicationsModel);
//			return newFullView;
//		}

		public override function initialize():void
		{
			super.initialize();
			if (!_user.medicationsModel.initialized && !_user.medicationsModel.isLoading)
			{
				_healthRecordService.loadMedications(_user);
			}
			(_widgetView as MedicationsWidgetView).model = _user.medicationsModel;
		}
		
		public override function close():void
		{
			super.close();
		}
	}
}