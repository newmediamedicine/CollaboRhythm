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
package collaboRhythm.plugins.medications.model
{

	import castle.flexbridge.reflection.ClassInfo;
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.AdherencePerformanceEvaluatorBase;
	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class MedicationsReportingViewAdapterFactory implements IReportingViewAdapterFactory
    {
        public function MedicationsReportingViewAdapterFactory()
        {
        }

		public function isMatchingReportingViewAdapterFactory(name:String = null, scheduleItem:ScheduleItemBase = null):Boolean
		{
			return ReflectionUtils.getClass(scheduleItem) == MedicationScheduleItem;
		}

		public function createAdherencePerformanceEvaluator(scheduleItemOccurrence:ScheduleItemOccurrence):AdherencePerformanceEvaluatorBase
		{
			return new MedicationsAdherencePerformanceEvaluator();
		}

		public function createReportingViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence):IReportingViewAdapter
		{
			var medicationScheduleItemOccurrenceReportingViewAdapter:MedicationScheduleItemOccurrenceReportingViewAdapter = new MedicationScheduleItemOccurrenceReportingViewAdapter(scheduleItemOccurrence);
			return medicationScheduleItemOccurrenceReportingViewAdapter;
		}

		public function createReportingModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																   scheduleModel:IScheduleModel):ScheduleItemOccurrenceReportingModelBase
		{
			var medicationScheduleItemOccurrenceReportingModel:MedicationScheduleItemOccurrenceReportingModel = new MedicationScheduleItemOccurrenceReportingModel(scheduleItemOccurrence,
																																								   scheduleModel);
			return medicationScheduleItemOccurrenceReportingModel;
		}

		public function get reportingViewAdaptersCollection():ArrayCollection
		{
			return null;
		}
	}
}
