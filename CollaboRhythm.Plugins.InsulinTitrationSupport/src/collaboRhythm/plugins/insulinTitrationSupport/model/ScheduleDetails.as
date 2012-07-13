package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class ScheduleDetails
	{
		private var _currentSchedule:MedicationScheduleItem;
		private var _occurrence:ScheduleItemOccurrence;
		private var _previousSchedule:MedicationScheduleItem;

		public function ScheduleDetails(schedule:MedicationScheduleItem=null, occurrence:ScheduleItemOccurrence=null)
		{
			_currentSchedule = schedule;
			_occurrence = occurrence;
		}

		public function get currentSchedule():MedicationScheduleItem
		{
			return _currentSchedule;
		}

		public function set currentSchedule(value:MedicationScheduleItem):void
		{
			_currentSchedule = value;
		}

		public function get occurrence():ScheduleItemOccurrence
		{
			return _occurrence;
		}

		public function set occurrence(value:ScheduleItemOccurrence):void
		{
			_occurrence = value;
		}

		public function get previousSchedule():MedicationScheduleItem
		{
			return _previousSchedule;
		}

		public function set previousSchedule(previousSchedule:MedicationScheduleItem):void
		{
			_previousSchedule = previousSchedule;
		}
	}
}
