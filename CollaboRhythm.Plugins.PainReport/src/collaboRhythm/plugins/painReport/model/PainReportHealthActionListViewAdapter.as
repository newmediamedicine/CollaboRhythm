package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthAction;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;

	import spark.components.Image;

	public class PainReportHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		public static const HEALTH_ACTION_TYPE:String = "Pain Report";

		private var _healthAction:HealthAction;

		public function PainReportHealthActionListViewAdapter()
		{
			_healthAction = new HealthAction(HEALTH_ACTION_TYPE);
		}

		public function get healthAction():HealthAction
		{
			return _healthAction;
		}

		public function get image():Image
		{
			return null;
		}

		public function get name():String
		{
			return _healthAction.healthActionType;
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

		public function get model():ScheduleItemOccurrenceReportingModelBase
		{
			return new PainReportHealthActionListViewModel(null, null);
		}
	}
}
