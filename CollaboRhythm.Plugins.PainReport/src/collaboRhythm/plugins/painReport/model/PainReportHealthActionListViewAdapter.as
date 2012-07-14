package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;

	import mx.core.IVisualElement;

	import spark.components.Image;

	public class PainReportHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		public static const HEALTH_ACTION_TYPE:String = "Pain Report";

		private var _healthAction:HealthActionBase;

		private var _model:PainReportHealthActionListViewModel;
		private var _controller:HealthActionListViewControllerBase;

		public function PainReportHealthActionListViewAdapter()
		{
			_healthAction = new HealthActionBase(HEALTH_ACTION_TYPE);

			_model = new PainReportHealthActionListViewModel(null, null);

		}

		public function get healthAction():HealthActionBase
		{
			return _healthAction;
		}

		public function createImage():Image
		{
			return null;
		}

		public function get name():String
		{
			return _healthAction.type;
		}

		public function get description():String
		{
			return "";
		}

		public function get indication():String
		{
			return "";
		}

		public function get primaryInstructions():String
		{
			return "";
		}

		public function get secondaryInstructions():String
		{
			return "";
		}

		public function get instructionalVideoPath():String
		{
			return "";
		}

		public function set instructionalVideoPath(value:String):void
		{

		}

		public function get additionalAdherenceInformation():String
		{
			return "...";
		}

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			if (!_controller)
			{
				_controller = new HealthActionListViewControllerBase(_model);
			}
			return _controller;
		}

		public function createCustomView():IVisualElement
		{
			return null;
		}
	}
}
