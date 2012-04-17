package com.dougmccune.controls
{
	import collaboRhythm.view.scroll.ITouchScrollerAdapter;
	import collaboRhythm.view.scroll.TouchScroller;
	import collaboRhythm.view.scroll.TouchScrollerEvent;

	import flash.events.KeyboardEvent;

	import mx.core.UIComponent;
	import mx.events.FlexEvent;

	[Event(name="scrollStart", type="collaboRhythm.view.scroll.TouchScrollerEvent")]
	[Event(name="scrollStop", type="collaboRhythm.view.scroll.TouchScrollerEvent")]
	
	public class TouchScrollingScrubChart extends ScrubChart implements ITouchScrollerAdapter
	{
		private var _touchScroller:TouchScroller;
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
			initializeTouchScroller();
		}

		[Bindable]
		override public function set scrollEnabled(value:Boolean):void
		{
			super.scrollEnabled = value;
			initializeTouchScroller();
			if (_touchScroller)
			{
				_touchScroller.useHorizontalTouchScrolling = useHorizontalTouchScrolling && scrollEnabled;
			}
		}

		private function initializeTouchScroller():void
		{
			if (scrollEnabled)
			{
				if (_touchScroller == null)
				{
					_touchScroller = new TouchScroller(this);
					_touchScroller.useHorizontalTouchScrolling = useHorizontalTouchScrolling;
					_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
					_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_STOP, scrollStopHandler);

					_touchScroller.createChildren();

					this.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				}
			}
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
            if (this._touchScroller)
    			_touchScroller.keyUpHandler(event);
		}
		
		public function get component():UIComponent
		{
			return this.mainChartContainer;
		}
		
		public function get componentContainer():UIComponent
		{
			return this.mainChartContainer;
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
			
			return (maxX - minX) * this.mainChartArea.width * mainChartToContainerRatio;
			
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
			var contentPositionX:Number = -(leftRangeTime - _minimumTime) * (mainChartArea.width / mainChartToContainerRatio / mainChartDurationTime);
//			var contentPositionX:Number = mainChart.x;
			return contentPositionX;
		}
		
		public function updateContentPositionX(value:Number):void
		{
//			trace("before:  mainChartDurationTime", mainChartDurationTime, "leftToRight", leftToRight,"leftRangeTime", leftRangeTime, "rightRangeTime", rightRangeTime, "min", minimumTime, "max", maximumTime);

			var leftToRight:Number = rightRangeTime - leftRangeTime;
			var targetLeftRangeTime:Number = -value / (mainChartArea.width / mainChartToContainerRatio / mainChartDurationTime) + _minimumTime;

			leftRangeTime = targetLeftRangeTime;
			rightRangeTime = targetLeftRangeTime + leftToRight;

			var mainChartEffectivePositionX:Number = -(getAxisMinimum(this.mainChart.horizontalAxis).time - _minimumTime) * (mainChartArea.width / mainChartToContainerRatio / mainChartDurationTime);
			quickScrollOffset = Math.round(value - mainChartEffectivePositionX);

			var isQuickScroll:Boolean = true;
			if (quickScrollOffset > 0 || quickScrollOffset < mainChartContainer.width - mainChartArea.width)
			{
				trace("quick scroll limit exceeded. quickScrollOffset", quickScrollOffset, "mainChartArea.width", mainChartArea.width, "contentPositionX", value, "mainChartEffectivePositionX", mainChartEffectivePositionX, "leftRangeTime", traceDate(leftRangeTime), "rightRangeTime", traceDate(rightRangeTime));
				isQuickScroll = false;
			}
			else
			{
				mainChart.x = quickScrollOffset;
			}

			this.updateForScroll(isQuickScroll);

//			trace("after:   mainChartDurationTime", mainChartDurationTime, "leftToRight", leftToRight, "rightRangeTime", rightRangeTime, "min", minimumTime, "max", maximumTime);
//			trace("         set contentPositionX value", value.toFixed(0), "get result", contentPositionX.toFixed(0));
//			trace("         targetLeftRangeTime", targetLeftRangeTime, "limitedLeftRangeTime", limitedLeftRangeTime, "leftRangeTime", leftRangeTime);
//			trace("         limitedRightRangeTime", limitedLeftRangeTime + leftToRight, "rightRangeTime", rightRangeTime);
		}

		public function set contentPositionX(value:Number):void
		{
			updateContentPositionX(value);
			this.dispatchScrollEvent();
		}
		
		public function stopInertiaScrolling():void
		{
            if (this._touchScroller)
    			this._touchScroller.stopInertiaScrolling();
		}
		
		private function scrollStartHandler(event:TouchScrollerEvent):void
		{
			if (_traceEvents)
				trace(this + ".scrollStartHandler");
			
			hideAnnotations();
		}
		
		private function scrollStopHandler(event:TouchScrollerEvent):void
		{
			if (_traceEvents)
				trace(this + ".scrollStopHandler");
			
			showAnnotations = true;
			refreshAnnotations();
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
			{
				_touchScroller.useHorizontalTouchScrolling = useHorizontalTouchScrolling && scrollEnabled;
			}
		}

		public function synchronizeScrollPosition(targetChart:TouchScrollingScrubChart):void
		{
			if (this != targetChart)
			{
				stopInertiaScrolling();

				// We can only use the optimized synchronization method of setting the contentPositionX if the charts match up as expected
				if (minimumTime == targetChart.minimumTime && maximumTime == targetChart.maximumTime &&
						mainChartToContainerRatio == targetChart.mainChartToContainerRatio &&
						mainDataRatio == targetChart.mainDataRatio)
				{
					updateContentPositionX(targetChart.contentPositionX);
				}
				else
				{
					var mismatches:Array = new Array();
					checkMismatchProperty(targetChart, mismatches, "minimumTime", true);
					checkMismatchProperty(targetChart, mismatches, "maximumTime", true);
					checkMismatchProperty(targetChart, mismatches, "mainChartToContainerRatio");
					checkMismatchProperty(targetChart, mismatches, "mainDataRatio");
					if (_traceEvents)
						_logger.debug("Optimization in synchronizeScrollPosition failed because of mismatch between this chart " +
								traceEventsPrefix + " and target " + targetChart.traceEventsPrefix + " Mismatches: " + mismatches.join(", ")); // + "minimumTime " + targetChart.minimumTime)
					leftRangeTime = targetChart.leftRangeTime;
					rightRangeTime = targetChart.rightRangeTime;
					updateForScroll();
				}
			}
		}

		private function checkMismatchProperty(targetChart:TouchScrollingScrubChart, mismatches:Array,
											   propertyName:String, isDate:Boolean = false):void
		{
			if (this[propertyName] != targetChart[propertyName])
				mismatches.push(propertyName + " != targetChart." + propertyName + " (" + (isDate ? traceDate(this[propertyName]) : this[propertyName]) + " != " +
						(isDate ? traceDate(targetChart[propertyName]) : targetChart[propertyName]) + ")");
		}
	}
}