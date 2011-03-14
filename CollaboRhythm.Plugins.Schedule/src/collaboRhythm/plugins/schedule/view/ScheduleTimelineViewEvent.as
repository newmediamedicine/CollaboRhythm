package collaboRhythm.plugins.schedule.view
{
	import collaboRhythm.plugins.schedule.shared.model.MoveData;
	
	import flash.events.Event;

	public class ScheduleTimelineViewEvent extends Event
	{
		public static const SCHEDULE_GROUP_TIMELINE_VIEW_MOUSE_DOWN:String = "ScheduleGroupTimelineViewMouseDown";
		public static const SCHEDULE_GROUP_TIMELINE_VIEW_MOUSE_MOVE:String = "ScheduleGroupTimelineViewMouseMove";
		
		private var _moveData:MoveData;
		
		public function ScheduleTimelineViewEvent(type:String, moveData:MoveData)
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