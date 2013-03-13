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
	public class CollaboRhythmValueAndUnit
	{
		private var _value:String;
		private var _textValue:String;
		private var _unit:CollaboRhythmCodedValue;
		
		public function CollaboRhythmValueAndUnit(value:String=null, unit:CollaboRhythmCodedValue=null, textValue:String=null)
		{
			_value = value;
			_unit = unit;
			_textValue = textValue;
		}

        public function get value():String
        {
            return _value;
        }

        public function set value(value:String):void
        {
            _value = value;
        }

        public function get unit():CollaboRhythmCodedValue
        {
            return _unit;
        }

        public function set unit(value:CollaboRhythmCodedValue):void
        {
            _unit = value;
        }

		public function get textValue():String
		{
			return _textValue;
		}

		public function set textValue(value:String):void
		{
			_textValue = value;
		}

		public function clone():CollaboRhythmValueAndUnit
		{
			return new CollaboRhythmValueAndUnit(value, unit, textValue);
		}

		public static function areEqual(a:CollaboRhythmValueAndUnit, b:CollaboRhythmValueAndUnit):Boolean
		{
			if (a == b)
				return true;
			if (a == null && b != null)
				return false;
			if (a != null && b == null)
				return false;
			return a.value == b.value && a.textValue == b.textValue && CollaboRhythmCodedValue.areEqual(a.unit, b.unit);
		}
	}
}