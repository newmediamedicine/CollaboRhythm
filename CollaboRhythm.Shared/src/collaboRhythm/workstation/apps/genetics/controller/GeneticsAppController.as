package collaboRhythm.workstation.apps.genetics.controller
{
//	import collaboRhythm.workstation.apps.genetics.view.GeneticsFullView;
	import collaboRhythm.workstation.apps.genetics.view.GeneticsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class GeneticsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:GeneticsWidgetView;
//		private var _fullView:GeneticsFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as GeneticsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as GeneticsFullView;
//		}
		
		public function GeneticsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new GeneticsWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new GeneticsFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.genetics == null)
//			{
//				_healthRecordService.loadGenetics(_sharedUser);
//			}
//			(_widgetView as GeneticsWidgetView).model = _sharedUser.genetics;
//			_fullView.model = _sharedUser.genetics;
		}
	}
}