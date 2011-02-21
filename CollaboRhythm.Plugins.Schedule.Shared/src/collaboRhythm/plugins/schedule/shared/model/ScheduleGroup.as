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
	
	import com.adobe.utils.DateUtil;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DateField;

	public class ScheduleGroup extends DocumentMetadata
	{
		private var _id:String;
		private var _scheduledBy:String;
		private var _dateTimeScheduled:Date;
		private var _dateTimeStart:Date;
		private var _dateTimeEnd:Date;
		private var _recurrenceRule:RecurrenceRule;
		private var _scheduleItemIDs:Vector.<String> = new Vector.<String>;
		private var _scheduleItemsCollection:ArrayCollection = new ArrayCollection();
		
		public function ScheduleGroup(scheduleGroupReportXML:XML)
		{
			parseDocumentMetadata(scheduleGroupReportXML.Meta.Document[0], this);
			var scheduleGroupXML:XML = scheduleGroupReportXML.Item.ScheduleGroup[0];
			_scheduledBy = scheduleGroupXML.scheduledBy;
			_dateTimeScheduled = DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeScheduled.toString());
			_dateTimeStart = DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeStart.toString());
			_dateTimeEnd = DateUtil.parseW3CDTF(scheduleGroupXML.dateTimeEnd.toString());
			_recurrenceRule = new RecurrenceRule(scheduleGroupXML.recurrenceRule.frequency, Number(scheduleGroupXML.recurrenceRule.count))
			for each (var scheduleItemXML:XML in scheduleGroupReportXML.Meta.Document.relatesTo.relation.relatedDocument)
			{
				var scheduleItemID:String = scheduleItemXML.@id;
				_scheduleItemIDs.push(scheduleItemID);
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
		
		public function get scheduleItemIDs():Vector.<String>
		{
			return _scheduleItemIDs;
		}
		
		public function get scheduleItemsCollection():ArrayCollection
		{
			return _scheduleItemsCollection;
		}
		
		public function addScheduleItem(scheduleItem:ScheduleItemBase):void
		{
			_scheduleItemsCollection.addItem(scheduleItem);
		}
	}
}