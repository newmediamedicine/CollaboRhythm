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
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class AdherencePerformanceModel
	{
		/**
		 * Key to the CurrentPerformanceModel instance in Record.appData
		 */
		public static const ADHERENCE_PERFORMANCE_MODEL_KEY:String = "adherencePerformanceModel";

		public static const ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY:String = "Yesterday";
		public static const ADHERENCE_PERFORMANCE_INTERVAL_TODAY:String = "Today";

		private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		private var _scheduleCollectionsProvider:IScheduleCollectionsProvider;
		private var _record:Record;

		private var _adherencePerformanceAssertionsCollection:ArrayCollection;

		private var _currentDateSource:ICurrentDateSource;

		public function AdherencePerformanceModel(scheduleCollectionsProvider:IScheduleCollectionsProvider,
												  record:Record)
		{
			_scheduleCollectionsProvider = scheduleCollectionsProvider;
			_record = record;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function updateAdherencePerformance():void
		{
			_adherencePerformanceAssertionsCollection = new ArrayCollection();

			var currentDate:Date = _currentDateSource.now();
			var scheduleItemOccurrencesForToday:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForToday(currentDate);
			if (scheduleItemOccurrencesForToday.length != 0)
			{
				updateAdherencePerformanceForInterval(scheduleItemOccurrencesForToday,
													  ADHERENCE_PERFORMANCE_INTERVAL_TODAY);
			}
			else
			{
				var scheduleItemOccurrencesForYesterday:Vector.<ScheduleItemOccurrence> = getScheduleItemOccurrencesForYesterday(currentDate);
				if (scheduleItemOccurrencesForYesterday.length != 0)
				{
					updateAdherencePerformanceForInterval(scheduleItemOccurrencesForYesterday,
														  ADHERENCE_PERFORMANCE_INTERVAL_YESTERDAY);
				}
			}
		}

		private function getScheduleItemOccurrencesForToday(currentDate:Date):Vector.<ScheduleItemOccurrence>
		{
			var dateStart:Date = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate());
			return _scheduleCollectionsProvider.getScheduleItemOccurrences(dateStart, currentDate);
		}

		private function getScheduleItemOccurrencesForYesterday(currentDate:Date):Vector.<ScheduleItemOccurrence>
		{
			var dateStart:Date = new Date(new Date(currentDate.getFullYear(), currentDate.getMonth(),
												   currentDate.getDate()).valueOf() - MILLISECONDS_IN_DAY);
			var dateEnd:Date = new Date(dateStart.valueOf() + MILLISECONDS_IN_DAY - 1);
			return _scheduleCollectionsProvider.getScheduleItemOccurrences(dateStart, dateEnd);
		}

		private function updateAdherencePerformanceForInterval(scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence>,
															   adherencePerformanceInterval:String):void
		{
			for each (var scheduleItemsCollection:ArrayCollection in _scheduleCollectionsProvider.scheduleItemsCollectionsArray)
			{
				if (scheduleItemsCollection.length > 0)
				{
					var adherencePerformanceEvaluator:AdherencePerformanceEvaluatorBase = _scheduleCollectionsProvider.viewFactory.createAdherencePerformanceEvaluator(scheduleItemsCollection[0]);
					var adherencePerformanceAssertion:String = adherencePerformanceEvaluator.evaluateAdherencePerformance(scheduleItemOccurrencesVector,
																														  _record,
																														  adherencePerformanceInterval);
					_adherencePerformanceAssertionsCollection.addItem(adherencePerformanceAssertion);
				}
			}
		}

		public function get adherencePerformanceAssertionsCollection():ArrayCollection
		{
			return _adherencePerformanceAssertionsCollection;
		}

		public function set adherencePerformanceAssertionsCollection(value:ArrayCollection):void
		{
			_adherencePerformanceAssertionsCollection = value;
		}
	}
}
