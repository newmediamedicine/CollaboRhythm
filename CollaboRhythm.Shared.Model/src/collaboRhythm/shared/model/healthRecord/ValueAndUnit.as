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
package collaboRhythm.shared.model.healthRecord
{
    [Bindable]
	public class ValueAndUnit
	{
		private var _value:String;
		private var _unit:CodedValue;
		
		public function ValueAndUnit(value:String=null, unit:CodedValue=null)
		{
			_value = value;
			_unit = unit;
		}

        public function get value():String
        {
            return _value;
        }

        public function set value(value:String):void
        {
            _value = value;
        }

        public function get unit():CodedValue
        {
            return _unit;
        }

        public function set unit(value:CodedValue):void
        {
            _unit = value;
        }
    }
}