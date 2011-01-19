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
	import flash.display.NativeWindowDisplayState;
	import flash.geom.Rectangle;
	
	import mx.core.Window;

	public class WindowState
	{
		private var _displayState:String;
		private var _bounds:Rectangle;
		private var _componentLayouts:Vector.<ComponentLayout> = new Vector.<ComponentLayout>();
		
		private var _spaces:Vector.<String> = new Vector.<String>();		
		
		public function WindowState()
		{
		}

		public function get componentLayouts():Vector.<ComponentLayout>
		{
			return _componentLayouts;
		}

		public function set componentLayouts(value:Vector.<ComponentLayout>):void
		{
			_componentLayouts = value;
		}

		public function get displayState():String
		{
			return _displayState;
		}

		public function set displayState(value:String):void
		{
			_displayState = value;
		}

		/**
		 * IDs of the spaces in this window. 
		 */
		public function get spaces():Vector.<String>
		{
			return _spaces;
		}

		public function set spaces(value:Vector.<String>):void
		{
			_spaces = value;
		}

		public function get isMinimized():Boolean
		{
			return _displayState == NativeWindowDisplayState.MINIMIZED;
		}
		
		public function get isMaximized():Boolean
		{
			return _displayState == NativeWindowDisplayState.MAXIMIZED;
		}
		
		public function get bounds():Rectangle
		{
			return _bounds;
		}

		public function set bounds(value:Rectangle):void
		{
			_bounds = value;
		}
	}
}