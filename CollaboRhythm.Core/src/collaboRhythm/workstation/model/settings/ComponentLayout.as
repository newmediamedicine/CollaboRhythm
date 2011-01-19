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
package collaboRhythm.workstation.model.settings
{
	public class ComponentLayout
	{
		private var _id:String;
		private var _percentWidth:Number;
		private var _percentHeight:Number;

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get percentWidth():Number
		{
			return _percentWidth;
		}

		public function set percentWidth(value:Number):void
		{
			_percentWidth = value;
		}

		public function get percentHeight():Number
		{
			return _percentHeight;
		}

		public function set percentHeight(value:Number):void
		{
			_percentHeight = value;
		}
		
		public function ComponentLayout(id:String, percentWidth:Number, percentHeight:Number)
		{
			_id = id;
			_percentWidth = percentWidth;
			_percentHeight = percentHeight;
		}
	}
}