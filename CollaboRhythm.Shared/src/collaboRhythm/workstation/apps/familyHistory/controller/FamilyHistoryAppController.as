package collaboRhythm.workstation.apps.familyHistory.controller
{
//	import collaboRhythm.workstation.apps.familyHistory.view.FamilyHistoryFullView;
	import collaboRhythm.workstation.apps.familyHistory.view.FamilyHistoryWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class FamilyHistoryAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:FamilyHistoryWidgetView;
//		private var _fullView:FamilyHistoryFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as FamilyHistoryWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as FamilyHistoryFullView;
//		}
		
		public function FamilyHistoryAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new FamilyHistoryWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new FamilyHistoryFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.familyHistory == null)
//			{
//				_healthRecordService.loadFamilyHistory(_sharedUser);
//			}
//			(_widgetView as FamilyHistoryWidgetView).model = _sharedUser.familyHistory;
//			_fullView.model = _sharedUser.familyHistory;
		}
	}
}