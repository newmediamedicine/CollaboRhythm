package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionListViewControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import spark.components.Image;

	public class InsulinTitrationSupportHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private var _healthAction:InsulinTitrationSupportHealthAction;
		private var _model:InsulinTitrationSupportHealthActionListViewModel;
		private var _controller:HealthActionListViewControllerBase;

		public function InsulinTitrationSupportHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_healthAction = new InsulinTitrationSupportHealthAction();
			_model = new InsulinTitrationSupportHealthActionListViewModel(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_controller = new HealthActionListViewControllerBase(_model)
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
			return InsulinTitrationSupportHealthAction.HEALTH_ACTION_TYPE;
		}

		public function get description():String
		{
			return "Make a decision to change insulin dose";
		}

		public function get indication():String
		{
			return "Diabetes";
		}

		public function get primaryInstructions():String
		{
			return "";
		}

		public function get secondaryInstructions():String
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
