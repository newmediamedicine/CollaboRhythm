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
package collaboRhythm.plugins.diary.model
{
import flash.utils.ByteArray;

public class PainEntry
	{

        private var _date:Date;
        private var _value:Number;
        private var _byteData:ByteArray;
        private var _description:String;


        public function PainEntry(date:Date, value:Number, data:ByteArray, description:String) {
            _date = date;
            _value = value;
            _byteData = data;
            _description = description;
        }
        public function get date():Date {
            return _date;
        }
        public function get text():Number {
            return _value;
        }
        public function get byteData():ByteArray{
            return _byteData;
/*
            access with: SWFLoader.load(imageByteArray);
*/

        }
        public function get description():String {
            return _description;
        }

	}
}
