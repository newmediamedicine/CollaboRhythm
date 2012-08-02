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

	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;

    [Bindable]
    public class MedicationFill extends DocumentBase
    {
		public static const DOCUMENT_TYPE:String = "http://indivo.org/vocab/xml/documents#MedicationFill";
        private var _name:CodedValue;
        private var _filledBy:String;
        private var _dateFilled:Date;
        private var _amountFilled:ValueAndUnit;
        private var _ndc:CodedValue;
        private var _fillSequenceNumber:int;
        private var _lotNumber:int;
        private var _refillsRemaining:int;
        private var _instructions:String;

        private var _currentDateSource:ICurrentDateSource;

        public function MedicationFill()
        {
			meta.type = DOCUMENT_TYPE;
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function init(name:CodedValue, filledBy:String, dateFilled:Date, amountFilled:ValueAndUnit = null, ndc:CodedValue = null, fillSequenceNumber:int = 0, lotNumber:int = 0, refillsRemaining:int = 0, instructions:String = null):void
		{
			_name = name;
            _filledBy = filledBy;
            _dateFilled = dateFilled;
            _amountFilled = amountFilled;
            _ndc = ndc;
            _fillSequenceNumber = fillSequenceNumber;
            _lotNumber = lotNumber;
            _refillsRemaining = refillsRemaining;
            _instructions = instructions;
		}

		public function initFromReportXML(medicationFillReportXml:XML):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			DocumentMetadata.parseDocumentMetadata(medicationFillReportXml.Meta.Document[0], this.meta);
			var medicationFillXml:XML = medicationFillReportXml.Item.MedicationOrder[0];
            _name = HealthRecordHelperMethods.xmlToCodedValue(medicationFillXml.name[0]);
            _filledBy = medicationFillXml.filledBy;
            _dateFilled = DateUtil.parseW3CDTF(medicationFillXml.dateFilled.toString());
            _amountFilled = new ValueAndUnit(medicationFillXml.amountFilled.value, HealthRecordHelperMethods.xmlToCodedValue(medicationFillXml.amountFilled.unit[0]));
            _ndc = HealthRecordHelperMethods.xmlToCodedValue(medicationFillXml.ndc[0]);
            _fillSequenceNumber = int(medicationFillXml.fillSequenceNumber);
            _lotNumber = int(medicationFillXml.lotNumber);
            _refillsRemaining = int(medicationFillXml.refills);
            _instructions = medicationFillXml.instructions;
		}

//        public function convertToXML():XML
//		{
            // TODO: Marshal to xml
//			var medicationOrderXml:XML = <MedicationOrder/>;
//			medicationOrderXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
//            // TODO: Write a helper method for coded value to xml, but this may be moot if a schema will be used for marshaling and unmarshaling
//            medicationOrderXml.name = name.text;
//            medicationOrderXml.name.@type = name.type;
//            medicationOrderXml.name.@value = name.value;
//            medicationOrderXml.name.@abbrev = name.abbrev;
//            medicationOrderXml.orderType = orderType;
//            medicationOrderXml.orderedBy = filledBy;
//            medicationOrderXml.dateOrdered = com.adobe.utils.DateUtil.toW3CDTF(dateFilled);
//            if (dateExpires)
//                medicationOrderXml.dateExpires = com.adobe.utils.DateUtil.toW3CDTF(dateExpires);
//            if (indication)
//                medicationOrderXml.indication = indication;
//            if (amountFilled)
//            {
//                medicationOrderXml.amountOrdered.value = amountFilled.value;
//                medicationOrderXml.amountOrdered.unit = amountFilled.unit.text;
//                medicationOrderXml.amountOrdered.unit.@type = amountFilled.unit.type;
//                medicationOrderXml.amountOrdered.unit.@value = amountFilled.unit.value;
//                medicationOrderXml.amountOrdered.unit.@abbrev = amountFilled.unit.abbrev;
//            }
//            if (refillsRemaining)
//                medicationOrderXml.refills = refillsRemaining.toString();
//            if (substitutionPermitted)
//                medicationOrderXml.substitutionPermitted = HealthRecordHelperMethods.booleanToString(substitutionPermitted);
//            if (instructions)
//                medicationOrderXml.instructions = instructions;
//
//			return medicationOrderXml;
//		}


        public function get name():CodedValue
        {
            return _name;
        }

        public function set name(value:CodedValue):void
        {
            _name = value;
        }

        public function get filledBy():String
        {
            return _filledBy;
        }

        public function set filledBy(value:String):void
        {
            _filledBy = value;
        }

        public function get dateFilled():Date
        {
            return _dateFilled;
        }

        public function set dateFilled(value:Date):void
        {
            _dateFilled = value;
        }

        public function get amountFilled():ValueAndUnit
        {
            return _amountFilled;
        }

        public function set amountFilled(value:ValueAndUnit):void
        {
            _amountFilled = value;
        }

        public function get ndc():CodedValue
        {
            return _ndc;
        }

        public function set ndc(value:CodedValue):void
        {
            _ndc = value;
        }

        public function get fillSequenceNumber():int
        {
            return _fillSequenceNumber;
        }

        public function set fillSequenceNumber(value:int):void
        {
            _fillSequenceNumber = value;
        }

        public function get lotNumber():int
        {
            return _lotNumber;
        }

        public function set lotNumber(value:int):void
        {
            _lotNumber = value;
        }

        public function get refillsRemaining():int
        {
            return _refillsRemaining;
        }

        public function set refillsRemaining(value:int):void
        {
            _refillsRemaining = value;
        }

        public function get instructions():String
        {
            return _instructions;
        }

        public function set instructions(value:String):void
        {
            _instructions = value;
        }

        public function get currentDateSource():ICurrentDateSource
        {
            return _currentDateSource;
        }

        public function set currentDateSource(value:ICurrentDateSource):void
        {
            _currentDateSource = value;
        }
    }
}
