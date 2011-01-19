package collaboRhythm.workstation.apps.imaging.controller
{
//	import collaboRhythm.workstation.apps.imaging.view.ImagingFullView;
	import collaboRhythm.workstation.apps.imaging.view.ImagingWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ImagingAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ImagingWidgetView;
//		private var _fullView:ImagingFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ImagingWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as ImagingFullView;
//		}
		
		public function ImagingAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new ImagingWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new ImagingFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.imaging == null)
//			{
//				_healthRecordService.loadImaging(_sharedUser);
//			}
//			(_widgetView as ImagingWidgetView).model = _sharedUser.imaging;
//			_fullView.model = _sharedUser.imaging;
		}
	}
}