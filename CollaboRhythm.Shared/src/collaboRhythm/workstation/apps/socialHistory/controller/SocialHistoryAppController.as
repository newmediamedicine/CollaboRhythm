package collaboRhythm.workstation.apps.socialHistory.controller
{
//	import collaboRhythm.workstation.apps.socialHistory.view.SocialHistoryFullView;
	import collaboRhythm.workstation.apps.socialHistory.view.SocialHistoryWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class SocialHistoryAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:SocialHistoryWidgetView;
//		private var _fullView:SocialHistoryFullView;
				
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as SocialHistoryWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as SocialHistoryFullView;
//		}
		
		public function SocialHistoryAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new SocialHistoryWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new SocialHistoryFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.socialHistory == null)
//			{
//				_healthRecordService.loadSocialHistory(_sharedUser);
//			}
//			(_widgetView as SocialHistoryWidgetView).model = _sharedUser.socialHistory;
//			_fullView.model = _sharedUser.socialHistory;
		}
	}
}