package collaboRhythm.plugins.intake.model
{
	import spark.components.Image;

	public class IntakeHealthActionListViewAdapter implements IHealthActionListViewAdapter
	{
		private static const NAME:String = "Pain Report";

		public function IntakeHealthActionListViewAdapter()
		{
		}

		public function get image():Image
		{
			return null;
		}


		public function get name():String
		{
			return NAME;
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
			return new IntakeHealthActionListViewModel(null, null);
		}
	}
}
