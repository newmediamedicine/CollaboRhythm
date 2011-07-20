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
package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.*;

    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class MedicationScheduleItem extends ScheduleItemBase
	{
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#MedicationScheduleItem";
        public static const MEDICATION:String = "Medication";

		private var _dose:ValueAndUnit;
        private var _scheduledMedicationOrder:MedicationOrder;
//		private var _scheduledActionID:String;
//		private var _scheduledAction:Medication;
//		private var _scheduleGroupID:String;

		public function MedicationScheduleItem():void
		{
		}

        override public function initFromReportXML(scheduleItemReportXml:XML, scheduleItemElementName:String):void
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            super.initFromReportXML(scheduleItemReportXml, scheduleItemElementName);

            _dose = new ValueAndUnit(scheduleItemXml.dose.value, HealthRecordHelperMethods.xmlToCodedValue(scheduleItemXml.dose.unit[0]));
        }

        override public function createXmlDocument():XML
        {
            var medicationScheduleItemXml:XML = <MedicationScheduleItem/>;
            return medicationScheduleItemXml;
        }

        override public function schedueItemType():String
        {
            return MEDICATION;
        }

        override public function addExtraXml(scheduleItemXml:XML):XML
        {
            scheduleItemXml.dose.value = dose.value;
            scheduleItemXml.dose.unit = dose.unit.text;
            scheduleItemXml.dose.unit.@type = dose.unit.type;
            scheduleItemXml.dose.unit.@value = dose.unit.value;
            scheduleItemXml.dose.unit.@abbrev = dose.unit.abbrev;

            return scheduleItemXml;
        }

        override public function getScheduleActionId():String
        {
            return _scheduledMedicationOrder.meta.id;
        }

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