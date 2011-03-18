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
	import collaboRhythm.plugins.medications.view.MedicationScheduleItemClockView;
	import collaboRhythm.plugins.medications.view.MedicationScheduleItemTimelineView;
	import collaboRhythm.plugins.medications.view.MedicationScheduleItemReportingView;
	import collaboRhythm.plugins.schedule.shared.model.AdherenceItem;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.ValueAndUnit;
	
	[Bindable]
	public class MedicationScheduleItem extends ScheduleItemBase
	{
		private var _dose:ValueAndUnit;
		private var _scheduledActionID:String;
		private var _scheduledAction:Medication;
		private var _scheduleGroupID:String;

		public function MedicationScheduleItem(scheduleItemReportXML:XML):void
		{
			super(scheduleItemReportXML, "MedicationScheduleItem");
			
			_dose = new ValueAndUnit(scheduleItemXML.dose.value, HealthRecordHelperMethods.codedValueFromXml(scheduleItemXML.dose.unit[0]));
			_scheduledActionID = scheduleItemReportXML.Meta.Document.relatesTo.relation.relatedDocument.@id;
			_scheduleGroupID =  scheduleItemReportXML.Meta.Document.isRelatedFrom.relation.relatedDocument[0].@id;
		}
		
		public function get dose():ValueAndUnit
		{
			return _dose;
		}
		
		public function get scheduledActionID():String
		{
			return _scheduledActionID;
		}
		
		public function get scheduledAction():Medication
		{
			return _scheduledAction;
		}
		
		public function set scheduledAction(value:Medication):void
		{
			_scheduledAction = value;
		}
		
		public function get scheduleGroupID():String
		{
			return _scheduleGroupID;
		}
		
		public override function createScheduleItemClockView():ScheduleItemClockViewBase
		{
			var medicationScheduleItemClockView:MedicationScheduleItemClockView = new MedicationScheduleItemClockView();
			medicationScheduleItemClockView.medication = _scheduledAction;
			medicationScheduleItemClockView.medicationScheduleItem = this;
			return medicationScheduleItemClockView;
		}
		
		public override function createScheduleItemReportingView():ScheduleItemReportingViewBase
		{
			var medicationScheduleItemWidgetView:MedicationScheduleItemReportingView = new MedicationScheduleItemReportingView();
			medicationScheduleItemWidgetView.medication = _scheduledAction;
			medicationScheduleItemWidgetView.medicationScheduleItem = this;
			return medicationScheduleItemWidgetView;
		}
		
		public override function createScheduleItemTimelineView():ScheduleItemTimelineViewBase
		{
			var medicationScheduleItemFullView:MedicationScheduleItemTimelineView = new MedicationScheduleItemTimelineView();
			medicationScheduleItemFullView.medication = _scheduledAction;
			return medicationScheduleItemFullView;
		}
	}
}