package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class ScheduleDetails
	{
		private var _currentSchedule:ScheduleItemBase;
		private var _occurrence:ScheduleItemOccurrence;
		private var _previousSchedule:ScheduleItemBase;

		public function ScheduleDetails(currentSchedule:ScheduleItemBase=null, occurrence:ScheduleItemOccurrence=null)
		{
			_currentSchedule = currentSchedule;
			_occurrence = occurrence;
		}

		public function get currentSchedule():ScheduleItemBase
		{
			return _currentSchedule;
		}

		public function set currentSchedule(value:ScheduleItemBase):void
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

		public function get previousSchedule():ScheduleItemBase
		{
			return _previousSchedule;
		}

		public function set previousSchedule(previousSchedule:ScheduleItemBase):void
		{
			_previousSchedule = previousSchedule;
		}
	}
}
