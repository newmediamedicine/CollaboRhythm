package collaboRhythm.plugins.healthCharts.controller
{
	import collaboRhythm.plugins.healthCharts.view.HealthChartsButtonWidgetView;
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;

	import spark.components.View;

	import spark.components.ViewNavigator;

	public class HealthChartsAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Health Charts";

		private var _widgetView:HealthChartsButtonWidgetView;
		private var _fullView:SynchronizedHealthCharts;
		private var _healthChartsModel:HealthChartsModel;

		public function HealthChartsAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
			cacheFullView = true;
			createFullViewOnInitialize = true;
		}

		override public function initialize():void
		{
			super.initialize();
			if (!_fullView && _fullContainer)
			{
				createFullView();
				prepareFullView();
			}
			doPrecreationForFullView();
		}

		protected override function listenForModelInitialized():void
		{
			if (_activeRecordAccount.primaryRecord.healthChartsModel.isInitialized)
			{
				listenForFullViewUpdateComplete();
			}
			else
			{
				_activeRecordAccount.primaryRecord.healthChartsModel.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
						model_propertyChangeHandler,
						false, 0, true);
			}
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "isInitialized" &&
					_activeRecordAccount.primaryRecord.healthChartsModel.isInitialized)
			{
				_activeRecordAccount.primaryRecord.healthChartsModel.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
						model_propertyChangeHandler);
				listenForFullViewUpdateComplete();
			}
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new HealthChartsButtonWidgetView();
			return _widgetView
		}

		override protected function createFullView():UIComponent
		{
			_fullView = new SynchronizedHealthCharts();
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
				_widgetView.init(this, healthChartsModel);
			}
		}

		override protected function updateFullViewModel():void
		{
			super.updateFullViewModel();

			if (_fullView)
			{
				_fullView.model = healthChartsModel;
				_fullView.modality = modality;
				_fullView.componentContainer  = _componentContainer;
				_fullView.activeAccountId = activeAccount.accountId;
				_fullView.viewNavigator = _viewNavigator;
			}
		}

		override protected function prepareFullViewContainer(view:View):void
		{
			super.prepareFullViewContainer(view);
			if (_fullView)
				_fullView.createActionButtons(view);
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get healthChartsModel():HealthChartsModel
		{
			if (!_healthChartsModel)
			{
				_healthChartsModel = _activeRecordAccount.primaryRecord.healthChartsModel;
			}
			return _healthChartsModel;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as HealthChartsButtonWidgetView;
		}

		override public function get fullView():UIComponent
		{
			return _fullView as UIComponent;
		}

		override public function set fullView(value:UIComponent):void
		{
			_fullView = value as SynchronizedHealthCharts;
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
			_healthChartsModel = null;
		}

		override protected function hideFullViewComplete():void
		{
			super.hideFullViewComplete();
			healthChartsModel.finishedDecision();
		}

		override protected function showFullViewStart():void
		{
			super.showFullViewStart();
			if (fullView)
				_fullView.prepareAllAdherenceGroups();
		}
	}
}
