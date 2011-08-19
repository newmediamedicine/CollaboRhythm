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
	
	public class TouchScrollingScrubChart extends ScrubChart implements ITouchScrollerAdapter
	{
		private var _touchScroller:TouchScroller;
		private var _traceEventHandlers:Boolean = false;
		private var _useHorizontalTouchScrolling:Boolean = true;

		override public function TouchScrollingScrubChart()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		public function creationCompleteHandler(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

			// TODO: add support for toggling scrollEnabled at runtime; currently only the initial value is considered 
			if (scrollEnabled)
			{
				_touchScroller = new TouchScroller(this);
				_touchScroller.useHorizontalTouchScrolling = useHorizontalTouchScrolling;
				_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
				_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_STOP, scrollStopHandler);

				_touchScroller.createChildren();

				this.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			}
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
            if (this._touchScroller)
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
			if (this.data == null || this.data.length == 0)
				return 0;
			
//			var cache:Array = [ { from: this.dateParse(this.data[0][dateField]).time, to: 0 }, { from: this.dateParse(this.data[this.data.length - 1][dateField]).time, to: 0} ];
			var cache:Array = [ { from: _minimumTime, to: 0 }, { from: _maximumTime, to: 0} ];
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
			var contentPositionX:Number = -(leftRangeTime - _minimumTime) * (mainChartArea.width / mainChartDurationTime);
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
			var targetLeftRangeTime:Number = -value / (mainChartArea.width / mainChartDurationTime) + _minimumTime;
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
            if (this._touchScroller)
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

		public function get useHorizontalTouchScrolling():Boolean
		{
			return _useHorizontalTouchScrolling;
		}

		public function set useHorizontalTouchScrolling(value:Boolean):void
		{
			_useHorizontalTouchScrolling = value;
			if (_touchScroller)
				_touchScroller.useHorizontalTouchScrolling = value;
		}

	}
}