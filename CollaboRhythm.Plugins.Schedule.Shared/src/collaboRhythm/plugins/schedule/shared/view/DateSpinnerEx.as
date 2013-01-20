package collaboRhythm.plugins.schedule.shared.view
{
	import spark.components.DateSpinner;

	public class DateSpinnerEx extends DateSpinner
	{
		public function DateSpinnerEx()
		{
		}

		override public function get baselinePosition():Number
		{
			return Math.round((super.baselinePosition + height) / 2) - 2;
		}
	}
}
