/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.plugins.schedule.view
{

	
	import collaboRhythm.plugins.schedule.shared.model.MoveData;
	
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