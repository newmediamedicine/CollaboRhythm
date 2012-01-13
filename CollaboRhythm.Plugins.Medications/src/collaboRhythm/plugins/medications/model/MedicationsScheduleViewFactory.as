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
	import collaboRhythm.plugins.schedule.shared.model.IScheduleItemOccurrenceReportingViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class MedicationsScheduleViewFactory implements IScheduleViewFactory
    {
        public function MedicationsScheduleViewFactory()
        {
        }

        public function get scheduleItemType():ClassInfo
        {
            return ReflectionUtils.getClassInfo(MedicationScheduleItem);
        }

		public function createAdherencePerformanceEvaluator(scheduleItem:ScheduleItemBase):AdherencePerformanceEvaluatorBase
		{
			return new MedicationsAdherencePerformanceEvaluator();
		}

		public function createScheduleItemOccurrenceReportingViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence):IScheduleItemOccurrenceReportingViewAdapter
		{
			var medicationScheduleItemOccurrenceReportingViewAdapter:MedicationScheduleItemOccurrenceReportingViewAdapter = new MedicationScheduleItemOccurrenceReportingViewAdapter(scheduleItemOccurrence);
			return medicationScheduleItemOccurrenceReportingViewAdapter;
		}

		public function createScheduleItemOccurrenceReportingModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																   scheduleModel:IScheduleModel):ScheduleItemOccurrenceReportingModelBase
		{
			var medicationScheduleItemOccurrenceReportingModel:MedicationScheduleItemOccurrenceReportingModel = new MedicationScheduleItemOccurrenceReportingModel(scheduleItemOccurrence,
																																								   scheduleModel);
			return medicationScheduleItemOccurrenceReportingModel;
		}
	}
}
