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
package collaboRhythm.workstation.model.settings
{
	import j2as3.collection.HashMap;

	public class WindowSettings
	{
		private var _fullScreen:Boolean;
		private var _windowStates:Vector.<WindowState> = new Vector.<WindowState>();
		private var _zoom:Number = 0;
		
		public function WindowSettings()
		{
		}

		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}

		public function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
		}

		public function get windowStates():Vector.<WindowState>
		{
			return _windowStates;
		}

		public function set windowStates(value:Vector.<WindowState>):void
		{
			_windowStates = value;
		}

		public function get zoom():Number
		{
			return _zoom;
		}

		public function set zoom(value:Number):void
		{
			_zoom = value;
		}


//		/**
//		 * Each container has an id (corresponding to it's purpose) and a window mapping (corresponding to where it exists in the visual hierarchy).  
//		 */
//		public function get containerWindowMappings():HashMap
//		{
//			return _containerWindowMappings;
//		}
//
//		/**
//		 * @private
//		 */
//		public function set containerWindowMappings(value:HashMap):void
//		{
//			_containerWindowMappings = value;
//		}

	}
}