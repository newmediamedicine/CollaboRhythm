package collaboRhythm.plugins.microhponeExamples.controller
{
	import collaboRhythm.plugins.microhponeExamples.model.MicrophoneExamplesModel;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import collaboRhythm.plugins.microhponeExamples.view.MicrophoneExamplesWidgetView;
	
	public class MicrophoneExamplesAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:MicrophoneExamplesWidgetView;
//		private var _fullView:MicrophoneExamplesFullView;
		private var _model:MicrophoneExamplesModel = new MicrophoneExamplesModel();
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as MicrophoneExamplesWidgetView;
		}
		
		public function MicrophoneExamplesAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:MicrophoneExamplesWidgetView = new MicrophoneExamplesWidgetView();
			newWidgetView.model = _model;
			return newWidgetView;
		}
	}
}