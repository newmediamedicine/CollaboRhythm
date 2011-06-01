/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.plugins.schedule.shared.model
{

    import collaboRhythm.shared.model.ScheduleItemBase;

    public class Time
	{
		private var _scheduleItems:Vector.<ScheduleItemBase>;
		private var _adherenceGroup:AdherenceGroup;
		
		public function Time()
		{
			_scheduleItems = new Vector.<ScheduleItemBase>;
		}
		
		public function get scheduleItems():Vector.<ScheduleItemBase>
		{
			return _scheduleItems;
		}
		
		public function set scheduleItems(value:Vector.<ScheduleItemBase>):void
		{
			_scheduleItems = value;
		}
		
		public function get adherenceGroup():AdherenceGroup
		{
			return _adherenceGroup;
		}
		
		public function set adherenceGroup(value:AdherenceGroup):void
		{
			_adherenceGroup = value;
		}
		
		public function removeMedication(medication:ScheduleItemBase):void
		{
			var medicationIndex:Number = _scheduleItems.indexOf(medication);
			_scheduleItems.splice(medicationIndex, 1);
		}
		
		public function addMedication(medication:ScheduleItemBase):void
		{
			_scheduleItems.push(medication);
		}
		
	}
}