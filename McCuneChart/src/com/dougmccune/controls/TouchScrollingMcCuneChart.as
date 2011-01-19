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
	import collaboRhythm.view.scroll.ITouchScrollerAdapter;
	import collaboRhythm.view.scroll.TouchScroller;
	import collaboRhythm.view.scroll.TouchScrollerEvent;
	
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	[Event(name="scrollStart", type="collaboRhythm.view.scroll.TouchScrollerEvent")]
	[Event(name="scrollStop", type="collaboRhythm.view.scroll.TouchScrollerEvent")]
	
	public class TouchScrollingMcCuneChart extends McCuneChart implements ITouchScrollerAdapter
	{
		private var _touchScroller:TouchScroller;
		private var _traceEventHandlers:Boolean = false;

		override public function TouchScrollingMcCuneChart()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		public function creationCompleteHandler(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			
//		override protected function createChildren():void
//		{
			_touchScroller = new TouchScroller(this);
			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_STOP, scrollStopHandler);
			//			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_ABORT, scrollAbortHandler);
			
//			super.createChildren();
			_touchScroller.createChildren();
			
			this.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			_touchScroller.keyUpHandler(event);
		}
		
		public function get component():UIComponent
		{
			return this.mainChart;
		}
		
		public function get componentContainer():UIComponent
		{
			return this.mainChart;
		}
		
		public function get panelWidth():Number
		{
			return this.mainChartArea.width;
		}
		
		public function get panelHeight():Number
		{
			return this.mainChartArea.height;
		}
		
		public function get scrollableAreaWidth():Number
		{
			if (this.data == null)
				return 0;
			
			var cache:Array = [ { from: this.dateParse(this.data[0].date).time, to: 0 }, { from: this.dateParse(this.data[this.data.length - 1].date).time, to: 0} ];   
			this.mainChart.horizontalAxis.transformCache(cache, "from", "to"); 
			
			var minX:Number = cache[0].to;
			var maxX:Number = cache[1].to;
			
//			trace(" minX", minX, "maxX", maxX);
			
			return (maxX - minX) * this.mainChartArea.width;
			
			// TODO: figure out why the following (simpler and faster) solution doesn't always work:
//			return (this.maximumTime - this.minimumTime) * (mainChartArea.width / mainChartDurationTime);
		}
		
		public function get scrollableAreaHeight():Number
		{
			return this.mainChart.height;
		}
		
		public function get contentPositionY():Number
		{
			return 0;
		}
		
		public function set contentPositionY(value:Number):void
		{
			// FIXME: implement vertical scrolling
		}
		
		public function get contentPositionX():Number
		{
			var contentPositionX:Number = -(leftRangeTime - t0) * (mainChartArea.width / mainChartDurationTime);
//			var contentPositionX:Number = mainChart.x;
			return contentPositionX;
		}
		
		public function set contentPositionX(value:Number):void
		{
//			var leftToRight:Number = rightRangeTime - leftRangeTime;
//			var targetLeftRangeTime:Number = -value / (mainChartContainer.width / mainChartDurationTime) + t0;
//			leftRangeTime = Math.max(minimumTime, Math.min(maximumTime - leftToRight, targetLeftRangeTime));
//			rightRangeTime = leftRangeTime + leftToRight;

//			trace("before:  mainChartDurationTime", mainChartDurationTime, "leftToRight", leftToRight,"leftRangeTime", leftRangeTime, "rightRangeTime", rightRangeTime, "min", minimumTime, "max", maximumTime);

			var leftToRight:Number = rightRangeTime - leftRangeTime;
			var targetLeftRangeTime:Number = -value / (mainChartArea.width / mainChartDurationTime) + t0;
//			var limitedLeftRangeTime:Number = Math.max(t0, Math.min(t1 - leftToRight, targetLeftRangeTime));
//			leftRangeTime = limitedLeftRangeTime;
//			rightRangeTime = limitedLeftRangeTime + leftToRight;

			leftRangeTime = targetLeftRangeTime;
			rightRangeTime = targetLeftRangeTime + leftToRight;

			this.updateForScroll();

			this.dispatchScrollEvent();
			
//			trace("after:   mainChartDurationTime", mainChartDurationTime, "leftToRight", leftToRight, "rightRangeTime", rightRangeTime, "min", minimumTime, "max", maximumTime);
//			trace("         set contentPositionX value", value.toFixed(0), "get result", contentPositionX.toFixed(0));
//			trace("         targetLeftRangeTime", targetLeftRangeTime, "limitedLeftRangeTime", limitedLeftRangeTime, "leftRangeTime", leftRangeTime);
//			trace("         limitedRightRangeTime", limitedLeftRangeTime + leftToRight, "rightRangeTime", rightRangeTime);
		}
		
		public function stopInertiaScrolling():void
		{
			this._touchScroller.stopInertiaScrolling();
		}
		
		private function scrollStartHandler(event:TouchScrollerEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".scrollStartHandler");
			
			hideAnnotations();
			
			dispatchEvent(new TouchScrollerEvent(event.type, event.scrollTarget));
		}
		
		private function scrollStopHandler(event:TouchScrollerEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".scrollStopHandler");
			
			showAnnotations = true;
			refreshAnnotations();
			
			dispatchEvent(new TouchScrollerEvent(event.type, event.scrollTarget));
		}
		
		public function hideScrollBarV():void
		{
		}
		
		public function hideScrollBarH():void
		{
		}
		
		public function showScrollBarV():void
		{
		}
		
		public function showScrollBarH():void
		{
		}
	}
}