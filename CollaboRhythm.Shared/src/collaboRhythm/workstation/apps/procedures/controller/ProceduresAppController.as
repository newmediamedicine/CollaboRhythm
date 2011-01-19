package collaboRhythm.workstation.apps.procedures.controller
{
//	import collaboRhythm.workstation.apps.procedures.view.ProceduresFullView;
	import collaboRhythm.workstation.apps.procedures.view.ProceduresWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ProceduresAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ProceduresWidgetView;
//		private var _fullView:ProceduresFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ProceduresWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as ProceduresFullView;
//		}
		
		public function ProceduresAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new ProceduresWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new ProceduresFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.procedures == null)
//			{
//				_healthRecordService.loadProcedures(_sharedUser);
//			}
//			(_widgetView as ProceduresWidgetView).model = _sharedUser.procedures;
//			_fullView.model = _sharedUser.procedures;
		}
	}
}