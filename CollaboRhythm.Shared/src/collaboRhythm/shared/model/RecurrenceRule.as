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

	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;

    [Bindable]
    public class RecurrenceRule
	{
		private var _frequency:String;
        private var _interval:int = 1;
		private var _dateUntil:Date;
		private var _count:int;
		
//		TODO: Implement with choice of dateUntil or count
		public function RecurrenceRule(recurrenceRuleXml:XML=null)
		{
			if (recurrenceRuleXml)
				initializeFromXml(recurrenceRuleXml);
		}

		protected function initializeFromXml(recurrenceRuleXml:XML):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			_frequency = recurrenceRuleXml.frequency;
            _interval = int(recurrenceRuleXml.interval);
//            _dateUntil = DateUtil.parseW3CDTF(recurrenceRuleXml.dateUntil);
			_count = int(recurrenceRuleXml.count);
		}


        public function get frequency():String
        {
            return _frequency;
        }

        public function set frequency(value:String):void
        {
            _frequency = value;
        }

        public function get interval():int
        {
            return _interval;
        }

        public function set interval(value:int):void
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