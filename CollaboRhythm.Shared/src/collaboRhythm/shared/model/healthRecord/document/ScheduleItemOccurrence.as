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

	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;

	[Bindable]
    public class ScheduleItemOccurrence
    {
        private var _id:String;
        private var _dateStart:Date;
        private var _dateEnd:Date;
        private var _recurrenceIndex:int;
        private var _scheduleItem:ScheduleItemBase;
        private var _adherenceItem:AdherenceItem;
        private var _moving:Boolean;
        private var _yPosition:int;

        public function get yPosition():int
        {
            return _yPosition;
        }

        public function set yPosition(value:int):void
        {
            _yPosition = value;
        }

        public function ScheduleItemOccurrence(dateStart:Date, dateEnd:Date, recurrenceIndex:int)
        {
            _dateStart = dateStart;
            _dateEnd = dateEnd;
            _recurrenceIndex = recurrenceIndex;
        }

        public function get recurrenceIndex():int
        {
            return _recurrenceIndex;
        }

        public function set recurrenceIndex(value:int):void
        {
            _recurrenceIndex = value;
        }

        public function get scheduleItem():ScheduleItemBase
        {
            return _scheduleItem;
        }

        public function set scheduleItem(value:ScheduleItemBase):void
        {
            _scheduleItem = value;
        }

        public function get adherenceItem():AdherenceItem
        {
            return _adherenceItem;
        }

        public function set adherenceItem(value:AdherenceItem):void
        {
            _adherenceItem = value;
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

        public function get moving():Boolean
        {
            return _moving;
        }

        public function set moving(value:Boolean):void
        {
            _moving = value;
        }
    }
}
