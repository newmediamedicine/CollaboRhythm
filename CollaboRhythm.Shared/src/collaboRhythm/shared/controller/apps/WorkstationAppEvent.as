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
package collaboRhythm.shared.controller.apps
{
	import flash.events.Event;
	
	import spark.primitives.Rect;
	
	public class WorkstationAppEvent extends Event
	{
		public static const SHOW_FULL_VIEW:String = "ShowFullView";
		private var _workstationAppController:WorkstationAppControllerBase;
		private var _startRect:Rect;
		private var _applicationName:String;
		
		public function WorkstationAppEvent(type:String, workstationAppController:WorkstationAppControllerBase=null, startRect:Rect=null, applicationName:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_workstationAppController = workstationAppController;
			_startRect = startRect;
			_applicationName = applicationName;
		}

		public function get applicationName():String
		{
			return _applicationName;
		}

		public function set applicationName(value:String):void
		{
			_applicationName = value;
		}

		public function get startRect():Rect
		{
			return _startRect;
		}

		public function set startRect(value:Rect):void
		{
			_startRect = value;
		}

		public function get workstationAppController():WorkstationAppControllerBase
		{
			return _workstationAppController;
		}

		public function set workstationAppController(value:WorkstationAppControllerBase):void
		{
			_workstationAppController = value;
		}

	}
}