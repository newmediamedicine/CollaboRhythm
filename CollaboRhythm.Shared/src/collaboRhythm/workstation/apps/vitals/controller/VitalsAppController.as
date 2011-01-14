package collaboRhythm.workstation.apps.vitals.controller
{
//	import collaboRhythm.workstation.apps.vitals.view.VitalsFullView;
	import collaboRhythm.workstation.apps.vitals.view.VitalsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class VitalsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:VitalsWidgetView;
//		private var _fullView:VitalsFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as VitalsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as VitalsFullView;
//		}
		
		public function VitalsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new VitalsWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new VitalsFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.vitals == null)
//			{
//				_healthRecordService.loadVitals(_sharedUser);
//			}
//			(_widgetView as VitalsWidgetView).model = _sharedUser.vitals;
//			_fullView.model = _sharedUser.vitals;
		}
	}
}