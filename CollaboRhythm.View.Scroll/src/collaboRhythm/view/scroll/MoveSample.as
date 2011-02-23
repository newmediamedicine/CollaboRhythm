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
package collaboRhythm.view.scroll
{
	import flash.geom.Point;

	/**
	 * A sample point corresponding to a mouse or touch move event. Multiple samples are stored in order to interpret a gesture over
	 * a period of time longer than the sample rate of individual move events.
	 *   
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public class MoveSample
	{
		private var _pos:Point;
		private var _dateStamp:Date;
		private var _previousSample:MoveSample;
		
		public function MoveSample(posX:Number, posY:Number, dateStamp:Date, previousSample:MoveSample)
		{
			_pos = new Point(posX, posY);
			_dateStamp = dateStamp;
			_previousSample = previousSample;
		}

		public function get previousSample():MoveSample
		{
			return _previousSample;
		}

		public function set previousSample(value:MoveSample):void
		{
			_previousSample = value;
		}

		public function get dateStamp():Date
		{
			return _dateStamp;
		}

		public function set dateStamp(value:Date):void
		{
			_dateStamp = value;
		}

		public function get pos():Point
		{
			return _pos;
		}

		public function set pos(value:Point):void
		{
			_pos = value;
		}

	}
}