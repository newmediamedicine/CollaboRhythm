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

	import mx.collections.ArrayCollection;

	public interface IScheduleCollectionsProvider
	{
		function get scheduleGroupsCollection():ArrayCollection;
		function get scheduleItemOccurrencesVector():Vector.<ScheduleItemOccurrence>;
		function get scheduleItemsCollectionsArray():Array
		function getScheduleItemOccurrences(dateStart:Date, dateEnd:Date):Vector.<ScheduleItemOccurrence>
		function get healthActionListViewAdapterFactory():MasterHealthActionListViewAdapterFactory;

		/**
		 * Finds the closest schedule item occurrence to the current time from the schedule item occurrences for today
		 * that do not already have adherence items. If the current time falls within the adherence window of a schedule
		 * item occurrence, then this schedule item occurrence is automatically the closest.
		 *
		 * @param name The name of the schedule item occurrence, which is the name of the device for an equipmentScheduleItem
		 * @return The schedule item occurrence that meets the criteria for being the closest
		 */
		function findClosestScheduleItemOccurrence(name:String, dateStartString:String):ScheduleItemOccurrence;
	}
}
