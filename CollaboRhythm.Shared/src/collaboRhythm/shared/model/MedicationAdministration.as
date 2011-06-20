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

    import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;

    import collaboRhythm.shared.model.DateUtil;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;

    import com.adobe.utils.DateUtil;

    import j2as3.collection.HashMap;

    [Bindable]
    public class MedicationAdministration extends DocumentMetadata
    {
        private var _name:CodedValue;
        private var _reportedBy:String;
        private var _dateReported:Date;
        private var _dateAdministered:Date;
        private var _amountAdministered:ValueAndUnit;
        private var _amountRemaining:ValueAndUnit;

        private var _currentDateSource:ICurrentDateSource;

        public function MedicationAdministration()
        {
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function init(name:CodedValue, reportedBy:String, dateReported:Date, dateAdministered:Date = null, amountAministered:ValueAndUnit = null, amountRemaining:ValueAndUnit = null):void
		{
			_name = name;
            _reportedBy = reportedBy;
            _dateReported = dateReported;
            _dateAdministered = dateAdministered;
            _amountAdministered = amountAministered;
            _amountRemaining = amountRemaining;
		}

		public function initFromReportXML(medicationOrderReportXml:XML):void
		{
			parseDocumentMetadata(medicationOrderReportXml.Meta.Document[0], this);
			var medicationAdministrationXml:XML = medicationOrderReportXml.Item.MedicationAdministration[0];
            _name = HealthRecordHelperMethods.xmlToCodedValue(medicationAdministrationXml.name[0]);
            _reportedBy = medicationAdministrationXml.reportedBy;
            _dateReported = collaboRhythm.shared.model.DateUtil.parseW3CDTF(medicationAdministrationXml.dateReported.toString());
			_dateAdministered = collaboRhythm.shared.model.DateUtil.parseW3CDTF(medicationAdministrationXml.dateAdministered.toString());
            _amountAdministered = new ValueAndUnit(medicationAdministrationXml.amountAdministered.value, HealthRecordHelperMethods.xmlToCodedValue(medicationAdministrationXml.amountAdministered.unit[0]));
            _amountRemaining = new ValueAndUnit(medicationAdministrationXml.amountRemaining.value, HealthRecordHelperMethods.xmlToCodedValue(medicationAdministrationXml.amountRemaining.unit[0]));
		}

        public function convertToXML():XML
		{
			var medicationAdministrationXml:XML = <MedicationAdministration/>;
			medicationAdministrationXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
            // TODO: Write a helper method for coded value to xml
            medicationAdministrationXml.name = name.text;
            medicationAdministrationXml.name.@type = name.type;
            medicationAdministrationXml.name.@value = name.value;
            medicationAdministrationXml.name.@abbrev = name.abbrev;
            medicationAdministrationXml.reportedBy = reportedBy;
            medicationAdministrationXml.dateOrdered = com.adobe.utils.DateUtil.toW3CDTF(dateReported);
            if (dateAdministered)
                medicationAdministrationXml.dateExpires = com.adobe.utils.DateUtil.toW3CDTF(dateAdministered);
            if (amountAdministered)
            {
                medicationAdministrationXml.amountOrdered.value = amountAdministered.value;
                medicationAdministrationXml.amountOrdered.unit = amountAdministered.unit.text;
                medicationAdministrationXml.amountOrdered.unit.@type = amountAdministered.unit.type;
                medicationAdministrationXml.amountOrdered.unit.@value = amountAdministered.unit.value;
                medicationAdministrationXml.amountOrdered.unit.@abbrev = amountAdministered.unit.abbrev;
            }
            if (amountRemaining)
            {
                medicationAdministrationXml.amountOrdered.value = amountAdministered.value;
                medicationAdministrationXml.amountOrdered.unit = amountAdministered.unit.text;
                medicationAdministrationXml.amountOrdered.unit.@type = amountAdministered.unit.type;
                medicationAdministrationXml.amountOrdered.unit.@value = amountAdministered.unit.value;
                medicationAdministrationXml.amountOrdered.unit.@abbrev = amountAdministered.unit.abbrev;
            }

			return medicationAdministrationXml;
		}

        public function get name():CodedValue
        {
            return _name;
        }

        public function set name(value:CodedValue):void
        {
            _name = value;
        }

        public function get reportedBy():String
        {
            return _reportedBy;
        }

        public function set reportedBy(value:String):void
        {
            _reportedBy = value;
        }

        public function get dateReported():Date
        {
            return _dateReported;
        }

        public function set dateReported(value:Date):void
        {
            _dateReported = value;
        }

        public function get dateAdministered():Date
        {
            return _dateAdministered;
        }

        public function set dateAdministered(value:Date):void
        {
            _dateAdministered = value;
        }

        public function get amountAdministered():ValueAndUnit
        {
            return _amountAdministered;
        }

        public function set amountAdministered(value:ValueAndUnit):void
        {
            _amountAdministered = value;
        }

        public function get amountRemaining():ValueAndUnit
        {
            return _amountRemaining;
        }

        public function set amountRemaining(value:ValueAndUnit):void
        {
            _amountRemaining = value;
        }
    }
}
