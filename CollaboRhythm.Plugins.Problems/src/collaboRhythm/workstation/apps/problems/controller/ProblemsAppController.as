package collaboRhythm.workstation.apps.problems.controller
{
	import collaboRhythm.workstation.apps.problems.view.ProblemsFullView;
	import collaboRhythm.workstation.apps.problems.view.ProblemsWidgetView;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	
	public class ProblemsAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:ProblemsWidgetView;
		private var _fullView:ProblemsFullView;
			
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as ProblemsWidgetView;
		}
		
		public override function get fullView():UIComponent
		{
			return _fullView;
		}
		
		public override function set fullView(value:UIComponent):void
		{
			_fullView = value as ProblemsFullView;
		}

		public function ProblemsAppController(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			super(widgetParentContainer, fullParentContainer);
		}
		
		protected override function createWidgetView():UIComponent
		{
			var newWidgetView:ProblemsWidgetView = new ProblemsWidgetView();
			if (_user != null)
				newWidgetView.model = _user.problemsModel;
			return newWidgetView;
		}
		
		protected override function createFullView():UIComponent
		{
			var newFullView:ProblemsFullView = new ProblemsFullView();
			if (_user != null)
				newFullView.model = _user.problemsModel;
			return newFullView;
		}
		
		public override function initialize():void
		{
			super.initialize();
			if (_user.problemsModel.initialized == false)
			{
				_healthRecordService.loadProblems(_user);
			}
			if (_widgetView)
				(_widgetView as ProblemsWidgetView).model = _user.problemsModel;

			if (_fullView)
				_fullView.model = _user.problemsModel;
		}
	}
}