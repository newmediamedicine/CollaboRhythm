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
package resources.physics
{
	import spark.effects.easing.IEaser;
	
	public class AccelerationEaser implements IEaser
	{
		public static const dpi:Number = 72; // approximate
		private static const metersToPixels:Number = 100 / 2.54 * dpi;
		private static const secondsToMilliseconds:Number = 1000 * 1000;
		public static const gravity:Number = 9.8 * metersToPixels / secondsToMilliseconds;
		
		private var _delta:Number;
		private var _acceleration:Number;
		private var _v0:Number;
		private var _duration:Number;
		
		public function AccelerationEaser(delta:Number, acceleration:Number, v0:Number=0)
		{
			_delta = delta;
			_acceleration = acceleration;
			_v0 = v0;
			
			var discriminant:Number = v0 * v0 + 2 * acceleration * delta;
			_duration = (-v0 + Math.sqrt(discriminant)) / acceleration; 
		}
		
		public function get duration():Number
		{
			return _duration;
		}
		
		public function ease(fraction:Number):Number
		{
			var t:Number = _duration * fraction;
			var x:Number = _v0 * t + 0.5 * _acceleration * t * t;
			return x / _delta;
		}
	}
}