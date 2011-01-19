package collaboRhythm.workstation.apps.allergies.controller
{
//	import collaboRhythm.workstation.apps.allergies.view.AllergiesFullView;
	import collaboRhythm.workstation.apps.allergies.view.AllergiesWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class AllergiesAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:AllergiesWidgetView;
//		private var _fullView:AllergiesFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as AllergiesWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as AllergiesFullView;
//		}
		
		public function AllergiesAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new AllergiesWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new AllergiesFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.allergies == null)
//			{
//				_healthRecordService.loadAllergies(_sharedUser);
//			}
//			(_widgetView as AllergiesWidgetView).model = _sharedUser.allergies;
//			_fullView.model = _sharedUser.allergies;
		}
	}
}