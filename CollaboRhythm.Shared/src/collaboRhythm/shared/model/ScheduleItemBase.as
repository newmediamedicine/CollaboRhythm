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

    [Bindable]
	public class ScheduleItemBase extends DocumentMetadata
	{
        private var _scheduleItemXml:XML;
		private var _name:CodedValue;
		private var _scheduledBy:String;
		private var _dateScheduled:Date;
        private var _dateStart:Date;
        private var _dateEnd:Date;
        private var _recurrenceRule:RecurrenceRule;
		private var _instructions:String;

		public function ScheduleItemBase():void
		{
		}

        public function init(name:CodedValue, scheduledBy:String, dateScheduled:Date, dateStart:Date, dateEnd:Date = null, recurrenceRule:RecurrenceRule = null, instructions:String = null):void
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
			parseDocumentMetadata(scheduleItemReportXml.Meta.Document[0], this);
            _scheduleItemXml = scheduleItemReportXml.Item.elements(scheduleItemElementName)[0];
			_name = HealthRecordHelperMethods.xmlToCodedValue(_scheduleItemXml.name[0]);
			_scheduledBy = _scheduleItemXml.scheduledBy;
			_dateScheduled = DateUtil.parseW3CDTF(_scheduleItemXml.dateScheduled.toString());
            _dateStart = DateUtil.parseW3CDTF(_scheduleItemXml.dateStart.toString());
            _dateEnd = DateUtil.parseW3CDTF(_scheduleItemXml.dateEnd.toString());
            _recurrenceRule = new RecurrenceRule(_scheduleItemXml.recurrenceRule[0]);
			_instructions = _scheduleItemXml.instructions;
		}

//		public function createScheduleItemClockView():ScheduleItemClockViewBase
//		{
//			// to be implemented by subclasses
//			var scheduleItemClockView:ScheduleItemClockViewBase = new ScheduleItemClockViewBase();
//			return scheduleItemClockView;
//		}
//
//		public function createScheduleItemReportingView():ScheduleItemReportingViewBase
//		{
//			// to be implemented by subclasses
//			var scheduleItemWidgetView:ScheduleItemReportingViewBase = new ScheduleItemReportingViewBase();
//			return scheduleItemWidgetView;
//		}
//
//		public function createScheduleItemTimelineView():ScheduleItemTimelineViewBase
//		{
//			// to be implemented by subclasses
//			var scheduleItemFullView:ScheduleItemTimelineViewBase = new ScheduleItemTimelineViewBase();
//			return scheduleItemFullView;
//		}

        public function get scheduleItemXml():XML
        {
            return _scheduleItemXml;
        }

        public function get name():CodedValue
        {
            return _name;
        }

        public function get scheduledBy():String
        {
            return _scheduledBy;
        }

        public function get dateScheduled():Date
        {
            return _dateScheduled;
        }

        public function get dateStart():Date
        {
            return _dateStart;
        }

        public function get dateEnd():Date
        {
            return _dateEnd;
        }

        public function get recurrenceRule():RecurrenceRule
        {
            return _recurrenceRule;
        }

        public function get instructions():String
        {
            return _instructions;
        }
    }
}