package collaboRhythm.workstation.apps.schedule.view
{
	import collaboRhythm.workstation.apps.schedule.model.MoveData;
	
	import flash.events.Event;
	
	public class FullScheduleItemViewEvent extends Event
	{
		public static const SCHEDULE_ITEM_GRAB:String = "ScheduleItemGrab";
		public static const SCHEDULE_ITEM_MOVE:String = "ScheduleItemMove";
		public static const SCHEDULE_ITEM_DROP:String = "ScheduleItemDrop";
		public static const MEDICATION_BEGIN_DRAG:String = "MedicationBeginDrag";
		public static const MEDICATION_MOVE:String = "MedicationMove";
		public static const MEDICATION_DROP:String = "MedicationDrop";
		public static const ADHERENCE_GROUP_BEGIN_DRAG:String = "AdherenceGroupBeginDrag";
		public static const ADHERENCE_GROUP_MOVE:String = "AdherenceGroupMove";
		public static const ADHERENCE_GROUP_DROP:String = "AdherenceGroupDrop";
		public static const ADHERENCE_WINDOW_BEGIN_RESIZE:String = "AdherenceWindowBeginResize";
		public static const ADHERENCE_WINDOW_RESIZE:String = "AdherenceWindowResize";
		public static const ADHERENCE_WINDOW_STOP_RESIZE:String = "AdherenceWindowStopResize";
		public static const SMART_DRAWER_BEGIN_DRAG:String = "SmartDrawerBeginDrag";
		public static const SMART_DRAWER_MOVE:String = "SmartDrawerMove";
		public static const SMART_DRAWER_DROP:String = "SmartDrawerDrop";
		
		private var _moveData:MoveData;
		
		public function FullScheduleItemViewEvent(type:String, moveData:MoveData)
		{
			super(type, true);
			_moveData = moveData;
		}
		
		public function get moveData():MoveData 
		{
			return _moveData;
		}		
	}
}