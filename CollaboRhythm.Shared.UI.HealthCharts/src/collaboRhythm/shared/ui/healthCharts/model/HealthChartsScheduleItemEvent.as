package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.Event;

	public class HealthChartsScheduleItemEvent extends Event
	{
		public static const TOGGLE_ADHERENCE:String = "scheduleItemOccurrenceToggleAdherence";

		private var _scheduleItemOccurrence:ScheduleItemOccurrence;

		public function HealthChartsScheduleItemEvent(type:String, scheduleItemOccurrence:ScheduleItemOccurrence, bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_scheduleItemOccurrence = scheduleItemOccurrence;
		}

		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _scheduleItemOccurrence;
		}
	}
}
