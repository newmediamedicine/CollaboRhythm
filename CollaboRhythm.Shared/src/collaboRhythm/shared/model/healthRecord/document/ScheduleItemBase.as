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
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import com.adobe.utils.DateUtil;

	import flash.utils.getQualifiedClassName;

	import j2as3.collection.HashMap;

	import mx.logging.ILogger;
	import mx.logging.Log;

	[Bindable]
	public class ScheduleItemBase extends DocumentBase
	{
		/**
		 * From an HealthActionSchedule or MedicationScheduleItem to an AdherenceItem.
		 */
		public static const RELATION_TYPE_ADHERENCE_ITEM:String = "http://indivo.org/vocab/documentrels#adherenceItem";
		public static const RELATION_TYPE_OCCURRENCE:String = "http://indivo.org/vocab/documentrels#occurrence";
		/**
		 * From an Equipment to an HealthActionSchedule or from a MedicationOrder to a MedicationScheduleItem.
		 */
		public static const RELATION_TYPE_SCHEDULE_ITEM:String = "http://indivo.org/vocab/documentrels#scheduleItem";


		public static const DAILY:String = "DAILY";
		public static const HOURLY:String = "HOURLY";
		private static const MILLISECONDS_IN_HOUR:Number = 1000 * 60 * 60;
		public static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

		private var _currentDateSource:ICurrentDateSource;
		private var _scheduleItemXml:XML;
		private var _name:CodedValue;
		private var _scheduledBy:String;
		private var _dateScheduled:Date;
		private var _dateStart:Date;
		private var _dateEnd:Date;
		private var _recurrenceRule:RecurrenceRule;

		private var _instructions:String;

		private var _logger:ILogger;
		private const _logGetScheduleItemOccurrences:Boolean = true;

		public function ScheduleItemBase():void
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function init(name:CodedValue, scheduledBy:String, dateScheduled:Date, dateStart:Date,
							 dateEnd:Date = null, recurrenceRule:RecurrenceRule = null, instructions:String = null):void
		{
			_name = name;
			_scheduledBy = scheduledBy;
			_dateScheduled = dateScheduled;
			_dateStart = dateStart;
			_dateEnd = dateEnd;
			_recurrenceRule = recurrenceRule;
			_instructions = instructions;
		}

		public function initFromReportXML(scheduleItemReportXml:XML, scheduleItemElementName:String):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			DocumentMetadata.parseDocumentMetadata(scheduleItemReportXml.Meta.Document[0], this.meta);
			_scheduleItemXml = scheduleItemReportXml.Item.elements(new QName(DocumentMetadata.INDIVO_DOCUMENTS_NAMESPACE,
																			 scheduleItemElementName))[0];
			_name = HealthRecordHelperMethods.xmlToCodedValue(_scheduleItemXml.name[0]);
			_scheduledBy = _scheduleItemXml.scheduledBy;
			_dateScheduled = collaboRhythm.shared.model.DateUtil.parseW3CDTF(_scheduleItemXml.dateScheduled.toString());
			_dateStart = collaboRhythm.shared.model.DateUtil.parseW3CDTF(_scheduleItemXml.dateStart.toString());
			_dateEnd = collaboRhythm.shared.model.DateUtil.parseW3CDTF(_scheduleItemXml.dateEnd.toString());
			_recurrenceRule = new RecurrenceRule(_scheduleItemXml.recurrenceRule[0]);
			_instructions = _scheduleItemXml.instructions;
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
			//TODO: Refactor so that this works for all recurrence intervals
			switch (frequency)
			{
				case DAILY:
					frequencyMilliseconds = MILLISECONDS_IN_DAY;
					break;
				case HOURLY:
					frequencyMilliseconds = MILLISECONDS_IN_HOUR;
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
		 * of the occurrences represented by the ScheduleItem and checking to see if they fall in the range. This function
		 * also ensures that a reference to the AdherenceItem with the matching recurrenceIndex is added to each of the
		 * occurrences. If more than one AdherenceItem matches, then that information is logged and a reference is only
		 * added for the most recent AdherenceItem.
		 *
		 * @param dateStart Date specifying the start of the desired interval
		 * @param dateEnd Date specifying the end of the desired interval
		 * @return Vector of ScheduleItemOccurrence instances for which dateStart falls withing the desired interval
		 */
		public function getScheduleItemOccurrences(dateStart:Date = null, dateEnd:Date = null):Vector.<ScheduleItemOccurrence>
		{
			//TODO: Implement for the case that the recurrence rule uses until instead of count
			var scheduleItemOccurrencesVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			var interval:CodedValue = _recurrenceRule.interval;
			var frequencyMilliseconds:int;
			if (interval)
				frequencyMilliseconds = getFrequencyMilliseconds(_recurrenceRule.frequency.text) * int(_recurrenceRule.interval.text);
			else
				frequencyMilliseconds = getFrequencyMilliseconds(_recurrenceRule.frequency.text);
			var excludeOccurrencesBecauseReplaced:int = -1;
			for (var recurrenceIndex:int = 0; recurrenceIndex < _recurrenceRule.count; recurrenceIndex++)
			{
				var occurrenceDateStart:Date = new Date(_dateStart.time + frequencyMilliseconds * recurrenceIndex);
				if (meta.replacedBy != null)
				{
					var replacedByScheduleItem:ScheduleItemBase = meta.replacedBy as ScheduleItemBase;
					if (occurrenceDateStart.time >= replacedByScheduleItem.dateStart.time)
					{
						// newer schedule item replaces this one, so ignore this and subsequent occurrences
						excludeOccurrencesBecauseReplaced = recurrenceIndex;
						break;
					}
				}

				if ((dateStart == null || occurrenceDateStart.time >= dateStart.time) && (dateEnd == null || occurrenceDateStart.time <= dateEnd.time))
				{
					var occurrenceDateEnd:Date = new Date(_dateEnd.time + frequencyMilliseconds * recurrenceIndex);
					var scheduleItemOccurrence:ScheduleItemOccurrence = new ScheduleItemOccurrence(this,
																								   occurrenceDateStart,
																								   occurrenceDateEnd,
																								   recurrenceIndex);
					var matchingAdherenceItems:Vector.<AdherenceItem> = new Vector.<AdherenceItem>();
					for each (var adherenceItem:AdherenceItem in adherenceItems)
					{
						if (adherenceItem && adherenceItem.recurrenceIndex == recurrenceIndex)
						{
							matchingAdherenceItems.push(adherenceItem);
						}
					}
					if (matchingAdherenceItems.length > 0)
					{
						// Normally, outside of testing scenarios, there should only be one AdherenceItem corresponding
						// to each ScheduleItemOccurrence recurrenceIndex. If there is more than one matching AdherenceItem
						// log this and the sort the matching AdherenceItem documents by createdAt date in the metaData
						// rather than by dateReported because, in testing scenarios, it is possible that the dateReported
						// does not correspond correlate with the most recently created Document.
						if (matchingAdherenceItems.length > 1)
						{
							_logger.info("Multiple matchingAdherenceItems (" + matchingAdherenceItems.length + ") found for " + scheduleItemOccurrence.scheduleItem.name.text + ". recurrenceIndex: " + recurrenceIndex + ";  date: " + occurrenceDateStart);
							matchingAdherenceItems.sort(compareDocumentsByCreatedAtValue);
						}
						scheduleItemOccurrence.adherenceItem = matchingAdherenceItems[0];
					}

					scheduleItemOccurrencesVector.push(scheduleItemOccurrence);
				}
			}
			if (_logGetScheduleItemOccurrences)
			{
				_logger.debug("getScheduleItemOccurrences got " + scheduleItemOccurrencesVector.length +
						" occurrences for " + this.name.text + " " + this.dateStart.toLocaleString() + " to " +
						new Date(_dateStart.time + frequencyMilliseconds * _recurrenceRule.count).toLocaleString() +
						((dateStart != null && dateEnd != null) ? (" in range " + dateStart.toLocaleString() + " to " +
								dateEnd.toLocaleString()) : "")
						+ ". Recurrence count " + _recurrenceRule.count + " excludeOccurrencesBecauseReplaced " +
						excludeOccurrencesBecauseReplaced + " replacedById " + meta.replacedById +
						(this as MedicationScheduleItem ? " order " +
								(this as MedicationScheduleItem).scheduledMedicationOrder : ""));
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

		public function get adherenceItems():Vector.<AdherenceItem>
		{
			var adherenceItems:Vector.<AdherenceItem> = new Vector.<AdherenceItem>();
			for each (var relationship:Relationship in relatesTo)
			{
				// relatesTo may be null if the related document is replaced or voided or fails to be loaded for some other reason
				if (relationship.type == RELATION_TYPE_ADHERENCE_ITEM && relationship.relatesTo != null)
				{
					adherenceItems.push(relationship.relatesTo);
				}
			}
			return adherenceItems;
		}
	}
}