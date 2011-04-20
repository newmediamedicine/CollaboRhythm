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
package collaboRhythm.plugins.bloodPressure.view.simulation
{
	import flash.events.Event;

	public class SimulationLevelEvent extends Event
	{
		public static const DRILL_DOWN_LEVEL:String = "drillDownLevel";
		public static const BACK_UP_LEVEL:String = "backUpLevel";

		private var _zoomWidthFrom:Number;
		private var _zoomHeightFrom:Number;
		private var _xFrom:Number;
		private var _yFrom:Number;

		public function SimulationLevelEvent(type:String, zoomWidthFrom:Number=NaN, zoomHeightFrom:Number=NaN, xFrom:Number=NaN, yFrom:Number=NaN, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_zoomWidthFrom = zoomWidthFrom;
			_zoomHeightFrom = zoomHeightFrom;
			_xFrom = xFrom;
			_yFrom = yFrom;
		}

		public function get zoomWidthFrom():Number
		{
			return _zoomWidthFrom;
		}

		public function set zoomWidthFrom(value:Number):void
		{
			_zoomWidthFrom = value;
		}

		public function get zoomHeightFrom():Number
		{
			return _zoomHeightFrom;
		}

		public function set zoomHeightFrom(value:Number):void
		{
			_zoomHeightFrom = value;
		}

		public function get xFrom():Number
		{
			return _xFrom;
		}

		public function set xFrom(value:Number):void
		{
			_xFrom = value;
		}

		public function get yFrom():Number
		{
			return _yFrom;
		}

		public function set yFrom(value:Number):void
		{
			_yFrom = value;
		}
	}
}
