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
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemFullViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemWidgetViewBase;
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

	[Bindable]
	public class ScheduleItemBase extends DocumentMetadata
	{
		protected var _scheduleItemXML:XML
		private var _name:CodedValue;
		private var _scheduledBy:String;
		private var _dateTimeScheduled:Date;
		private var _instructions:String;
//		private var _scheduledAction:String;

		public function ScheduleItemBase(scheduleItemReportXML:XML, scheduleItemElementName:String):void
		{
			parseDocumentMetadata(scheduleItemReportXML.Meta.Document[0], this);
			_scheduleItemXML = scheduleItemReportXML.Item.elements(scheduleItemElementName)[0];
			_name = HealthRecordHelperMethods.codedValueFromXml(_scheduleItemXML.name[0]);
			_scheduledBy = _scheduleItemXML.scheduledBy;
			_dateTimeScheduled = DateUtil.parseW3CDTF(_scheduleItemXML.dateTimeScheduled.toString());
			_instructions = _scheduleItemXML.instructions;
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
		
		public function createScheduleItemWidgetView():ScheduleItemWidgetViewBase
		{
			// to be implemented by subclasses
			var scheduleItemWidgetView:ScheduleItemWidgetViewBase = new ScheduleItemWidgetViewBase();
			return scheduleItemWidgetView;
		}
		
		public function createScheduleItemFullView():ScheduleItemFullViewBase
		{
			// to be implemented by subclasses
			var fullScheduleItemView:ScheduleItemFullViewBase = new ScheduleItemFullViewBase();
			return fullScheduleItemView;
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