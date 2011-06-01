package collaboRhythm.plugins.schedule.shared.view
{
	import collaboRhythm.shared.model.AdherenceItem;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.shared.model.ScheduleItemBase;
	
	import flash.events.Event;
	
	public class ScheduleItemReportingViewEventHandler extends Event
	{
		public static const ADHERENCE_ITEM_CREATED:String = "AdherenceItemCreated";
		
		private var _scheduleItem:ScheduleItemBase;
		private var _adherenceItem:AdherenceItem
		
		public function ScheduleItemReportingViewEventHandler(type:String, scheduleItem:ScheduleItemBase, adherenceItem:AdherenceItem)
		{
			super(type, true);
			
			_scheduleItem = scheduleItem;
			_adherenceItem = adherenceItem;
		}
		
		public function get scheduleItem():ScheduleItemBase
		{
			return _scheduleItem;
		}

		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}

	}
}