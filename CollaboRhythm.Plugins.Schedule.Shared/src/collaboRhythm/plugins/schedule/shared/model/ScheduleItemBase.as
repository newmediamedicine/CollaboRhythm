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
package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

	[Bindable]
	public class ScheduleItemBase extends DocumentMetadata
	{
		private var _scheduleItemXML:XML
		private var _name:CodedValue;
		private var _scheduledBy:String;
		private var _dateTimeScheduled:Date;
		private var _instructions:String;
		private var _adherenceItemID:String;
		private var _adherenceItem:AdherenceItem;
		
		public function ScheduleItemBase(scheduleItemReportXML:XML, scheduleItemElementName:String):void
		{
			parseDocumentMetadata(scheduleItemReportXML.Meta.Document[0], this);
			_scheduleItemXML = scheduleItemReportXML.Item.elements(scheduleItemElementName)[0];
			_name = HealthRecordHelperMethods.codedValueFromXml(_scheduleItemXML.name[0]);
			_scheduledBy = _scheduleItemXML.scheduledBy;
			_dateTimeScheduled = DateUtil.parseW3CDTF(_scheduleItemXML.dateTimeScheduled.toString());
			_instructions = _scheduleItemXML.instructions;
		}
		
		public function get scheduleItemXML():XML
		{
			return _scheduleItemXML;
		}
		
		public function get name():CodedValue
		{
			return _name;
		}

		public function get scheduledBy():String
		{
			return _scheduledBy;
		}

		public function get dateTimeScheduled():Date
		{
			return _dateTimeScheduled;
		}

		public function get instructions():String
		{
			return _instructions;
		}
		
		public function get adherenceItem():AdherenceItem
		{
			return _adherenceItem;
		}
		
		public function set adherenceItem(value:AdherenceItem):void
		{
			_adherenceItem = value;
		}
		
		public function createScheduleItemClockView():ScheduleItemClockViewBase
		{
			// to be implemented by subclasses
			var scheduleItemClockView:ScheduleItemClockViewBase = new ScheduleItemClockViewBase();
			return scheduleItemClockView;
		}
		
		public function createScheduleItemReportingView():ScheduleItemReportingViewBase
		{
			// to be implemented by subclasses
			var scheduleItemWidgetView:ScheduleItemReportingViewBase = new ScheduleItemReportingViewBase();
			return scheduleItemWidgetView;
		}
		
		public function createScheduleItemTimelineView():ScheduleItemTimelineViewBase
		{
			// to be implemented by subclasses
			var scheduleItemFullView:ScheduleItemTimelineViewBase = new ScheduleItemTimelineViewBase();
			return scheduleItemFullView;
		}
		
//		public function get scheduledAction():String
//		{
//			return _scheduledAction;
//		}
//		
//		public function set scheduledAction(value:String):void
//		{
//			_scheduledAction = value;
//		}
	}
}