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
	import collaboRhythm.plugins.schedule.shared.view.FullScheduleItemViewBase;
	import collaboRhythm.plugins.schedule.shared.view.ScheduleItemWidgetViewBase;
	import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.HealthRecordServiceBase;

	[Bindable]
	public class ScheduleItemBase
	{
		private var _id:String;
		private var _name:CodedValue;
		private var _scheduledBy:String;
		private var _dateTimeScheduled:Date;
		private var _instructions:String;
//		private var _scheduledAction:String;

		public function ScheduleItemBase(documentID:String, scheduleItemXML:XML):void
		{
			_id = documentID;
			_name = HealthRecordHelperMethods.codedValueFromXml(scheduleItemXML.name[0]);
			_scheduledBy = scheduleItemXML.scheduledBy;
			_dateTimeScheduled = HealthRecordServiceBase.parseDate(scheduleItemXML.dateTimeScheduled.toString());
			_instructions = scheduleItemXML.instructions;
		}
		
		public function get id():String
		{
			return _id;
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