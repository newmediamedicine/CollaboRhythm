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
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import com.adobe.utils.DateUtil;

	import j2as3.collection.HashMap;

	[Bindable]
    public class ScheduleItemBase extends DocumentBase
    {
		/**
		 * From an EquipmentScheduleItem or MedicationScheduleItem to an AdherenceItem.
		 */
		public static const RELATION_TYPE_ADHERENCE_ITEM:String = "http://indivo.org/vocab/documentrels#adherenceItem";
		/**
		 * From an Equipment to an EquipmentScheduleItem or from a MedicationOrder to a MedicationScheduleItem.
		 */
		public static const RELATION_TYPE_SCHEDULE_ITEM:String = "http://indivo.org/vocab/documentrels#scheduleItem";

        public static const DAILY:String = "DAILY";

		private static const MILLISECONDS_IN_HOUR:Number = 1000 * 60 * 60;
		private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		private var _scheduleItemXml:XML;
		private var _name:CodedValue;
		private var _scheduledBy:String;
		private var _dateScheduled:Date;
		private var _dateStart:Date;
		private var _dateEnd:Date;
		private var _recurrenceRule:RecurrenceRule;
		private var _instructions:String;

        private var _adherenceItems:HashMap = new HashMap();
		private var _currentDateSource:ICurrentDateSource;

        public function ScheduleItemBase():void
        {
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function init(name:CodedValue, scheduledBy:String, dateScheduled:Date, dateStart:Date,
                             dateEnd:Date = null, recurrenceRule:RecurrenceRule = null, instructions:String = null,
                             adherenceItems:HashMap = null):void
        {
            _name = name;
            _scheduledBy = scheduledBy;
            _dateScheduled = dateScheduled;
            _dateStart = dateStart;
            _dateEnd = dateEnd;
            _recurrenceRule = recurrenceRule;
            _instructions = instructions;
            _adherenceItems = adherenceItems;
        }

		public function initFromReportXML(scheduleItemReportXml:XML, scheduleItemElementName:String):void
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            DocumentMetadata.parseDocumentMetadata(scheduleItemReportXml.Meta.Document[0], this.meta);
            _scheduleItemXml = scheduleItemReportXml.Item.elements(new QName(DocumentMetadata.INDIVO_DOCUMENTS_NAMESPACE, scheduleItemElementName))[0];
			_name = HealthRecordHelperMethods.xmlToCodedValue(_scheduleItemXml.name[0]);
            _scheduledBy = _scheduleItemXml.scheduledBy;
            _dateScheduled = collaboRhythm.shared.model.DateUtil.parseW3CDTF(_scheduleItemXml.dateScheduled.toString());
            _dateStart = collaboRhythm.shared.model.DateUtil.parseW3CDTF(_scheduleItemXml.dateStart.toString());
            _dateEnd = collaboRhythm.shared.model.DateUtil.parseW3CDTF(_scheduleItemXml.dateEnd.toString());
            _recurrenceRule = new RecurrenceRule(_scheduleItemXml.recurrenceRule[0]);
            _instructions = _scheduleItemXml.instructions;
            for each (var adherenceItemXml:XML in scheduleItemReportXml..relatesTo.relation.(@type == RELATION_TYPE_ADHERENCE_ITEM).relatedDocument)
            {
                _adherenceItems.put(adherenceItemXml.@id, null);
            }
        }

        public function createXmlDocument():XML
        {
            throw new Error("virtual function must be overridden in subclass");
        }

        public function addExtraXml(scheduleItemXml:XML):XML
        {
            throw new Error("virtual function must be overridden in subclass");
        }

        public function schedueItemType():String
        {
            throw new Error("virtual function must be overridden in subclass");
        }

        public function convertToXML():XML
        {
            var scheduleItemXml:XML = createXmlDocument();
            scheduleItemXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
            scheduleItemXml.name = name.text;
            scheduleItemXml.name.@type = name.type;
            scheduleItemXml.name.@value = name.value;
            scheduleItemXml.name.@abbrev = name.abbrev;
            scheduleItemXml.scheduledBy = scheduledBy;
            scheduleItemXml.dateScheduled = com.adobe.utils.DateUtil.toW3CDTF(dateScheduled);
            scheduleItemXml.dateStart = com.adobe.utils.DateUtil.toW3CDTF(dateStart);
            scheduleItemXml.dateEnd = com.adobe.utils.DateUtil.toW3CDTF(dateEnd);
            scheduleItemXml.recurrenceRule.frequency = recurrenceRule.frequency.text;
            scheduleItemXml.recurrenceRule.frequency.@type = recurrenceRule.frequency.type;
            scheduleItemXml.recurrenceRule.frequency.@value = recurrenceRule.frequency.value;
            scheduleItemXml.recurrenceRule.frequency.@abbrev = recurrenceRule.frequency.abbrev;
            scheduleItemXml.recurrenceRule.count = recurrenceRule.count;
            scheduleItemXml = addExtraXml(scheduleItemXml);
            scheduleItemXml.instructions = instructions;

            return scheduleItemXml;
        }

        public function rescheduleItem(dateScheduled:Date, dateStart:Date, dateEnd:Date):void
        {
			this.dateScheduled = dateScheduled;
			this.dateStart = dateStart;
			this.dateEnd = dateEnd;
			this.recurrenceRule.count = updateCount(this.dateStart, dateStart);
        }

        private function getFrequencyMilliseconds(frequency:String):int
        {
            var frequencyMilliseconds:int;
            switch (frequency)
            {
                case DAILY:
                    frequencyMilliseconds = MILLISECONDS_IN_DAY;
                    break;
            }
            return frequencyMilliseconds;
        }

        private function updateCount(dateStart:Date, dateStartUpdated:Date):int
        {
            var countCompleted:int = Math.floor((dateStartUpdated.time - dateStart.time) / getFrequencyMilliseconds(_recurrenceRule.frequency.text));
            return _recurrenceRule.count - countCompleted;
        }

        public function getScheduleActionId():String
        {
            throw new Error("virtual function must be overridden in subclass");
        }

		/**
		 * Returns all of the occurrences of the ScheduleItem for which the dateStart of the occurrence
		 * falls in the interval between the dateStart and dateEnd parameters. This is achieved by iterating through all
		 * of the occurrences represented by the ScheduleItem and checking to see if they fall in the range.
		 *
		 * @param dateStart Date specifying the start of the desired interval
		 * @param dateEnd Date specifying the end of the desired interval
		 * @return Vector of ScheduleItemOccurrence instances for which dateStart falls withing the desired interval
		 */
        public function getScheduleItemOccurrences(dateStart:Date, dateEnd:Date):Vector.<ScheduleItemOccurrence>
        {
            //TODO: Implement for the case that the recurrence rule uses until instead of count
            var scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
            var frequencyMilliseconds:int = getFrequencyMilliseconds(_recurrenceRule.frequency.text);
            for (var recurrenceIndex:int = 0; recurrenceIndex < _recurrenceRule.count; recurrenceIndex++)
            {
                var occurrenceDateStart:Date = new Date(_dateStart.time + frequencyMilliseconds * recurrenceIndex);
                if (occurrenceDateStart.time >= dateStart.time && occurrenceDateStart.time <= dateEnd.time)
                {
                    var occurrenceDateEnd:Date = new Date(_dateEnd.time + frequencyMilliseconds * recurrenceIndex);
                    var scheduleItemOccurrence:ScheduleItemOccurrence = new ScheduleItemOccurrence(this,
																								   occurrenceDateStart,
																								   occurrenceDateEnd,
																								   recurrenceIndex);
                    for each (var adherenceItem:AdherenceItem in _adherenceItems)
                    {
                        if (adherenceItem.recurrenceIndex == recurrenceIndex)
                        {
                            scheduleItemOccurrence.adherenceItem = adherenceItem;
                        }
                    }
                    scheduleItemOccurrencesVector.push(scheduleItemOccurrence);
                }
            }
            return scheduleItemOccurrencesVector;
        }

       public function get scheduleItemXml():XML
        {
            return _scheduleItemXml;
        }

        public function set scheduleItemXml(value:XML):void
        {
            _scheduleItemXml = value;
        }

        public function get name():CodedValue
        {
            return _name;
        }

        public function set name(value:CodedValue):void
        {
            _name = value;
        }

        public function get scheduledBy():String
        {
            return _scheduledBy;
        }

        public function set scheduledBy(value:String):void
        {
            _scheduledBy = value;
        }

        public function get dateScheduled():Date
        {
            return _dateScheduled;
        }

        public function set dateScheduled(value:Date):void
        {
            _dateScheduled = value;
        }

        public function get dateStart():Date
        {
            return _dateStart;
        }

        public function set dateStart(value:Date):void
        {
            _dateStart = value;
        }

        public function get dateEnd():Date
        {
            return _dateEnd;
        }

        public function set dateEnd(value:Date):void
        {
            _dateEnd = value;
        }

        public function get recurrenceRule():RecurrenceRule
        {
            return _recurrenceRule;
        }

        public function set recurrenceRule(value:RecurrenceRule):void
        {
            _recurrenceRule = value;
        }

        public function get instructions():String
        {
            return _instructions;
        }

        public function set instructions(value:String):void
        {
            _instructions = value;
        }

        public function get adherenceItems():HashMap
        {
            return _adherenceItems;
        }

        public function set adherenceItems(value:HashMap):void
        {
            _adherenceItems = value;
        }
    }
}