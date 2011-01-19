package collaboRhythm.workstation.controller.apps
{
	import collaboRhythm.workstation.view.apps.RichTextWidgetView;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class RichTextAppController extends WorkstationAppControllerBase
	{
		private var _text:String;
		private var _widgetView:RichTextWidgetView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as RichTextWidgetView;
		}
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			_text = value;
			(_widgetView as RichTextWidgetView).text = value;
		}

		public function RichTextAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new RichTextWidgetView();
		}
	}
}