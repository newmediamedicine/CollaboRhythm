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
    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;

    import collaboRhythm.shared.model.DateUtil;
    import com.adobe.utils.DateUtil;

    [Bindable]
	public class AdherenceItem extends DocumentMetadata
	{
		private var _name:CodedValue;
		private var _reportedBy:String;
		private var _dateReported:Date;
        private var _recurrenceIndex:int;
		private var _adherence:Boolean;
		private var _nonadherenceReason:String;

		public function AdherenceItem()
		{
		}

		public function init(name:CodedValue, reportedBy:String, dateReported:Date, recurrendIndex:int,  adherence:Boolean, nonadherenceReason:String = null):void
		{
			_name = name;
			_reportedBy = reportedBy;
			_dateReported = dateReported;
            _recurrenceIndex = recurrendIndex;
			_adherence = adherence;
			_nonadherenceReason = nonadherenceReason;
		}
		
		public function initFromReportXML(adherenceItemReportXML:XML):void
		{
			parseDocumentMetadata(adherenceItemReportXML.Meta.Document[0], this);
			var adherenceItemXml:XML = adherenceItemReportXML.Item.AdherenceItem[0];
			_name = HealthRecordHelperMethods.xmlToCodedValue(adherenceItemXml.name[0]);
			_reportedBy = adherenceItemXml.reportedBy;
            _dateReported = collaboRhythm.shared.model.DateUtil.parseW3CDTF(adherenceItemXml.dateReported);
            _recurrenceIndex = int(adherenceItemXml.recurrenceIndex);
			_adherence = HealthRecordHelperMethods.stringToBoolean(adherenceItemXml.adherence);
			_nonadherenceReason = adherenceItemXml.nonadherenceReason;
		}

        public function convertToXML():XML
		{
			var adherenceItemXml:XML = <AdherenceItem/>;
			adherenceItemXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
            // TODO: Write a helper method for coded value to xml
            adherenceItemXml.name = name.text;
            adherenceItemXml.name.@type = name.type;
            adherenceItemXml.name.@value = name.value;
            adherenceItemXml.name.@abbrev = name.abbrev;
            adherenceItemXml.reportedBy = reportedBy;
            adherenceItemXml.dateReported = com.adobe.utils.DateUtil.toW3CDTF(dateReported);
            adherenceItemXml.recurrenceIndex = recurrenceIndex.toString();
            adherenceItemXml.adherence = HealthRecordHelperMethods.booleanToString(adherence);
            if (nonadherenceReason)
                adherenceItemXml.nonadherenceReason = nonadherenceReason;

			return adherenceItemXml;
		}

        public function get name():CodedValue
        {
            return _name;
        }

        public function get reportedBy():String
        {
            return _reportedBy;
        }

        public function get dateReported():Date
        {
            return _dateReported;
        }

        public function get recurrenceIndex():int
        {
            return _recurrenceIndex;
        }

        public function get adherence():Boolean
        {
            return _adherence;
        }

        public function get nonadherenceReason():String
        {
            return _nonadherenceReason;
        }
    }
}