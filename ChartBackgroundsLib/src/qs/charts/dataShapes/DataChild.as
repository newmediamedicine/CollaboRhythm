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