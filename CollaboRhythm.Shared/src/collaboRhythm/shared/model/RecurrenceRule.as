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

    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;

    [Bindable]
    public class RecurrenceRule
	{
		private var _frequency:CodedValue;
        private var _interval:CodedValue;
		private var _dateUntil:Date;
		private var _count:int;
		
//		TODO: Implement with choice of dateTimeUntil or count
		public function RecurrenceRule(recurrenceRuleXml:XML)
		{
			_frequency = HealthRecordHelperMethods.xmlToCodedValue(recurrenceRuleXml.frequency[0]);
//            _interval = HealthRecordHelperMethods.xmlToCodedValue(recurrenceRuleXml.interval[0]);
//            _dateUntil = DateUtil.parseW3CDTF(recurrenceRuleXml.dateUntil);
			_count = int(recurrenceRuleXml.count);
		}


        public function get frequency():CodedValue
        {
            return _frequency;
        }

        public function set frequency(value:CodedValue):void
        {
            _frequency = value;
        }

        public function get interval():CodedValue
        {
            return _interval;
        }

        public function set interval(value:CodedValue):void
        {
            _interval = value;
        }

        public function get dateUntil():Date
        {
            return _dateUntil;
        }

        public function set dateUntil(value:Date):void
        {
            _dateUntil = value;
        }

        public function get count():int
        {
            return _count;
        }

        public function set count(value:int):void
        {
            _count = value;
        }
    }
}