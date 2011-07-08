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
		private var _localX:Number;
		private var _localY:Number;
        private var _stageX:Number;
        private var _stageY:Number;
		private var _containerX:Number;
		private var _containerY:Number;
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
		
		public function get localX():Number
		{
			return _localX;
		}
		
		public function set localX(value:Number):void
		{
			_localX = value;
		}
		
		public function get localY():Number
		{
			return _localY;
		}
		
		public function set localY(value:Number):void
		{
			_localY = value;
		}

		public function get containerX():Number
		{
			return _containerX;
		}

        public function get stageX():Number
        {
            return _stageX;
        }

        public function set stageX(value:Number):void
        {
            _stageX = value;
        }

        public function get stageY():Number
        {
            return _stageY;
        }

        public function set stageY(value:Number):void
        {
            _stageY = value;
        }

        public function set containerX(value:Number):void
		{
			_containerX = value;
		}
		
		public function get containerY():Number
		{
			return _containerY;
		}
		
		public function set containerY(value:Number):void
		{
			_containerY = value;
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