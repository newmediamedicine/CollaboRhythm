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

	public class AppEvent extends Event
	{
		public static const SHOW_FULL_VIEW:String = "ShowFullView";
        public static const HIDE_FULL_VIEW:String = "HideFullView";
        public static const ALLOW_HIDE_FULL_VIEW_ON_BACK:String = "HideFullViewOnBack";
        public static const PREVENT_HIDE_FULL_VIEW_ON_BACK:String = "NoActionOnBack";

		private var _workstationAppController:WorkstationAppControllerBase;
		private var _startRect:Rect;
		private var _applicationName:String;
		private var _viaMechanism:String;

		public function AppEvent(type:String, workstationAppController:WorkstationAppControllerBase = null,
								 startRect:Rect = null, applicationName:String = null, viaMechanism:String = null, bubbles:Boolean = false,
								 cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_workstationAppController = workstationAppController;
			_startRect = startRect;
			_applicationName = applicationName;
			_viaMechanism = viaMechanism;
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

		public function get viaMechanism():String
		{
			return _viaMechanism;
		}

		public function set viaMechanism(value:String):void
		{
			_viaMechanism = value;
		}
	}
}