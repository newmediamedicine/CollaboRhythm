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

	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;

	public class PendingAdherenceItem
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _adherenceItem:AdherenceItem;
		private var _scheduleGroup:ScheduleGroup;

		public function get scheduleGroup():ScheduleGroup
		{
			return _scheduleGroup;
		}

		public function set scheduleGroup(value:ScheduleGroup):void
		{
			_scheduleGroup = value;
		}

		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _scheduleItemOccurrence;
		}

		public function set scheduleItemOccurrence(value:ScheduleItemOccurrence):void
		{
			_scheduleItemOccurrence = value;
		}

		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}

		public function set adherenceItem(value:AdherenceItem):void
		{
			_adherenceItem = value;
		}

		public function PendingAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItemOccurrence:ScheduleItemOccurrence,
											 adherenceItem:AdherenceItem)
		{
			_scheduleGroup = scheduleGroup;
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_adherenceItem = adherenceItem;
		}
	}
}
