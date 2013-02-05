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
	public class CodedValue
	{
		private var _title:String;
		private var _system:String;
		private var _identifier:String;

		public function CodedValue(title:String=null, system:String=null, identifier:String=null)
		{
			_title = title;
			_system = system;
			_identifier = identifier;
		}

        public function get system():String
        {
            return _system;
        }

        public function set system(value:String):void
        {
            _system = value;
        }

        public function get identifier():String
        {
            return _identifier;
        }

        public function set identifier(value:String):void
        {
            _identifier = value;
        }

        public function get title():String
        {
            return _title;
        }

        public function set title(value:String):void
        {
            _title = value;
        }

		public function clone():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(title, system, identifier);
		}
    }
}