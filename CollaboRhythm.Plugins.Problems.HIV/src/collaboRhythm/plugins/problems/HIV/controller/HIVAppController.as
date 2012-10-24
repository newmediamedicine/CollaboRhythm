package collaboRhythm.plugins.problems.HIV.controller
{
	import collaboRhythm.plugins.problems.HIV.model.HIVSimulationModel;
	import collaboRhythm.plugins.problems.HIV.view.HIVSimulationButtonWidgetView;
	import collaboRhythm.plugins.problems.HIV.view.HIVSimulationView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;

	import mx.core.UIComponent;

	public class HIVAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "HIV";

		private var _widgetView:HIVSimulationButtonWidgetView;
		private var _hivSimulationModel:HIVSimulationModel;

		private var _recordIsLoadingChangeWatcher:ChangeWatcher;

		public function HIVAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			if (activeRecordAccount && activeRecordAccount.primaryRecord)
				_recordIsLoadingChangeWatcher = BindingUtils.bindSetter(record_isLoadingHandler,
						activeRecordAccount.primaryRecord, "isLoading");
		}

		private function record_isLoadingHandler(isLoading:Boolean):void
		{
			if (!isLoading)
			{
				if (_recordIsLoadingChangeWatcher)
				{
					_recordIsLoadingChangeWatcher.unwatch();
					_recordIsLoadingChangeWatcher = null;
				}

				createAndPrepareWidgetView();
				showWidget();
			}
		}

		override public function initialize():void
		{
			super.initialize();
			initializeHIVSimulationModel();

			updateWidgetViewModel();
		}

		private function initializeHIVSimulationModel():void
		{
			if (_hivSimulationModel == null)
			{
				_hivSimulationModel = new HIVSimulationModel(_activeRecordAccount);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		override protected function createWidgetView():UIComponent
		{
			initializeHIVSimulationModel();

			// Only make the widget view if it is appropriate for this record
			if (_hivSimulationModel && _hivSimulationModel.recordContainsHivMedication)
				_widgetView = new HIVSimulationButtonWidgetView();
			else
				_widgetView = null;

			return _widgetView
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, _hivSimulationModel);
			}
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as HIVSimulationButtonWidgetView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return false;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		override public function reloadUserData():void
		{
			removeUserData();

			initializeHIVSimulationModel();
			super.reloadUserData();
		}

		override protected function removeUserData():void
		{
			_hivSimulationModel = null;
		}

		public function showHIVSimulationView():void
		{
			_viewNavigator.pushView(HIVSimulationView, _hivSimulationModel);
		}
	}
}
