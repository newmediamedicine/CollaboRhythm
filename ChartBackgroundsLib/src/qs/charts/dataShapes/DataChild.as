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
	import mx.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	[DefaultProperty("content")]
	[Event("change")]
	public class DataChild extends EventDispatcher
	{
		public function DataChild(child:DisplayObject = null,left:* = undefined, top:* = undefined, right:* = undefined, bottom:* = undefined,
		horizontalCenter:* = undefined, verticalCenter:* = undefined):void
		{
			this.child = child;
			this.left = left;
			this.top = top;
			this.bottom = bottom;
			this.right = right;
		}
		
		public var child:DisplayObject;
		public var left:*;
		public var right:*;
		public var top:*;
		public var bottom:*;		
		public var horizontalCenter:*;
		public var verticalCenter:*;
		
		public function set content(value:*):void
		{
			if(value is DisplayObject)
				child = value;
			else if (value is Class)
				child = new value();
			dispatchEvent(new Event("change"));
		}		
	}
}