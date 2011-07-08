package collaboRhythm.plugins.schedule.shared.view
{
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;

    import flash.events.Event;
	
	public class ScheduleItemReportingViewEvent extends Event
	{
		public static const ADHERENCE_ITEM_CREATED:String = "AdherenceItemCreated";
		
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _adherenceItem:AdherenceItem;
		
		public function ScheduleItemReportingViewEvent(type:String, scheduleItemOccurrence:ScheduleItemOccurrence, adherenceItem:AdherenceItem)
		{
			super(type, true);
			
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_adherenceItem = adherenceItem;
		}
		
		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _scheduleItemOccurrence;
		}

		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}

	}
}