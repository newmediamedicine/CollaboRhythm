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
package collaboRhythm.plugins.schedule.shared.model
{
	import castle.flexbridge.reflection.Void;
	
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

	public class ScheduleGroup extends DocumentMetadata
	{
		private var _id:String;
		private var _scheduledBy:String;
		private var _dateTimeScheduled:Date;
		private var _dateTimeStart:Date;
		private var _dateTimeEnd:Date;
		private var _recurrenceRule:RecurrenceRule;
		private var _scheduleItems:Vector.<String> = new Vector.<String>;
		
		public function ScheduleGroup(scheduleGroupReportXML:XML)
		{
			parseDocumentMetadata(scheduleGroupReportXML.Meta.Document[0], this);
			var scheduleGroupXML:XML = scheduleGroupReportXML.Item.ScheduleGroup[0];
			_scheduledBy = scheduleGroupXML.scheduledBy;
			_dateTimeScheduled = HealthRecordServiceBase.parseDate(scheduleGroupXML.dateTimeScheduled.toString());
			_dateTimeStart = HealthRecordServiceBase.parseDate(scheduleGroupXML.dateTimeStart.toString());
			_dateTimeEnd = HealthRecordServiceBase.parseDate(scheduleGroupXML.dateTimeEnd.toString());
			_recurrenceRule = new RecurrenceRule(scheduleGroupXML.recurrenceRule.frequency, Number(scheduleGroupXML.recurrenceRule.count))
			for each (var scheduleItemXML:XML in scheduleGroupReportXML.Meta.Document.relatesTo.relation.relatedDocument)
			{
				var scheduleItemID:String = scheduleItemXML.@id;
				_scheduleItems.push(scheduleItemID);
			}
		}

		public function get scheduledBy():String
		{
			return _scheduledBy;
		}

		public function get dateTimeScheduled():Date
		{
			return _dateTimeScheduled;
		}

		public function set dateTimeScheduled(value:Date):void
		{
			_dateTimeScheduled = value;
		}

		public function get dateTimeStart():Date
		{
			return _dateTimeStart;
		}

		public function get dateTimeEnd():Date
		{
			return _dateTimeEnd;
		}

		public function get recurrenceRule():RecurrenceRule
		{
			return _recurrenceRule;
		}
		
		public function get scheduleItems():Vector.<String>
		{
			return _scheduleItems;
		}
		
		public function addScheduleItem(scheduleItem:String):void
		{
			_scheduleItems.push(scheduleItem);
		}
	}
}