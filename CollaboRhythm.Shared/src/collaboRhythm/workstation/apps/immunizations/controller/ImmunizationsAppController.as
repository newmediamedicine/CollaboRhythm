package collaboRhythm.workstation.apps.immunizations.controller
{
//	import collaboRhythm.workstation.apps.immunizations.view.ImmunizationsFullView;
	import collaboRhythm.workstation.apps.immunizations.view.ImmunizationsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ImmunizationsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ImmunizationsWidgetView;
//		private var _fullView:ImmunizationsFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ImmunizationsWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as ImmunizationsFullView;
//		}
		
		public function ImmunizationsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new ImmunizationsWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new ImmunizationsFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.immunizations == null)
//			{
//				_healthRecordService.loadImmunizations(_sharedUser);
//			}
//			(_widgetView as ImmunizationsWidgetView).model = _sharedUser.immunizations;
//			_fullView.model = _sharedUser.immunizations;
		}
	}
}