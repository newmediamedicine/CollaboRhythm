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
package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	public class MoveData
	{
		private var _id:String;
		private var _objectMouseX:Number;
		private var _objectMouseY:Number;
		private var _containerMouseX:Number;
		private var _containerMouseY:Number;
		private var _containerWidth:Number;
		private var _containerHeight:Number;
		private var _hour:Number;
		private var _xPosition:Number;
		private var _yBottomPosition:Number;
		private var _adherenceWindow:Number;
		private var _color:uint;
		private var _itemIndex:Number;
		
		public function MoveData()
		{
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function set id(value:String):void
		{
			_id = value;
		}
		
		public function get objectMouseX():Number
		{
			return _objectMouseX;
		}
		
		public function set objectMouseX(value:Number):void
		{
			_objectMouseX = value;
		}
		
		public function get objectMouseY():Number
		{
			return _objectMouseY;
		}
		
		public function set objectMouseY(value:Number):void
		{
			_objectMouseY = value;
		}

		public function get containerMouseX():Number
		{
			return _containerMouseX;
		}
		
		public function set containerMouseX(value:Number):void
		{
			_containerMouseX = value;
		}
		
		public function get containerMouseY():Number
		{
			return _containerMouseY;
		}
		
		public function set containerMouseY(value:Number):void
		{
			_containerMouseY = value;
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
		
		public function get hour():Number
		{
			return _hour;
		}

		public function set hour(value:Number):void
		{
			_hour = value;
		}

		public function get yBottomPosition():Number
		{
			return _yBottomPosition;
		}

		public function set yBottomPosition(value:Number):void
		{
			_yBottomPosition = value;
		}

		public function get xPosition():Number
		{
			return _xPosition;
		}

		public function set xPosition(value:Number):void
		{
			_xPosition = value;
		}

		public function get itemIndex():Number
		{
			return _itemIndex;
		}

		public function set itemIndex(value:Number):void
		{
			_itemIndex = value;
		}


		
		public function get adherenceWindow():Number
		{
			return _adherenceWindow;
		}
		
		public function set adherenceWindow(value:Number):void
		{
			_adherenceWindow = value;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}

	}
}