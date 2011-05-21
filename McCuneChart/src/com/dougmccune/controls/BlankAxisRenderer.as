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
package com.dougmccune.controls
{
	import flash.geom.Rectangle;

	import mx.charts.chartClasses.IAxis;
	import mx.charts.chartClasses.IAxisRenderer;
	import mx.core.UIComponent;

	public class BlankAxisRenderer extends UIComponent implements IAxisRenderer
	{
		private var _gutters:Rectangle;
		public function BlankAxisRenderer()
		{
		}

		public function get axis():IAxis
		{
			return null;
		}

		public function set axis(value:IAxis):void
		{
		}

		public function get gutters():Rectangle
		{
			return _gutters;
		}

		public function set gutters(value:Rectangle):void
		{
			_gutters = value;
		}

		public function set heightLimit(value:Number):void
		{
		}

		public function get heightLimit():Number
		{
			return 0;
		}

		public function get horizontal():Boolean
		{
			return false;
		}

		public function set horizontal(value:Boolean):void
		{
		}

		public function get minorTicks():Array
		{
			return null;
		}

		public function set otherAxes(value:Array):void
		{
		}

		public function get placement():String
		{
			return "";
		}

		public function set placement(value:String):void
		{
		}

		public function get ticks():Array
		{
			return [0];
		}

		public function adjustGutters(workingGutters:Rectangle, adjustable:Object):Rectangle
		{
			return workingGutters;
		}

		public function chartStateChanged(oldState:uint, v:uint):void
		{
		}
	}
}
