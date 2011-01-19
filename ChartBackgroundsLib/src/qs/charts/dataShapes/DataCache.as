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
package qs.charts.dataShapes
{
	import flash.utils.Dictionary;
	import mx.charts.chartClasses.BoundedValue;
	
public class DataCache
{
	public var xCache:Array;
	public var yCache:Array;
	
	public var xBoundedValues:Dictionary;
	public var yBoundedValues:Dictionary;
	public var xMap:Dictionary;
	public var yMap:Dictionary;
	
	public function DataCache():void
	{
		xMap = new Dictionary(true);
		yMap = new Dictionary(true);
		xCache = [];
		yCache = [];
		xBoundedValues = new Dictionary(true);
		yBoundedValues = new Dictionary(true);
	}
	public function storeX(value:*,leftMargin:Number = 0, rightMargin:Number = 0):void
	{
		var bounds:BoundedValue;

		if(value is Edge)
			return;
		if(leftMargin < 0)
			leftMargin = 0;
		if(rightMargin < 0)
			rightMargin = 0;
			
		xMap[value] = value;
		if(leftMargin != 0 || rightMargin != 0)
		bounds = xBoundedValues[value];
		if(leftMargin > 0)
			leftMargin += 2;
		if (rightMargin > 0)
			rightMargin += 2;
			
		if(bounds == null)
		{
			xBoundedValues[value] = bounds = new BoundedValue(0,leftMargin,rightMargin);
		}
		else
		{
			bounds.lowerMargin = Math.max(bounds.lowerMargin,leftMargin);
			bounds.upperMargin = Math.max(bounds.upperMargin,rightMargin);
		}
	}

	public function storeY(value:*,topMargin:Number = 0,bottomMargin:Number = 0):void
	{
		var bounds:BoundedValue;

		if(value is Edge)
			return;
		yMap[value] = value;
		if(topMargin != 0 || bottomMargin != 0)
		{
			bounds = yBoundedValues[value];
			if(bounds == null)
			{
				yBoundedValues[value] = bounds = new BoundedValue(0,bottomMargin,topMargin);
			}
			else
			{
				bounds.lowerMargin = Math.max(bounds.lowerMargin,bottomMargin);
				bounds.upperMargin = Math.max(bounds.upperMargin,topMargin);
			}
		}
	}
	public function x(value:*):Number
	{
		return Number(xMap[value]);
	}
	public function y(value:*):Number
	{
		return Number(yMap[value]);
	}
}
}