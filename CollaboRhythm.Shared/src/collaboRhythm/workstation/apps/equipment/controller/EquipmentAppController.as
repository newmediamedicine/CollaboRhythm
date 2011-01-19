package collaboRhythm.workstation.apps.equipment.controller
{
//	import collaboRhythm.workstation.apps.equipment.view.EquipmentFullView;
	import collaboRhythm.workstation.apps.equipment.view.EquipmentWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class EquipmentAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:EquipmentWidgetView;
//		private var _fullView:EquipmentFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as EquipmentWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as EquipmentFullView;
//		}
		
		public function EquipmentAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new EquipmentWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new EquipmentFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.equipment == null)
//			{
//				_healthRecordService.loadEquipment(_sharedUser);
//			}
//			(_widgetView as EquipmentWidgetView).model = _sharedUser.equipment;
//			_fullView.model = _sharedUser.equipment;
		}
	}
}