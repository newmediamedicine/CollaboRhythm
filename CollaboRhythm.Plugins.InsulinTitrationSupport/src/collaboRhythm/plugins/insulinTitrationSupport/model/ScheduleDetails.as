package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class ScheduleDetails
	{
		private var _schedule:MedicationScheduleItem;
		private var _occurrence:ScheduleItemOccurrence;

		public function ScheduleDetails(schedule:MedicationScheduleItem=null, occurrence:ScheduleItemOccurrence=null)
		{
			_schedule = schedule;
			_occurrence = occurrence;
		}

		public function get schedule():MedicationScheduleItem
		{
			return _schedule;
		}

		public function set schedule(value:MedicationScheduleItem):void
		{
			_schedule = value;
		}

		public function get occurrence():ScheduleItemOccurrence
		{
			return _occurrence;
		}

		public function set occurrence(value:ScheduleItemOccurrence):void
		{
			_occurrence = value;
		}
	}
}
