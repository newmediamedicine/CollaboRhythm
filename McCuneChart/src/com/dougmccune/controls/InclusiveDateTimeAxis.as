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
package com.dougmccune.controls
{
	import mx.charts.DateTimeAxis;
	
	/**
	 * A subclass of DateTimeAxis which overrides the filtering behavior to include data points outside the range
	 * of minimum/maximum. The data is assumed to be sorted by date. The one point just before minimum date
	 * and the one point just after the maximum is is included (whereas DateTimeAxis would filter these out).
	 * This enables line graphs to be plotted edge-to-edge, right up to the left and right borders (axis) of the graph.
	 * 
	 * @author sgilroy
	 * 
	 */
	public class InclusiveDateTimeAxis extends DateTimeAxis
	{
		public function InclusiveDateTimeAxis()
		{
			super();
		}
		
		/**
		 *  @copy mx.charts.chartClasses.IAxis#filterCache()
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public override function filterCache(cache:Array /* of Object */, field:String,
									filteredField:String):void
		{
			update();
			
			// Avoid roundoff errors.
			var max:Number = computedMaximum + 0.00001;
			var min:Number = computedMinimum - 0.00001;
			
			var pastMin:Boolean = false;
			var pastMax:Boolean = false;
//			var previousIn:Boolean = false;
			
			var n:int = cache.length;
			for (var i:int = 0; i < n; i++)
			{
				var v:Object = cache[i][field];
//				var currentIn:Boolean = v >= min && v <= max;
				
				var justPassedMin:Boolean = !pastMin && v >= min;
				if (justPassedMin) pastMin = true;
				var justPassedMax:Boolean = !pastMax && v >= max;
				if (justPassedMax) pastMax = true;
				
				var currentIn:Boolean = pastMin && !pastMax;

				// Include the next value after maximum by including a value if either 
				//	(a) it is in range (currentIn) or 
				//	(b) the previous value was in in range (previousIn)
//				cache[i][filteredField] = currentIn || previousIn ? v : NaN;
				cache[i][filteredField] = currentIn || justPassedMax ? v : NaN;
				
				if (justPassedMin && i > 0)
				{
					// include the previous value
					cache[i - 1][filteredField] = cache[i - 1][field];
				}
				
//				previousIn = currentIn
			}
		}
		
	}
}