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

	/**
	 * Base class for ScheduleGroup. This was formerly used as a base class to ScheduleItemOccurrence, but not any more.
	 * TODO: rename or eliminate ScheduleItemOccurrenceBase because it is NOT a base clas for ScheduleItemOccurrence.
	 */
    [Bindable]
    public class ScheduleItemOccurrenceBase
    {
        private var _dateStart:Date;
        private var _dateEnd:Date;
        private var _dateCenter:Date;
        private var _moving:Boolean = false;
        private var _dateCenterPreMove:Date;
        private var _dateStartPreMove:Date;
        private var _dateEndPreMove:Date;
        private var _containerMouseDownX:Number;
        private var _containerMouseDownY:Number;
        private var _yPreMove:Number;
        private var _yPosition:Number;
        private var _scheduleGroupsStacked:Number;
        private var _scheduleItemsStacked:Number;
        private var _stackingUpdate:Boolean;
        private var _containerWidth:Number;
        private var _containerHeight:Number;

        public function ScheduleItemOccurrenceBase(dateStart:Date, dateEnd:Date)
        {
            _dateStart = dateStart;
            _dateEnd = dateEnd;
            _dateCenter = new Date(dateStart.time + (dateEnd.time - dateStart.time) / 2);
        }

        public function get dateStart():Date
        {
            return _dateStart;
        }

        public function set dateStart(value:Date):void
        {
            _dateStart = value;
            if (_moving)
            {
                dateEnd = new Date(_dateStart.time + (_dateEndPreMove.time - _dateStartPreMove.time));
            }
        }

        public function get dateEnd():Date
        {
            return _dateEnd;
        }

        public function set dateEnd(value:Date):void
        {
            _dateEnd = value;
        }

        public function get dateCenter():Date
        {
            return _dateCenter;
        }

        public function set dateCenter(value:Date):void
        {
            _dateCenter = value;
            if (_moving)
            {
                dateStart = new Date(_dateCenter.time - (_dateEndPreMove.time - _dateStartPreMove.time) / 2);
            }
        }

		public function get dateCenterValue():Number
		{
			return dateCenter.valueOf();
		}

		public function get moving():Boolean
        {
            return _moving;
        }

        public function set moving(value:Boolean):void
        {
            _moving = value;
        }

        public function get dateCenterPreMove():Date
        {
            return _dateCenterPreMove;
        }

        public function set dateCenterPreMove(value:Date):void
        {
            _dateCenterPreMove = value;
        }

        public function get dateStartPreMove():Date
        {
            return _dateStartPreMove;
        }

        public function set dateStartPreMove(value:Date):void
        {
            _dateStartPreMove = value;
        }

        public function get dateEndPreMove():Date
        {
            return _dateEndPreMove;
        }

        public function set dateEndPreMove(value:Date):void
        {
            _dateEndPreMove = value;
        }

        public function get containerMouseDownX():Number
        {
            return _containerMouseDownX;
        }

        public function set containerMouseDownX(value:Number):void
        {
            _containerMouseDownX = value;
        }

        public function get containerMouseDownY():Number
        {
            return _containerMouseDownY;
        }

        public function set containerMouseDownY(value:Number):void
        {
            _containerMouseDownY = value;
        }

        public function get yPreMove():Number
        {
            return _yPreMove;
        }

        public function set yPreMove(value:Number):void
        {
            _yPreMove = value;
        }

        public function get yPosition():Number
        {
            return _yPosition;
        }

        public function set yPosition(value:Number):void
        {
            _yPosition = value;
        }

        public function get scheduleGroupsStacked():Number
        {
            return _scheduleGroupsStacked;
        }

        public function set scheduleGroupsStacked(value:Number):void
        {
            _scheduleGroupsStacked = value;
        }

        public function get scheduleItemsStacked():Number
        {
            return _scheduleItemsStacked;
        }

        public function set scheduleItemsStacked(value:Number):void
        {
            _scheduleItemsStacked = value;
        }

        public function get stackingUpdated():Boolean
        {
            return _stackingUpdate;
        }

        public function set stackingUpdated(value:Boolean):void
        {
            _stackingUpdate = value;
        }

        public function get containerWidth():Number
        {
            return _containerWidth;
        }

        public function set containerWidth(value:Number):void
        {
            _containerWidth = value;
        }

        public function get containerHeight():Number
        {
            return _containerHeight;
        }

        public function set containerHeight(value:Number):void
        {
            _containerHeight = value;
        }
    }
}
