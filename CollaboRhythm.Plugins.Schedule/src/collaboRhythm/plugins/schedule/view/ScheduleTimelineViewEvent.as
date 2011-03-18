package collaboRhythm.plugins.schedule.view
{
	import collaboRhythm.plugins.schedule.shared.model.MoveData;
	
	import flash.events.Event;

	public class ScheduleTimelineViewEvent extends Event
	{
		public static const SCHEDULE_GROUP_TIMELINE_VIEW_MOUSE_DOWN:String = "ScheduleGroupTimelineViewMouseDown";
		public static const SCHEDULE_GROUP_TIMELINE_VIEW_MOUSE_MOVE:String = "ScheduleGroupTimelineViewMouseMove";
		public static const SCHEDULE_GROUP_TIMELINE_VIEW_MOUSE_UP:String = "ScheduleGroupTimelineViewMouseUp";
		
		public static const SCHEDULE_GROUP_SPOTLIGHT_VIEW_MOUSE_DOWN:String = "ScheduleGroupSpotlightViewMouseDown";
		public static const SCHEDULE_GROUP_SPOTLIGHT_VIEW_LEFT_MOUSE_MOVE:String = "ScheduleGroupSpotlightViewLeftMouseMove";
		public static const SCHEDULE_GROUP_SPOTLIGHT_VIEW_RIGHT_MOUSE_MOVE:String = "ScheduleGroupSpotlightViewRightMouseMove";
		public static const SCHEDULE_GROUP_SPOTLIGHT_VIEW_MOUSE_UP:String = "ScheduleGroupSpotlightViewMouseUp";
		
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