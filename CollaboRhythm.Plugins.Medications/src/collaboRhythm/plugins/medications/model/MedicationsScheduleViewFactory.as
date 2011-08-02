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

	import collaboRhythm.plugins.medications.view.MedicationScheduleItemClockView;
	import collaboRhythm.plugins.medications.view.MedicationScheduleItemReportingView;
	import collaboRhythm.plugins.medications.view.MedicationScheduleItemTimelineView;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleReportingModel;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.InvokeEvent;

	public class MedicationsScheduleViewFactory implements IScheduleViewFactory
    {
        public function MedicationsScheduleViewFactory()
        {
        }

        public function get scheduleItemType():ClassInfo
        {
            return ReflectionUtils.getClassInfo(MedicationScheduleItem);
        }

        public function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemClockViewBase
        {
            var medicationScheduleItemClockView:MedicationScheduleItemClockView =  new MedicationScheduleItemClockView();
            medicationScheduleItemClockView.init(scheduleItemOccurrence);
            return medicationScheduleItemClockView;
        }

        public function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence,
														scheduleReportingModel:IScheduleReportingModel,
														activeAccountId:String,
														handledInvokeEvents:Vector.<String>):ScheduleItemReportingViewBase
        {
            var medicationScheduleItemReportingView:MedicationScheduleItemReportingView = new MedicationScheduleItemReportingView();
            medicationScheduleItemReportingView.init(scheduleItemOccurrence, scheduleReportingModel, activeAccountId, handledInvokeEvents);
            return medicationScheduleItemReportingView;
        }

        public function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemTimelineViewBase
        {
            var medicationScheduleItemTimelineView:MedicationScheduleItemTimelineView = new MedicationScheduleItemTimelineView();
            medicationScheduleItemTimelineView.init(scheduleItemOccurrence);
            return medicationScheduleItemTimelineView;
        }
    }
}
