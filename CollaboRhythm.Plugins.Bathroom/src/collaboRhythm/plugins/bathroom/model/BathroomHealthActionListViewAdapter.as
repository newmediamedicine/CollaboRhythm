package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;

	import spark.components.Image;

	public class BathroomHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		public static const HEALTH_ACTION_TYPE:String = "Bathroom";

		private var _healthAction:HealthActionBase;

		private var _model:BathroomHealthActionListViewModel;
		private var _controller:HealthActionListViewControllerBase;

		public function BathroomHealthActionListViewAdapter()
		{
			_healthAction = new HealthActionBase(HEALTH_ACTION_TYPE);

			_model = new BathroomHealthActionListViewModel(null, null);
			_controller = new HealthActionListViewControllerBase(_model);
		}

		public function get healthAction():HealthActionBase
		{
			return _healthAction;
		}

		public function get image():Image
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

		public function get instructions():String
		{
			return "";
		}

		public function get model():IHealthActionListViewModel
		{
			return _model;
		}

		public function get controller():IHealthActionListViewController
		{
			return _controller;
		}
	}
}