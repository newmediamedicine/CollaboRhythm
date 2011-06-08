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
package collaboRhythm.shared.model
{

    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;

    [Bindable]
	public class MedicationScheduleItem extends ScheduleItemBase
	{
		private var _dose:ValueAndUnit;
        private var _scheduledMedicationOrder:MedicationOrder;
//		private var _scheduledActionID:String;
//		private var _scheduledAction:Medication;
//		private var _scheduleGroupID:String;

		public function MedicationScheduleItem():void
		{
		}

        public override function initFromReportXML(scheduleItemReportXml:XML, scheduleItemElementName:String):void
        {
            super.initFromReportXML(scheduleItemReportXml, scheduleItemElementName);

            _dose = new ValueAndUnit(scheduleItemXml.dose.value, HealthRecordHelperMethods.xmlToCodedValue(scheduleItemXml.dose.unit[0]));
//            _scheduledActionID = scheduleItemReportXML.Meta.Document.relatesTo.relation.relatedDocument.@id;
//			_scheduleGroupID =  scheduleItemReportXML.Meta.Document.isRelatedFrom.relation.relatedDocument[0].@id;
        }

		
//		public function get scheduledActionID():String
//		{
//			return _scheduledActionID;
//		}
//
//		public function get scheduledAction():Medication
//		{
//			return _scheduledAction;
//		}
//
//		public function set scheduledAction(value:Medication):void
//		{
//			_scheduledAction = value;
//		}
//
//		public function get scheduleGroupID():String
//		{
//			return _scheduleGroupID;
//		}
		
//		public override function createScheduleItemClockView():ScheduleItemClockViewBase
//		{
//			var medicationScheduleItemClockView:MedicationScheduleItemClockView = new MedicationScheduleItemClockView();
//			medicationScheduleItemClockView.medication = _scheduledAction;
//			medicationScheduleItemClockView.medicationScheduleItem = this;
//			return medicationScheduleItemClockView;
//		}
//
//		public override function createScheduleItemReportingView():ScheduleItemReportingViewBase
//		{
//			var medicationScheduleItemWidgetView:MedicationScheduleItemReportingView = new MedicationScheduleItemReportingView();
//			medicationScheduleItemWidgetView.medication = _scheduledAction;
//			medicationScheduleItemWidgetView.medicationScheduleItem = this;
//			return medicationScheduleItemWidgetView;
//		}
//
//		public override function createScheduleItemTimelineView():ScheduleItemTimelineViewBase
//		{
//			var medicationScheduleItemFullView:MedicationScheduleItemTimelineView = new MedicationScheduleItemTimelineView();
//			medicationScheduleItemFullView.medication = _scheduledAction;
//			return medicationScheduleItemFullView;
//		}
        public function get scheduledMedicationOrder():MedicationOrder {
            return _scheduledMedicationOrder;
        }

        public function set scheduledMedicationOrder(value:MedicationOrder):void {
            _scheduledMedicationOrder = value;
        }

        public function get dose():ValueAndUnit
        {
            return _dose;
        }

        public function set dose(value:ValueAndUnit):void
        {
            _dose = value;
        }
    }
}