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
package collaboRhythm.workstation.apps.schedule.model
{
	import collaboRhythm.workstation.apps.schedule.view.FullAdherenceGroupView;
	import collaboRhythm.workstation.apps.schedule.view.FullMedicationView;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	[Bindable]
	public class AdherenceGroup extends ScheduleItemBase
	{
		private var _scheduleItems:Vector.<ScheduleItemBase>;
		private var _adherenceWindow:Number;
		private var _medicationSpaces:Array;
		private var _groupFromRight:Number = 1;
		private var _show:Boolean = false;
		
		public function AdherenceGroup(hour:Number, scheduleItems:Vector.<ScheduleItemBase>)
		{
			_scheduleItems = scheduleItems;
			this.hour = hour;
			_adherenceWindow = 2;
			scheduled = true;
		}
		
		public function get scheduleItems():Vector.<ScheduleItemBase>
		{
			return _scheduleItems;
		}
		
		public function set scheduleItems(value:Vector.<ScheduleItemBase>):void
		{
			_scheduleItems = value;
		}
		
		public function get adherenceWindow():Number
		{
			return _adherenceWindow;
		}
		
		public function set adherenceWindow(value:Number):void
		{
			_adherenceWindow = value;
		}
		
		public function get medicationSpaces():Array
		{
			return _medicationSpaces;
		}
		
		public function set medicationSpaces(value:Array):void
		{
			_medicationSpaces = value;
		}
		
		public function get groupFromRight():Number
		{
			return _groupFromRight;
		}
		
		public function set groupFromRight(value:Number):void
		{
			_groupFromRight = value;
		}	
		
		public function get show():Boolean
		{
			return _show;
		}
		
		public function set show(value:Boolean):void
		{
			_show = value;
		}
		
		public function addScheduleItem(scheduleItem:ScheduleItemBase):void
		{
			_scheduleItems.push(scheduleItem);
		}
		
		public function moveAdherenceGroup(moveData:MoveData):void
		{
			updateHour(moveData.hour);
			yBottomPosition = moveData.yBottomPosition - FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH;
		}
		
		public function moveScheduledItems(moveData:MoveData):void
		{
			var index:Number = 0
			for each (var scheduleItem:ScheduleItemBase in scheduleItems)
			{
				scheduleItem.updateHour(moveData.hour);
				scheduleItem.yBottomPosition = moveData.yBottomPosition + FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH + index * (FullMedicationView.MEDICATION_HEIGHT + FullAdherenceGroupView.ADHERENCE_GROUP_BUFFER_WIDTH);
				index += 1;
			}
		}
	}
}