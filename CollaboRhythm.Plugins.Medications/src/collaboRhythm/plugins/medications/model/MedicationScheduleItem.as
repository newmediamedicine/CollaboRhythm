/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemBase;
	import collaboRhythm.shared.model.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.ValueAndUnit;
	
	public class MedicationScheduleItem extends ScheduleItemBase
	{
		private var _dose:ValueAndUnit;
		private var _scheduledAction:Medication;

		public function MedicationScheduleItem(scheduleItemReportXML:XML):void
		{
			var scheduleItemXML:XML = scheduleItemReportXML.Item.MedicationScheduleItem[0];
			super(scheduleItemReportXML.Meta.Document.@id, scheduleItemXML);
			
			_dose = new ValueAndUnit(scheduleItemXML.dose.value, HealthRecordHelperMethods.codedValueFromXml(scheduleItemXML.dose.unit[0]));
			var scheduledActionID:String = scheduleItemReportXML.Meta.Document.relatesTo.relation.relatedDocument.@id;
		}
		
		public function get dose():ValueAndUnit
		{
			return _dose;
		}
		
		public function get scheduledAction():Medication
		{
			return _scheduledAction;
		}
	}
}