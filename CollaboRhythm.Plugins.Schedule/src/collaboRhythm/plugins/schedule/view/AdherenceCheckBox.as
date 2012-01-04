package collaboRhythm.plugins.schedule.view
{

	import spark.components.CheckBox;

	/**
	 * A subclass of the CheckBox was created so that whether or not it is selected is based on whether or not there
	 * is an AherenceItem related to the ScheduleItemOccurrence as opposed to whether the check box is pressed
	 */
	public class AdherenceCheckBox extends CheckBox
	{
		public function AdherenceCheckBox()
		{
			super();
		}

		override protected function buttonReleased():void
		{
			// Normally, the CheckBox would be toggled here. Instead, the adherence CheckBox is selected based on
			// data binding depending on whether a corresponding adherenceItem is associated with it.
		}
	}
}
