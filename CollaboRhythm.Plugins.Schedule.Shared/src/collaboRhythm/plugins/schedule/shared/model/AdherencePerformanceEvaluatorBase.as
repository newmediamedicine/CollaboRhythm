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

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class AdherencePerformanceEvaluatorBase
	{
		private var _scheduleItemType:String;

		public function AdherencePerformanceEvaluatorBase(scheduleItemType:String)
		{
			_scheduleItemType = scheduleItemType;
		}

		public function evaluateAdherencePerformance(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
														record:Record, adherencePerformanceInterval:String):AdherencePerformanceAssertion
		{
			throw new Error("virtual function must be overridden in subclass");
		}

		protected function getScheduleItemOccurrencesForType(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>):Vector.<ScheduleItemOccurrence>
		{
			var scheduleItemOccurrencesForType:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrencesVector)
			{
				if (scheduleItemOccurrence.scheduleItem.meta.type == _scheduleItemType)
				{
					scheduleItemOccurrencesForType.push(scheduleItemOccurrence);
				}
			}
			return scheduleItemOccurrencesForType;
		}

		protected function isAdherencePerformancePerfect(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>):Boolean
		{
			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrencesVector)
			{
				if (scheduleItemOccurrence.scheduleItem.meta.type == _scheduleItemType)
				{
					if (!scheduleItemOccurrence.adherenceItem || (scheduleItemOccurrence.adherenceItem && !scheduleItemOccurrence.adherenceItem.adherence))
					{
						return false;
					}
				}
			}
			return true;
		}
	}
}
