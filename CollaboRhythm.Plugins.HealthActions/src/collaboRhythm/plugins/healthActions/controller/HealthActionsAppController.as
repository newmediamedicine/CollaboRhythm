package collaboRhythm.plugins.healthActions.controller
{
	import collaboRhythm.plugins.healthActions.model.HealthActionsModel;
	import collaboRhythm.plugins.healthActions.view.HealthActionsButtonWidgetView;
	import collaboRhythm.plugins.healthActions.view.HealthActionsFullView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.AppEvent;

	import mx.core.UIComponent;

	import spark.components.ViewNavigator;

	public class HealthActionsAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "HealthActions";

		private var _widgetView:HealthActionsButtonWidgetView;
		private var _fullView:HealthActionsFullView;

		private var _healthActionsModel:HealthActionsModel;

		public function HealthActionsAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		override public function initialize():void
		{
			super.initialize();
			if (!_fullView && _fullContainer)
			{
				createFullView();
				prepareFullView();
			}
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new HealthActionsButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new HealthActionsFullView();
			return _fullView;
		}

		override public function reloadUserData():void
		{
			removeUserData();

			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, healthActionsModel);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.init(this, healthActionsModel);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get healthActionsModel():HealthActionsModel
		{
			if (!_healthActionsModel)
			{
				_healthActionsModel = new HealthActionsModel(_componentContainer, _activeRecordAccount.primaryRecord,
						_activeRecordAccount.accountId, _navigationProxy);
			}
			return _healthActionsModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as HealthActionsButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as HealthActionsFullView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return true;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		protected override function removeUserData():void
		{
			_healthActionsModel = null;
		}

		public function get viewNavigator():ViewNavigator
		{
			return _viewNavigator
		}
	}
}
