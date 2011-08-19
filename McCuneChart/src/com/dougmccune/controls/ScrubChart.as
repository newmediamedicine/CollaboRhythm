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
 *
 * This code is based in part on code by Brendan Meutzner.

Portions Copyright (c) 2007 Brendan Meutzner

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */
package com.dougmccune.controls
{

	import annotations.EventAnnotation;

	import com.dougmccune.events.FocusTimeEvent;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.globalization.DateTimeFormatter;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

	import mx.charts.ChartItem;
	import mx.charts.DateTimeAxis;
	import mx.charts.HitData;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.NumericAxis;
	import mx.charts.chartClasses.Series;
	import mx.charts.events.ChartItemEvent;
	import mx.charts.series.AreaSeries;
	import mx.charts.series.items.AreaSeriesItem;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.controls.Alert;
	import mx.controls.DateField;
	import mx.controls.List;
	import mx.controls.TextArea;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.effects.Effect;
	import mx.events.CollectionEvent;
	import mx.events.DividerEvent;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.events.SliderEvent;
	import mx.formatters.DateFormatter;
	import mx.formatters.NumberFormatter;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.IFocusManagerComponent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.styles.CSSStyleDeclaration;
	import mx.utils.UIDUtil;

	import spark.components.Group;

	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.ToggleButtonBase;
	import spark.core.IDisplayText;
	import spark.effects.Animate;
	import spark.effects.Move;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Power;
	import spark.primitives.Ellipse;
	import spark.primitives.Rect;

	import vo.AnnotationVO;

	/**
	 *  Controls the visibility of the border for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="borderVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the header for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="headerVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the footer for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="footerVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the slider for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="sliderVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the top border for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="topBorderVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the volume chart for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="volumeVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the range chart for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="rangeChartVisible", type="Boolean", inherit="no", theme="spark")]

	/**
	 *  Controls the visibility of the Frames Per Second information for this component.
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
//	[Style(name="showFps", type="Boolean", inherit="no", theme="spark")]

	/**
	 * Signifies that the data is completely loaded. When this event is dispatched, the sliders and dividers, etc. will
	 * The event should only be dispatched once when the application first loads.
	 */
	[Event(name="seriesComplete", type="flash.events.Event")]
	[Event(name="scroll", type="mx.events.ScrollEvent")]
	[Event(name="focusTimeChange", type="com.dougmccune.events.FocusTimeEvent")]
	[Event(name="itemClick", type="mx.charts.events.ChartItemEvent")]

	public class ScrubChart extends SkinnableComponent implements IFocusManagerComponent
	{
		[SkinPart(required="false")]
		public var titleDisplay:IDisplayText;
		
		[SkinPart(required="true")]
		public var mainChartContainer:Canvas;
		
		[SkinPart(required="true")]
		public var mainChart:CartesianChart;

		[SkinPart(required="false")]
		public var mainPrimarySeries:AreaSeries;

		[SkinPart(required="false")]
		public var mainChartArea:Canvas;

		[SkinPart(required="false")]
		public var fpsDisplay:IDisplayText;
		
		[SkinPart(required="false")]
		public var annotationCanvas:Canvas;

		[SkinPart(required="false")]
		public var rangeChart:CartesianChart;

		[SkinPart(required="false")]
		public var rangePrimarySeries:AreaSeries;

		[SkinPart(required="false")]
		public var dividedBox:HDividedBox;

		[SkinPart(required="false")]
		public var leftBox:Canvas;

		[SkinPart(required="false")]
		public var middleBox:Canvas;

		[SkinPart(required="false")]
		public var rightBox:Canvas;

		[SkinPart(required="false")]
		public var mainChartVolume:CartesianChart;

		[SkinPart(required="false")]
		public var focusTimeMarker:UIComponent;

		[SkinPart(required="false")]
		public var leftScrollButton:UIComponent;

		[SkinPart(required="false")]
		public var rightScrollButton:UIComponent;

		[SkinPart(required="false")]
		public var slider:HSlider;

		[SkinPart(required="false")]
		public var annDate:DateField;

		[SkinPart(required="false")]
		public var annDescription:TextArea;

		[SkinPart(required="false")]
		public var addAnnotationButton:UIComponent;

		[SkinPart(required="false")]
		public var showAnnotationsButton:ToggleButtonBase;
		
		[SkinPart(required="false")]
		public var rangeOneDayButton:UIComponent;
		
		[SkinPart(required="false")]
		public var rangeOneWeekButton:UIComponent;

		[SkinPart(required="false")]
		public var rangeOneMonthButton:UIComponent;
		
		[SkinPart(required="false")]
		public var rangeOneYearButton:UIComponent;
		
		[SkinPart(required="false")]
		public var rangeMaxButton:UIComponent;
		
		[SkinPart(required="false")]
		public var rangeTodayButton:UIComponent;

		[SkinPart(required="false")]
		public var annotationForm:List;
		
		[SkinPart(required="false")]
		public var footer:UIComponent;

		[SkinPart(required="false")]
		public var highlightChartItemGroup:Group;

		[SkinPart(required="false")]
		public var highlightChartItemBullsEye:Ellipse;

		[SkinPart(required="false")]
		public var highlightChartItemEffect:Effect;

		[SkinPart(required="false")]
		public var highlightChartItemScopeLeft:Rect;

		[SkinPart(required="false")]
		public var highlightChartItemEffectScopeLeftMove:Move;

		//the sliced data to appear in the upper area chart, and column volume chart
		[Bindable]
		public var mainData:ArrayCollection = new ArrayCollection();
		//the full dataset of stock information
		[Bindable]
		protected var rangeData:ArrayCollection = new ArrayCollection();

		private var _mainChartTitle:String;

		//static positions of left and right indicators set in setMouseDown and used in moveChart to calculate new positions
		private var staticLeftBoundary:Number;
		private var staticRightBoundary:Number;
		//the static mouse position where we've clicked... used to calculate move differences in moveChart
		private var mouseXRef:Number;
		//flags to determine which chart we've clicked on for the drag... set in setMouseDown used it moveChart
		private var rangeDrag:Boolean = false;
		private var mainDrag:Boolean = false;
		//the ratio between the width of the range control, and the duration of the full dataset
		[Bindable]
		private var rangeDataRatio:Number = 1;
		//enabled when the slider is directly updating the box positions for realtime drag
		//disabled when divider is moved and dropped inside easing effect for delayed move
		private var updateBoxFromRangeTimes:Boolean = true;
		//a flag to allow the updateComplete event on AreaSeries to run only once on startup
		private var allowUpdateComplete:Boolean = true;

		//values used in text instances above chart for current data point data
		[Bindable]
		private var _selectedDate:String;
		[Bindable]
		private var _selectedClose:String;
		[Bindable]
		private var _selectedVolume:String;

		/* STEP 5 */
		[Bindable]
		public var annotationItems:ArrayCollection = new ArrayCollection();
		private var alphabet:Array = ['A','B','C','D','E','F','G','H','I','J','K',
			'L','M','N','O','P','Q','R','S','T','U','V',
			'W','X','Y','Z'];
		public var showAnnotations:Boolean = true;

		private var indicatorToDateSlope:Number;
		private var indicatorToDateIntercept:Number;
		//			private var sliderToDateSlope:Number;
		//			private var sliderToDateIntercept:Number;

		public static const DAYS_TO_MILLISECONDS:Number = 24 * 60 * 60 * 1000;
		private const minimumDurationTime:Number = 2 * DAYS_TO_MILLISECONDS;

		private var _leftRangeTime:Number;
		private var _rightRangeTime:Number;
		private var _focusTime:Number;
		private const defaultInitialDurationTime:Number = 30 * DAYS_TO_MILLISECONDS;
		[Bindable]
		protected var _minimumTime:Number;
		[Bindable]
		protected var _maximumTime:Number;
		protected var mainChartDurationTime:Number;
		// the ratio between the width of the main chart control and the duration of it's dataset
		protected var mainDataRatio:Number;

		[Bindable]
		public var seriesName:String = "close";

		private var _today:Date;

		[Bindable]
		private var _showFps:Boolean = false;
		private var _lastUpdate:Date;
		private const _lastUpdatesStackMax:int = 10;
		private var _lastUpdatesStack:Vector.<Date> = new Vector.<Date>();
		private var _performanceCounter:Object;

		private var highlightedItem:ChartItem;

		private var _showFocusTimeMarker:Boolean = true;
		private var _scrollEnabled:Boolean = true;
		private var _traceEvents:Boolean = false;

		private var fullDateFormat:DateFormatter = new DateFormatter();
			
		private var labelYearFormatter:DateFormatter = new DateFormatter();
		private var labelMonthFormatter:DateFormatter = new DateFormatter();
		private var labelDayFormatter:DateFormatter = new DateFormatter();
		private var labelDefaultFormatter:DateFormatter = new DateFormatter();
		private var labelSummaryDateFormatter:DateFormatter = new DateFormatter();
		
		private var verticalAxisFormat:NumberFormatter = new NumberFormatter();
		private var dollarFormatter:NumberFormatter = new NumberFormatter();
		private var percentageFormatter:NumberFormatter = new NumberFormatter();
		private var volumeFormatter:NumberFormatter = new NumberFormatter();
		
		// http://flexdevtips.blogspot.com/2009/03/setting-default-styles-for-custom.html
//		private static var classConstructed:Boolean = classConstruct();
		
		private var _synchronizedAxisCache:SynchronizedAxisCache;
		private var _dateField:String = "date";

		public function get dateField():String
		{
			return _dateField;
		}

		public function set dateField(value:String):void
		{
			_dateField = value;
		}

		public function get synchronizedAxisCache():SynchronizedAxisCache
		{
			return _synchronizedAxisCache;
		}

		public function set synchronizedAxisCache(value:SynchronizedAxisCache):void
		{
			_synchronizedAxisCache = value;
			updateSynchronizedAxisRenderers();
		}
		
		private function updateSynchronizedAxisRenderers():void
		{
			if (mainChart && mainChart.horizontalAxisRenderers[0] is SynchronizedAxisRenderer)
			{
				var synchronizedAxisRenderer:SynchronizedAxisRenderer = mainChart.horizontalAxisRenderers[0];
				synchronizedAxisRenderer.synchronizedAxisCache = synchronizedAxisCache;
			}
		}

		private static function classConstruct():Boolean
		{
			if (!FlexGlobals.topLevelApplication.styleManager.
					getStyleDeclaration("com.dougmccune.controls.ScrubChart"))
			{
				// No CSS definition for StyledRectangle,  so create and set default values
				var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
				styleDeclaration.defaultFactory = function():void
				{
					this.skinClass = ScrubChartSkin;
					this.rangeChartVisible = true;
					this.sliderVisible = true;
					this.topBorderVisible = true;
					this.headerVisible = true;
					this.footerVisible = true;
				};

				FlexGlobals.topLevelApplication.styleManager.
						setStyleDeclaration("com.dougmccune.controls.ScrubChart", styleDeclaration, true);
			}
			return true;
		}

		public function ScrubChart()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			fullDateFormat.formatString = "YYYY-MM-DD";
			labelYearFormatter.formatString = "YYYY";
			labelMonthFormatter.formatString = "MMM YYYY";
			labelDayFormatter.formatString = "MMM DD";
			labelDefaultFormatter.formatString = "EEE MMM D";
			labelSummaryDateFormatter.formatString = "EEE MMM DD, YYYY";

			verticalAxisFormat.precision = 1;
			dollarFormatter.useNegativeSign = true;
			dollarFormatter.precision = 2;
			percentageFormatter.useNegativeSign = true;
			percentageFormatter.precision = 2;
			volumeFormatter.useThousandsSeparator = true;

			initializeRangeTimeAnimate();
			initializeFocusTimeAnimate();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			this.addEventListener(MouseEvent.CLICK, mainChartArea_clickHandler);
		}

		[Bindable]
		public function get scrollEnabled():Boolean
		{
			return _scrollEnabled;
		}

		public function set scrollEnabled(value:Boolean):void
		{
			_scrollEnabled = value;
		}

		[Bindable]
		public function get showFocusTimeMarker():Boolean
		{
			return _showFocusTimeMarker;
		}

		public function set showFocusTimeMarker(value:Boolean):void
		{
			_showFocusTimeMarker = value;
            if (focusTimeMarker)
    			focusTimeMarker.visible = value;
		}

		[Bindable]
		public function get leftRangeTime():Number
		{
			return _leftRangeTime;
		}

		public function set leftRangeTime(value:Number):void
		{
			_leftRangeTime = value;
			if (slider)
				slider.values[0] = value;
		}

		[Bindable]
		public function get rightRangeTime():Number
		{
			return _rightRangeTime;
		}

		public function set rightRangeTime(value:Number):void
		{
			_rightRangeTime = value;
			if (slider)
				slider.values[1] = value;
		}

		[Bindable]
		public function get focusTime():Number
		{
			return _focusTime;
		}

		public function set focusTime(value:Number):void
		{
			updateFocusTime(value);
		}

		public function updateFocusTime(value:Number):void
		{
		//				trace("_focusTime " + (new Date(_focusTime)).toString() + " value " + (new Date(value)).toString() + " focusTimeMarker.x " + focusTimeMarker.x);
			_focusTime = Math.max(leftRangeTime, Math.min(rightRangeTime, value));

			var cache:Array = [
				{ from: _focusTime, to: 0 }
			];
			this.mainChart.horizontalAxis.transformCache(cache, "from", "to");
			var result:Object = cache[0];
			var focusAxisPosition:Number = result["to"];

			//				var focusAxisPosition:Number = (focusTimeMarker.x + focusTimeMarker.width / 2 - mainChartContainer.x - mainChart.x - mainChart.computedGutters.left) /
			//					(this.mainChart.width - this.mainChart.computedGutters.left - this.mainChart.computedGutters.right);

			if (focusTimeMarker)
			{
				focusTimeMarker.x = focusAxisPosition * (this.mainChart.width - this.mainChart.computedGutters.left - this.mainChart.computedGutters.right) -
						(focusTimeMarker.width / 2 - mainChartContainer.x - mainChart.x - mainChart.computedGutters.left);
			}

			hideDataPointHighlight();
		}

		public function get showFps():Boolean
		{
			return _showFps;
		}

		public function set showFps(value:Boolean):void
		{
			if (_showFps != value)
			{
				_showFps = value;
				var fpsLabel:UIComponent = fpsDisplay as UIComponent;
				if (fpsLabel)
					fpsLabel.visible = value;

				if (_showFps)
					this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				else
					this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}

		protected function showAnnotationsButton_clickHandler(event:MouseEvent):void
		{
			if (showAnnotationsButton.selected)
				this.currentState = "showAnnotationControls";
			else
				this.currentState = "hideAnnotationControls";
		}

		private function creationCompleteHandler(event:Event):void
		{
			_isCreationComplete = true;
			updateSynchronizedAxisRenderers();
			initializeFromData();

			if (_showFps)
				this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		private var s0:Number = 0.2;
		private var s1:Number = 0.7;

		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.F)
			{
				showFps = !showFps;
			}
			else if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.T)
			{
				_traceEvents = !_traceEvents;
			}
			else if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.S)
			{
				setStyle("sliderVisible", !getStyle("sliderVisible"));
			}
			else if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.D)
			{
				trace("dividedBox.width", dividedBox.width, "boxes_width", leftBox.width + middleBox.width + rightBox.width, "rangeChart.width", rangeChart ? rangeChart.width : "N/A", "mainChart.width", mainChart.width, "focusTimeMarker.x", focusTimeMarker ? focusTimeMarker.x : "N/A", "this.mouseX", this.mouseX);
			}
			else if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.E)
			{
				if (slider)
				{
					// TODO: fix updating of the slider thumbs; currently they don't move when slider.values is updated
					trace("slider.values[0]", slider.values[0], "slider.values[1]", slider.values[1]);
					slider.values[0] = _minimumTime + (_maximumTime - _minimumTime) * s0;
					slider.values[1] = _minimumTime + (_maximumTime - _minimumTime) * s1;
					slider.invalidateProperties();
					slider.validateNow();
					this.validateNow();
				}
			}
            else if (event.keyCode == Keyboard.LEFT || event.keyCode == Keyboard.RIGHT)
            {
                var delta:Number = 0;
                if (event.keyCode == Keyboard.LEFT)
                    delta = 1;
                else if (event.keyCode == Keyboard.RIGHT)
                    delta = -1;

				if (event.altKey)
					delta *= 100;
				else if (!event.altKey && !event.ctrlKey && !event.shiftKey)
					delta *= 10;

                if (delta != 0)
                    mainChartUpdate(delta);
            }
		}

		private var _data:ArrayCollection = new ArrayCollection();

		public function get data():ArrayCollection
		{
			return _data;
		}

		private var _initialDurationTime:Number = defaultInitialDurationTime;
		private var _isCreationComplete:Boolean;
		private var _pendingUpdateData:Boolean;
		private var _minimumDataTime:Number;
		private var _maximumDataTime:Number;

		public function get isCreationComplete():Boolean
		{
			return _isCreationComplete;
		}

		private function initializeFromData():void
		{
			if (isCreationComplete)
			{
				minimumTime = NaN;
				maximumTime = NaN;
				commitDataChange();
			}
		}

		private function commitDataChange():void
		{
			if (_data == null)
			{
				throw new Error("data must not be null");
			}

			allowUpdateComplete = true;

			rangeData.source = _data.source;

			try
			{
				mainData.source = _data.source;
			} catch(e:Error)
			{
				trace("Error setting mainData: " + e.message);
			}

			if (rangeData.length > 0)
			{
				//setting default range values for loading
				var i0:Number = 0;
				try
				{
					var i1:Number = rangeData.source.length - 1;
				} catch(e:Error)
				{
					trace("Error setting i1: " + e.message);
				}
				_minimumTime = _minimumDataTime = dateParse(rangeData.source[i0][dateField]).time;
				_maximumTime = _maximumDataTime = dateParse(rangeData.source[i1][dateField]).time;
				initializeChartsFromMinMaxTimes();
				if (_traceEvents)
					trace(traceEventsPrefix + "initializeFromData leftRangeTime", traceDate(leftRangeTime),
						  "rightRangeTime",
						  traceDate(rightRangeTime), "minimumTime", traceDate(minimumTime), "maximumTime",
						  traceDate(maximumTime),
						  "_minimumTime", traceDate(_minimumTime), "_maximumTime", traceDate(_maximumTime),
						  "i0", i0,  "i1", i1
					);

			}
		}

		private function initializeChartsFromMinMaxTimes():void
		{
			updateSliderMinMax();

			try
			{
				rightRangeTime = _maximumTime;
			} catch(e:Error)
			{
				trace("Error setting rightRangeTime: " + e.message);
			}

			try
			{
//				leftRangeTime = Math.max(t0, t1 - initialDurationTime);
				leftRangeTime = _maximumTime - initialDurationTime;
			} catch(e:Error)
			{
				trace("Error setting leftRangeTime: " + e.message);
			}

			calculateRangeDataRatio();

			updateRangeChart();
			updateMainChart();

			updateMainDataSource();

			if (_traceEvents)
				trace(traceEventsPrefix + "initializeChartsFromMinMaxTimes (after)", "minimumTime", traceDate(minimumTime), "maximumTime", traceDate(maximumTime));
		}

		public function set data(value:ArrayCollection):void
		{
			if (value == null)
			{
		//		throw new Error("data must not be null");
				value = new ArrayCollection();
			}

			_data.removeEventListener(CollectionEvent.COLLECTION_CHANGE, data_collectionChange);
			_data = value;
			_data.addEventListener(CollectionEvent.COLLECTION_CHANGE, data_collectionChange, false, 0, true);
			initializeFromData();
		}

		private function data_collectionChange(event:CollectionEvent):void
		{
			pendingUpdateData = true;
			invalidateProperties();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			if (pendingUpdateData)
			{
				pendingUpdateData = false;
				updateFromData();
			}
		}

		private function updateFromData():void
		{
			if (isCreationComplete)
			{
				var isScrolledToNow:Boolean = rightRangeTime == maximumTime;
				commitDataChange();
				if (isScrolledToNow)
					scrollToNow();
			}
		}

		private function scrollToNow():void
		{

		}

//			private function calculateIndicatorConversionRatio():void
		//			{
		//				var i0:Number = 0;
		//				var i1:Number = rangeData.source.length - 1;
		//				var t0:Number = dateParse(rangeData.source[i0].date).time;
		//				var t1:Number = dateParse(rangeData.source[i1].date).time;
		//
		//				indicatorToDateSlope = (t1 - t0) / (i1 - i0);
		//				indicatorToDateIntercept = t0 - indicatorToDateSlope * i0;
		//			}

		//			private function calculateSliderConversionRatio():void
		//			{
		//				var i0:Number = 0;
		//				var i1:Number = rangeData.source.length - 1;
		//				var x0:Number = 0;
		//				var x1:Number = slider.m;
		//				var t0:Number = dateParse(rangeData.source[x0].date).time;
		//				var t1:Number = dateParse(rangeData.source[x1].date).time;
		//
		//				sliderToDateSlope = (t1 - t0) / (x1 - x0);
		//				sliderToDateIntercept = t0 - sliderToDateSlope * x0;
		//			}

		/**
		 * Called when HTTPService call completes the data load of the XML chart info.
		 */
		private function dataResult(event:ResultEvent):void
		{
			var tmpData:ArrayCollection = event.result.root.data;
			this.data = tmpData;
		}

		private function calculateRangeDataRatio():void
		{
		//				rangeDataRatio = ((dividedBox.width - 28) / rangeData.length);
			//				rangeDataRatio = ((dividedBox.width) / rangeData.length);
			// TODO: rangeDataRatio should be based on rangeChart width, not slider
			if (slider)
				rangeDataRatio = slider.width / (_maximumTime - _minimumTime);
		}

		/**
		 * If an error occurs loading the XML chart info
		 */
		private function faultResult(event:FaultEvent):void
		{
			Alert.show("Error retrieving XML data", "Error");
		}

		/**
		 * Called from updateComplete on Main chart series... when data is completely loaded, we set the defaults for the sliders and divider
		 * boxes etc... filtered to only run once (allowUpdateComplete) when the application first loads
		 */
		public function seriesComplete(event:FlexEvent):void
		{
			if (mainData.length > 0 && allowUpdateComplete)
			{
				allowUpdateComplete = false;
				updateBoxFromRangeTimes = true;
				rightRangeTime = _maximumTime;
				leftRangeTime = Math.max(_minimumTime, _maximumTime - initialDurationTime);
				updateBox();
				callLater(refreshAnnotations);
				this.visible = true;
		//					loadSampleAnnotations();

				if (rangeChart)
				{
					// TODO: Figure out how to remove this. This is a hack to get the axis labels to render correctly when the data is initially loaded; otherwise, we see "1970" at the far left edge of the axis
					rangeChart.horizontalAxis.dataChanged();
				}

				initializeFocusTime();

				this.validateNow();

				this.dispatchEvent(new Event("seriesComplete"));
			}
		}

		private function initializeFocusTime():void
		{
			focusTime = rightRangeTime;

			// TODO: avoid dispatching this event (because we may have multiple initializing McCune charts which do this, causing duplicate events)
			this.dispatchEvent(new FocusTimeEvent());
		}

		/**
		 * Simple parsing function to convert the date strings in our dataset to the equivalent Date object.
		 */
		public function dateParse(value:Date):Date
		{
		//				var dateArray:Array = value.split('-');
		//				return new Date(dateArray[0], dateArray[1] - 1, dateArray[2]);
			// TODO: eliminate
			return value;
		}

		/**
		 * Formats a date object from the DateTimeAxis into a label string
		 */
		private function formatDateLabel(value:Number, prevValue:Number, axis:DateTimeAxis):String
		{
			var dateValue:Date = new Date();
			dateValue.setTime(value + ((dateValue.timezoneOffset + 60) * 60 * 1000));
			switch (axis.labelUnits)
			{
				case "years":
					return labelYearFormatter.format(dateValue);
					break;
				case "months":
					return labelMonthFormatter.format(dateValue);
					break;
				case "days":
					return labelDayFormatter.format(dateValue);
				default:
					return labelDefaultFormatter.format(dateValue);
					break;
			}
		}

		/**
		 * Formats a date object from the DateTimeAxis into a label string
		 */
		private function formatDateLabel2(value:Number, prevValue:Number, axis:DateTimeAxisExtended):String
		{
			var dateValue:Date = new Date();
			dateValue.setTime(value + ((dateValue.timezoneOffset + 60) * 60 * 1000));
			switch (axis.labelUnits)
			{
				case "years":
					return labelYearFormatter.format(dateValue);
					break;
				case "months":
					return labelMonthFormatter.format(dateValue);
					break;
				case "days":
					return labelDayFormatter.format(dateValue);
				default:
					return labelDefaultFormatter.format(dateValue);
					break;
			}
		}

		/*Step 3 */
		/**
		 * Called throughout use to update the mainData range of data that is displayed by slicing the
		 * range data to the left and right values.
		 */
		private function updateMainData():void
		{
			hideDataPointHighlight();
			updateMainDataSource();
			refreshAnnotations();
			chartMouseOut();
			updateFocusTimeBox();
		}

		private var focusTimePositionLocked:Boolean = true;

		private function updateFocusTimeBox():void
		{
		//				focusTimeMarker.x = mainChartContainer.x + mainChart.x + mainChart.width - (focusTimeMarker.width / 2);

			if (focusTimeMarker)
			{
				if (focusTimePositionLocked)
					updateFocusTimeFromMarkerPosition();
				else
					updateFocusTime(_focusTime);
			}
		}

		private function sliceMainData():void
		{
			var i0:int = 0;
			var i1:int = rangeData.source.length - 1;

			for (var i:int = 0; i < rangeData.source.length; i++)
			{
				var dataItem:Object = rangeData.source[i];
				// use the first data point that is just before crossing the left edge
				if ((dataItem[dateField] as Date).time > leftRangeTime)
				{
					i0 = Math.max(0, i - 1);
					break;
				}
			}

			// TODO: handle the case where all of the data points are to the left of (before) leftRangeTime

			for (i = i0 + 2; i < rangeData.source.length; i++)
			{
				dataItem = rangeData.source[i];
				// use the first data point that is beyond the right edge
				if ((dataItem[dateField] as Date).time > rightRangeTime)
				{
					i1 = i + 1;
					break;
				}
			}

		//				trace("slicing in", this.id, i0, i1);
			mainData.source = rangeData.source.slice(i0, i1 + 1);
		}

		private function updateMainDataSource():void
		{
			if (!scrollEnabled)
			{
				sliceMainData();
			}

			var minimum:Number = leftRangeTime;
			var maximum:Number = rightRangeTime;

			mainChartDurationTime = maximum - minimum;
			var daysApart:Number = (maximum - minimum) / DAYS_TO_MILLISECONDS;

			mainDataRatio = mainChartArea.width / mainChartDurationTime;

//			trace("updateMainDataSource", "leftIndicator.x", leftIndicator.x.toFixed(2), "rightIndicator.x", rightIndicator.x.toFixed(2), "i0", i0, "i1", i1, "minimum", minimum.toFixed(0), "maximum", maximum.toFixed(0), "daysApart", daysApart.toFixed(2));
//						if (traceRangeTimes)
//							trace("updateMainDataSource", "leftRangeTime", leftRangeTime.toFixed(2), "rightRangeTime", rightRangeTime.toFixed(2), "minimum", minimum.toFixed(0), "maximum", maximum.toFixed(0), "daysApart", daysApart.toFixed(2));

			(this.mainChart.horizontalAxis as DateTimeAxis).minimum = new Date(minimum);
			(this.mainChart.horizontalAxis as DateTimeAxis).maximum = new Date(maximum);
			if (getStyle("volumeVisible"))
			{
				(this.mainChartVolume.horizontalAxis as DateTimeAxis).minimum = (this.mainChart.horizontalAxis as DateTimeAxis).minimum;
				(this.mainChartVolume.horizontalAxis as DateTimeAxis).maximum = (this.mainChart.horizontalAxis as DateTimeAxis).maximum;
			}

			if (_performanceCounter != null)
				_performanceCounter["updateMainDataSource"] += 1;

			if (_traceEvents)
				trace(traceEventsPrefix + "updateMainDataSource leftRangeTime", traceDate(leftRangeTime), "rightRangeTime", traceDate(rightRangeTime), "minimumTime", traceDate(minimumTime), "maximumTime", traceDate(maximumTime));
		}

		private function updateFps():void
		{
			if (_showFps && fpsDisplay)
			{
				var now:Date = new Date();
				if (_lastUpdate != null)
				{
					var totalDiff:Number = now.time - _lastUpdatesStack[0].time;
					var averageFps:Number = 1000 * _lastUpdatesStack.length / totalDiff;

					var diff:Number = now.time - _lastUpdate.time;
					var fps:Number = 1000 / diff;
					fpsDisplay.text =
							"FPS: " + fps.toFixed(2) + "\n" +
									diff.toFixed(0) + "\n" +
									"Avg FPS: " + averageFps.toFixed(2) + "\n" +
									totalDiff.toFixed(0) + "\n" +
									"count: " + _performanceCounter["updateMainDataSource"];

		//						fpsBar.setProgress(averageFps, this.stage.frameRate);
				}
				_lastUpdate = now;

				_lastUpdatesStack.push(now);
				if (_lastUpdatesStack.length > _lastUpdatesStackMax)
					_lastUpdatesStack.shift();

				_performanceCounter = new Object();
				_performanceCounter["updateMainDataSource"] = 0;
			}
		}

		/**
		 * Listener for enter frame event
		 * @param e event information
		 */
		private function enterFrameHandler(e:Event):void
		{
			updateFps();
		}

		/**
		 * Return time value corresponding to an indicator position (value is in milliseconds since the epoch).
		 */
		public function timeFromIndicator(indicatorPos:Number):Number
		{
			return indicatorToDateSlope * indicatorPos + indicatorToDateIntercept;
		}

		public function indicatorFromTime(time:Number):Number
		{
			return (time - indicatorToDateIntercept) / indicatorToDateSlope;
		}

		public function updateForScroll():void
		{
			updateBox();
		}

		/**
		 * Called from the slider value changes.  It is filtered to only change when the slider calling it
		 * directly.  The updateBoxFromSlider value is set to false when the moveSlider function effect is
		 * playing because the box widths have already been set by the dividerRelease calling
		 * updateIndicatorValuesWithEffect.
		 */
		private function updateBox():void
		{
			if (updateBoxFromRangeTimes)
			{
				//setting the box width value to the slider value times the ratio (to decrease
				//it to the equivalent width percentage
				//eg. full divided box width = 500, rangeDataRatio = 1/5 would equal 100 for the
				//proper left box width equal to range index value
				if (leftBox)
					leftBox.width = rangeTimeToRangeChartPos(leftRangeTime);
				if (rightBox)
					rightBox.width = dividedBox.width - rangeTimeToRangeChartPos(rightRangeTime);
		//					middleBox.width = NaN;
				if (middleBox)
					middleBox.width = NaN;
//				if (!isNaN(slider.values[0]))
//					leftRangeTime = slider.values[0];
//				if (!isNaN(slider.values[1]))
//					rightRangeTime = slider.values[1];
		//					(groupBetweenMainRange.getElementAt(1) as Line).validateNow();
			}

			if (slider)
			{
				slider.values[0] = leftRangeTime;
				slider.values[1] = rightRangeTime;
			}
			updateMainData();
		}

		private function rangeTimeToRangeChartPos(value:Number):Number
		{
			return (value - _minimumTime) * rangeDataRatio;
		}

		private function rangeChartPosToRangeTime(value:Number):Number
		{
			return (value / rangeDataRatio) + _minimumTime;
		}

		private function mainChartPosToSliderValue(value:Number):Number
		{
			return (value / mainDataRatio) + leftRangeTime;
		}

		/**
		 * Updates the range by moving the entire range left or right by a fixed number of units
		 */
		private function clickUpdate(value:int):void
		{
			leftRangeTime += value / rangeDataRatio;
			rightRangeTime += value / rangeDataRatio;
			if (slider)
				slider.dispatchEvent(new SliderEvent('change'));
		}

		private function mainChartUpdate(value:Number):void
		{
			leftRangeTime += value / mainDataRatio;
			rightRangeTime += value / mainDataRatio;
			if (slider)
				slider.dispatchEvent(new SliderEvent('change'));
			this.updateForScroll();
			this.dispatchScrollEvent();
		}

		/**
		 * Called from the divided box dividerRelease.  Calls a Move for the left and right Indicator
		 * x values which has an easing function
		 * applied.
		 */
		private function updateIndicatorValuesWithEffect():void
		{
			//setting indicator positions to the box width divided by the ratio (to increase
			//it to the equivalent range value)
			//eg. left box width = 100, rangeDataRatio = 1/5 would equal 500 for the range index value

			animateRangeTimes(rangeChartPosToRangeTime(leftBox.width), rangeChartPosToRangeTime(dividedBox.width - rightBox.width), false);
		}

		/**
		 * Called from the thumbRelease on the slider instance, as well as creationComplete
		 * to set the initial range values.
		 * Updates the left and right indicator x values without the move effect.
		 */
		private function updateIndicatorsQuietly():void
		{
			//these two values are mapped 1:1 as the slider values and indicator values equal the rangeData length exactly
			if (slider)
			{
				leftRangeTime = slider.values[0];
				rightRangeTime = slider.values[1];
			}
		}

		private var _rangeTimeAnimate:Animate;
		private var _leftRangeMotionPath:SimpleMotionPath;
		private var _rightRangeMotionPath:SimpleMotionPath;
		
		private var _focusTimeMoveEffect:Move;

		private var _pendingUpdateBoxFromRangeTimes:Boolean;
		private var _pendingAnimateLeftRangeTime:Number;
		private var _pendingAnimateRightRangeTime:Number;
		private var _pendingLeftRangeTime:Number;
		private var _pendingRightRangeTime:Number;
		private var compareResultToBruteForceSearch:Boolean = false;
		protected var _logger:ILogger;
		private var skipSearch:Boolean = false;

		private function initializeRangeTimeAnimate():void
		{
			_rangeTimeAnimate = new Animate(this);
			_rangeTimeAnimate.motionPaths = new Vector.<MotionPath>();
			_leftRangeMotionPath = new SimpleMotionPath("leftRangeTime");
			_rangeTimeAnimate.motionPaths.push(_leftRangeMotionPath);
			_rightRangeMotionPath = new SimpleMotionPath("rightRangeTime");
			_rangeTimeAnimate.motionPaths.push(_rightRangeMotionPath);
			
			_rangeTimeAnimate.easer = new Power(0.5, 3);
			_rangeTimeAnimate.duration = 750;
			
			_rangeTimeAnimate.addEventListener(EffectEvent.EFFECT_START, function(event:EffectEvent):void
			{
				updateBoxFromRangeTimes = _pendingUpdateBoxFromRangeTimes;
			});
			_rangeTimeAnimate.addEventListener(EffectEvent.EFFECT_UPDATE, function(event:EffectEvent):void
			{
				updateBox();
				dispatchScrollEvent();
			});
			_rangeTimeAnimate.addEventListener(EffectEvent.EFFECT_END, function(event:EffectEvent):void
			{
				updateBoxFromRangeTimes = true;
				showAnnotations = true;
				callLater(refreshAnnotations);
//				if (callbackFunc != null) callbackFunc.call(this, rest)
			});
		}

		private function initializeFocusTimeAnimate():void
		{
			_focusTimeMoveEffect = new Move(focusTimeMarker);

			_focusTimeMoveEffect.easer = new Power(0.5, 3);
			_focusTimeMoveEffect.duration = 750;

			_focusTimeMoveEffect.addEventListener(EffectEvent.EFFECT_UPDATE, function(event:EffectEvent):void
			{
				updateFocusTimeFromMarkerPosition();
				this.dispatchEvent(new FocusTimeEvent());
			});
		}
		
		private function animateRangeTimes(leftRangeTimeTo:Number, rightRangeTimeTo:Number = NaN, update:Boolean = true):void
		{
			if (!isNaN(leftRangeTime) && !isNaN(rightRangeTime))
			{
				// determine if any change is required
				if ((!isNaN(leftRangeTimeTo) && leftRangeTimeTo != leftRangeTime) || (!isNaN(rightRangeTimeTo) && rightRangeTimeTo != rightRangeTime))
				{
					hideAnnotations();
					_pendingUpdateBoxFromRangeTimes = update;
					_rangeTimeAnimate.stop();
					_leftRangeMotionPath.valueFrom = leftRangeTime;
					_leftRangeMotionPath.valueTo = isNaN(leftRangeTimeTo) ? leftRangeTime : leftRangeTimeTo;
					_rightRangeMotionPath.valueFrom = rightRangeTime;
					_rightRangeMotionPath.valueTo = isNaN(rightRangeTimeTo) ? rightRangeTime : rightRangeTimeTo;
					_rangeTimeAnimate.play();
				}
			}
		}
		
		private function animateFocusTimeMarker(x:Number):void
		{
			hideDataPointHighlight();
			if (focusTimeMarker)
			{
				focusTimeMarker.x = x;
				updateFocusTimeFromMarkerPosition();
			}
			else
			{
				updateFocusTimeFromX(x);
			}
			this.dispatchEvent(new FocusTimeEvent());

//			_focusTimeMoveEffect.stop();
//			_focusTimeMoveEffect.xFrom = focusTimeMarker.x;
//			_focusTimeMoveEffect.xTo = focusTimeMarkerMaxX;
//			_focusTimeMoveEffect.play();
		}

		private function animateFocusTimeMarkerToDate(date:Date):void
		{
			focusTime = date.getTime();
			this.dispatchEvent(new FocusTimeEvent());
		}

		/**
		 * Moves the left and right indicator x values with an easing transition applied.  update
		 * dictates whether this should update the divided box range measurements (false if we're calling this
		 * from the divided box release) callbackFunc can be passed to get called when the move is finished.
		 */
/*
		private function moveSlider(target:VRule, xTo:Number, update:Boolean, callbackFunc:Function = null,
									... rest):void
		{
			var moveRange:SimpleMotionPath = new SimpleMotionPath();
			var rangeAnimate:Animate = new Animate(this);
			rangeAnimate.end();
			rangeAnimate.easer = new Power(0.5, 3);
			rangeAnimate.duration = 750;
		//				rangeAnimate.target = this;
			if (target == leftIndicator)
				moveRange.property = "leftRangeTime";
			else if (target == rightIndicator)
				moveRange.property = "rightRangeTime";
			else
				throw new ArgumentError("target must be leftIndicator or rightIndicator");

			moveRange.valueTo = xTo;
			rangeAnimate.addEventListener(EffectEvent.EFFECT_START, function():void
			{
				updateBoxFromSlider = update
			});
			rangeAnimate.addEventListener(EffectEvent.EFFECT_UPDATE, function():void
			{
				updateBox();
				dispatchScrollEvent();
			});
			rangeAnimate.addEventListener(EffectEvent.EFFECT_END, function():void
			{
				updateBoxFromSlider = true;
				showAnnotations = true;
				callLater(refreshAnnotations);
				if (callbackFunc != null) callbackFunc.call(this, rest)
			});
			rangeAnimate.motionPaths = new Vector.<MotionPath>();
			rangeAnimate.motionPaths.push(moveRange);
			rangeAnimate.play();
		}
*/

		/**
		 * Called from range chart or main chart and determines the position of the mouse as well as left
		 * and right indicators (for static comparison when moving) and adds systemManager events
		 * to capture mouse movement.  The values set here are used in the moveChart function to calculate
		 * new position differences with start position
		 */
		private function setMouseDown(theChart:CartesianChart):void
		{
			//don't capture for drag if we're viewing the entire range of data
			if (!(leftRangeTime == _minimumTime && rightRangeTime == _maximumTime))
			{
				hideAnnotations();
				mouseXRef = this.mouseX;
				staticLeftBoundary = leftRangeTime;
				staticRightBoundary = rightRangeTime;
				if (theChart == mainChart) mainDrag = true;
				if (theChart == rangeChart) rangeDrag = true;
				this.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, moveChart);
				this.systemManager.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			}
		}

		/**
		 * Called when systemManager receives mouseUp event.  Sets the indicators for which range is
		 * being dragged to false, and removes the system manager event listeners for drag movement.
		 */
		private function stopDragging(event:MouseEvent):void
		{
			if (rightRangeTime - leftRangeTime < minimumDurationTime)
			{
				rightRangeTime = Math.min(_maximumTime, leftRangeTime + minimumDurationTime);
				leftRangeTime = Math.max(_minimumTime, rightRangeTime - minimumDurationTime);
				updateBox();
			}
			rangeDrag = false;
			mainDrag = false;
			this.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, moveChart);
			this.systemManager.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}

		/**
		 * Determines which chart instance is being dragged, and updates the left and right indicator x values
		 */
		private function moveChart(event:MouseEvent):void
		{
		//				trace("moveChart " + this.mouseX + ", " + this.mouseY + " mainDrag = " + mainDrag + " rangeDrag = " + rangeDrag);

			var targetLeftRangeTime:Number;
		//				var targetRightRangeTime:Number;

			if (mainDrag)
			{
				var mainChartPixelsToTime:Number = mainChartDurationTime / mainChartArea.width;
				targetLeftRangeTime = staticLeftBoundary + (mouseXRef - this.mouseX) * mainChartPixelsToTime;
		//					targetRightRangeTime = staticRightBoundary + (mouseXRef - this.mouseX) * mainChartPixelsToTime;
			}
			else if (rangeDrag)
			{
				var rangeChartPixelsToTime:Number = (_maximumTime - _minimumTime) / rangeChart.width;
				targetLeftRangeTime = staticLeftBoundary - (mouseXRef - this.mouseX) * rangeChartPixelsToTime;
		//					targetRightRangeTime = staticRightBoundary - (mouseXRef - this.mouseX) * rangeChartPixelsToTime;
			}

			var leftToRight:Number = rightRangeTime - leftRangeTime;

			// constrain drag to be within min/max values
			leftRangeTime = Math.max(_minimumTime, Math.min(_maximumTime - leftToRight, targetLeftRangeTime));
		//				var constrainLeftDelta:Number = leftRangeTime - targetLeftRangeTime;
			rightRangeTime = leftRangeTime + leftToRight;

			updateBoxFromRangeTimes = true;
			updateBox();
			dispatchScrollEvent();
		}

		protected function dispatchScrollEvent():void
		{
			this.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL));
		}

		/* Step 4 */
		/**
		 * Finds the DateTimeAxis value (the date) of the mouseover position
		 */
		private function getChartDataPoint():void
		{
			//filtering to only run if the full dataset is present in the chart...
			//this value is false if the indicator move effect is playing
			if (updateBoxFromRangeTimes)
			{
//							var chartPoint:Object = getChartCoordinates(new Point(mainChart.mouseX, mainChart.mouseY), mainChart);
//							var formattedDate:String = fullDateFormat.format(new Date(chartPoint.x));
//							trace("getChartDataPoint", formattedDate);
//
//							if (mainChart.series[0].numChildren - 1 == mainData.length)
//							{
//								var result:int = findDataPoint(mainData, chartPoint.x);
//								if (result > -1)
//								{
//									//						var dataItem:Object = mainData.getItemAt(result);
//									mainChart.series[0].getChildAt(result). (true);
//									//							mainChartVolume.series[0].getChildAt(result).showRenderer(true);
//								}
//							}

//							selectChartDataPoint();

//							for(var i:int = 0; i < mainData.length; i++)
//							{
//								var dataItem:Object = mainData.getItemAt(i);
//								if(dataItem.date == formattedDate)
//								{
//									_selectedDate = labelSummaryDateFormatter.format(dateParse(dataItem.date));
//									_selectedClose = 'Price: ' + dollarFormatter.format(Number(dataItem.close));
//									_selectedVolume = 'Vol: ' + volumeFormatter.format(Number(dataItem.volume));
//									mainChart.series[0].getChildAt(i + 1).showRenderer(true);
//									mainChartVolume.series[0].getChildAt(i + 1).showRenderer(true);
//								}
//								else
//								{
//									mainChart.series[0].getChildAt(i + 1).showRenderer(false);
//									mainChartVolume.series[0].getChildAt(i + 1).showRenderer(false);
//								}
//							}
//							for(var i:int = 0; i < mainChart.series[0].numChildren; i++)
//							{
//								mainChart.series[0].getChildAt(i).showRenderer(true);
//								mainChartVolume.series[0].getChildAt(i).showRenderer(true);
//							}

			}
		}

		private function selectChartDataPoint():void
		{
			for (var s:int = 0; s < mainChart.series.length; s++)
			{
				var series:Series = mainChart.series[s] as Series;

				var points:Array = series.findDataPoints(series.mouseX, series.mouseY, highlightChartItemBullsEye.width);
				if (points.length > 0)
				{
		//						trace("getChartDataPoint", points.length, "points", points[0]);
					var hitData:HitData = points[0] as HitData;
					if (hitData != null && highlightedItem != hitData.chartItem)
					{
						highlightClickedChartItem(hitData.chartItem);
						// only highlight the first item found; for overlapping series, obscured data points may not be selectable
						return;
					}
				}
			}

			// if no point found, hide the highlight
			hideDataPointHighlight();
		}

		private function highlightClickedChartItem(chartItem:ChartItem):void
		{
			var chartItemX:Number = highlightChartItem(chartItem);
			dispatchEvent(new ChartItemEvent(ChartItemEvent.ITEM_CLICK, [highlightedItem]));

			// If possible, we move the focus time the exact date, instead of trying to infer the date from the item position
			var date:Date;
			var series:Series = chartItem.element as Series;
			if (series)
			{
				if (series.hasOwnProperty("xField"))
				{
					var xField:String = series["xField"] as String;
					if (xField && chartItem.item.hasOwnProperty(xField))
					{
						date = chartItem.item[xField] as Date;
					}
				}
			}
			if (date)
				animateFocusTimeMarkerToDate(date);
			else
				animateFocusTimeMarker(chartItemX);
		}

		/**
		 * Highlights a chart item and returns the x coordinate of the item
		 * @param chartItem
		 * @return
		 */
		public function highlightChartItem(chartItem:ChartItem):Number
		{
			if (highlightChartItemEffect)
				highlightChartItemEffect.stop();

			var chartItemX:Number;
			var chartItemY:Number;
			if (chartItem.hasOwnProperty("x"))
				chartItemX = chartItem["x"];
			else
				chartItemX = chartItem.itemRenderer.x + chartItem.itemRenderer.width / 2;

			if (chartItem.hasOwnProperty("y"))
				chartItemY = chartItem["y"];
			else
				chartItemY = chartItem.itemRenderer.y + chartItem.itemRenderer.height / 2;

			highlightChartItemBullsEye.x = chartItemX - highlightChartItemBullsEye.width / 2;
			highlightChartItemBullsEye.y = chartItemY - highlightChartItemBullsEye.height / 2;
//			highlightChartItemEffectScopeLeftMove.xFrom = 0;
//			highlightChartItemEffectScopeLeftMove.xTo = chartItemX - highlightChartItemScopeLeft.width;


			highlightedItem = chartItem;
			highlightChartItemGroup.visible = true;
			if (highlightChartItemEffect)
				highlightChartItemEffect.play();
			return chartItemX;
		}

		public function hideDataPointHighlight():void
		{
			highlightedItem = null;
			highlightChartItemGroup.visible = false;
		}

		/**
		 * Finds the data point from the main data series in the currently visible set of data in the main chart that
		 * has a date which is less than or equal to the specified date and is closest to the specified date.
		 * @param dateValue The date to find a nearby data point to
		 * @return The data point which is less than or equal to the specified date and is closest to the specified date
		 */
		public function findPreviousDataPoint(dateValue:Number):Object
		{
			var result:int = findPreviousDataIndex(dateValue);
			return result != -1 ? mainData.getItemAt(result) : null;
		}

		/**
		 * Finds the index of the data point from the main data series in the currently visible set of data in the main chart that
		 * has a date which is less than or equal to the specified date and is closest to the specified date.
		 * @param dateValue The date to find a nearby data point to
		 * @return The index of the data point which is less than or equal to the specified date and is closest to the specified date
		 */
		public function findPreviousDataIndex(dateValue:Number):int
		{
			var dataCollection:ArrayCollection = mainData;
			var result:int = -1;

			if (dataCollection != null)
			{
				var numDataPoints:int = mainData.length;
				if (numDataPoints > 0)
				{
					var mainDataT0:Number = dataCollection.getItemAt(0)[dateField].time;
					var mainDataT1:Number = dataCollection.getItemAt(numDataPoints - 1)[dateField].time;
					var mainDataDuration:Number = mainDataT1 - mainDataT0;
					var averageDataPointDuration:Number = mainDataDuration / numDataPoints;
					var strategy:String;

					var guessIndex:int;
					if (averageDataPointDuration == 0)
						guessIndex = 0;
					else
						guessIndex = Math.floor((dateValue - mainDataT0) / averageDataPointDuration);

					if (guessIndex < 0)
					{
//						var message:String = "mainDataT0 " + traceDate(mainDataT0) + " mainDataT1 " + traceDate(mainDataT1) + " dateValue " + traceDate(dateValue);
//						_logger.warn("guessIndex " + guessIndex + " is less than 0 " + message);
						result = -1;
					}
					else if (guessIndex > numDataPoints - 1)
					{
//						_logger.warn("guessIndex " + guessIndex + " is greater than " + (numDataPoints - 1) + " (numDataPoints - 1)");
						result = numDataPoints - 1;
					}
					else
					{
						var dataItem:Object = dataCollection.getItemAt(guessIndex);
						var dataItemTime:Number = dataItem[dateField].time;
						if (dataItemTime == dateValue) // . . . g| . . .
						{
							strategy = "guessed " + guessIndex + " (exactly)";
							result = guessIndex;
						}
						else if (dataItemTime < dateValue) //  . . g . . | . . .
						{
							// . . g |    or    . . g | . . .
							if (guessIndex == numDataPoints - 1 || dataCollection.getItemAt(guessIndex + 1)[dateField].time > dateValue)
							{
								strategy = "guessed " + guessIndex + " (just prior)";
								result = guessIndex;
							}
							else //  . . g . . | . . .
							{
								strategy = "searched after guess " + guessIndex;
								result = binarySearch(dataCollection, dateValue, guessIndex, numDataPoints - 1)
							}
						}
						else //  . . . | . . g . .
						{
							if (guessIndex <= 0)
							{
								result = -1;
							}
							else if (dataCollection.getItemAt(guessIndex - 1)[dateField].time < dateValue)
							{
								strategy = "guessed " + guessIndex + " (just after)";
								result = guessIndex - 1;
							}
							else
							{
								strategy = "searched before guess " + guessIndex;
								result = binarySearch(dataCollection, dateValue, 0, guessIndex - 1);
							}
						}
					}

					if (compareResultToBruteForceSearch)
					{
						var result2:int = -1;
						for (var i:int = dataCollection.length - 1; i >= 0; i--)
						{
							dataItem = dataCollection.getItemAt(i);
							if (dataItem[dateField].time <= dateValue)
							{
								result2 = i;
								break;
							}
						}
						strategy = strategy ? " when it " + strategy : "";
						if (result != result2)
							_logger.warn("findPreviousDataPoint optimized search found " + result + (result >= 0 ? " " + traceDate(dataCollection.getItemAt(result)[dateField].time) : "") +
												 " but should have found " + result2 + (result2 >= 0 ? " " + traceDate(dataCollection.getItemAt(result2)[dateField].time) : "") + strategy);
						else
							_logger.info("findPreviousDataPoint optimized search found the correct result " + result + (result >= 0 ? " " + traceDate(dataCollection.getItemAt(result)[dateField].time) : "") +
												 strategy);

						result = result2;
					}
				}

			}
			return result;
		}

		public function binarySearch(dataCollection:ArrayCollection, dateValue:Number, i1:int, i2:int):int
		{
			if (skipSearch)
				return -1;

			if (i1 < 0)
				throw new ArgumentError("i1 must be 0 or greater");
			if (i2 > dataCollection.length - 1)
				throw new ArgumentError("i2 must be " + (dataCollection.length - 1) + " (dataCollection.length - 1) or less");

			while (i2 - i1 >= 0)
			{
				var middleIndex:int = i1 + Math.ceil((i2 - i1) / 2);
				var middleItem:Object = dataCollection.getItemAt(middleIndex);
				var middleTime:Number = middleItem[dateField].time;

				if (middleTime == dateValue) // i1 . m| . i2
				{
					return middleIndex;
				}
				else if (middleTime < dateValue) // i1 .  m  . | i2
				{
					if (middleIndex == i1)
						return middleIndex;

					i1 = middleIndex;
				}
				else // i1 | . m . i2
				{
					i2 = middleIndex - 1;
				}
			}

			return -1;
		}

		private function findDataPoint(dataCollection:ArrayCollection, dateValue:Number):int
		{
			const delta:Number = 1 * DAYS_TO_MILLISECONDS;
			for (var i:int = 0; i < dataCollection.length; i++)
			{
				var dataItem:Object = dataCollection.getItemAt(i);
				if (Math.abs(dataItem[dateField].time - dateValue) < delta)
				{
					return i;
				}
			}

			return -1;
		}

		/**
		 * Called when cursor is moved off of main chart area.  Clears any values that are bound
		 * to mouseover position, and clears all
		 * LineSeriesCustomRenderers on the chart that are showing
		 */
		private function chartMouseOut():void
		{
			if (mainData.length > 2)
			{
				for (var i:int = 0; i < mainData.length; i++)
				{
					try
					{
						mainChart.series[0].getChildAt(i + 1).showRenderer(false);
						if (getStyle("volumeVisible"))
							mainChartVolume.series[0].getChildAt(i).showRenderer(false);
					}
					catch(e:Error)
					{
					}
				}
				_selectedDate = labelSummaryDateFormatter.format(dateParse(mainData.getItemAt(0)[dateField])) + ' - ' +
						labelSummaryDateFormatter.format(dateParse(mainData.getItemAt(mainData.length - 1)[dateField]));
				_selectedClose = percentageFormatter.format((Number(mainData.getItemAt(mainData.length - 1)[seriesName]) /
						Number(mainData.getItemAt(0)[seriesName]) - 1) * 100) + '%';
				_selectedVolume = '';
			}
			else
			{
				_selectedDate = '';
				_selectedClose = '';
				_selectedVolume = '';
			}

		}

		/**
		 * Finds the DateTimeAxis value (the date) of the mouseover position
		 * invertTransform takes a point in stage space (x and y coordinate) and transforms it into the
		 * relative point in data space, giving appropriate values along x axis (first item in return array),
		 * and y axis (second item in return array)
		 */
		private function getChartCoordinates(thePos:Point, theChart:CartesianChart):Object
		{
			var tmpArray:Array;
			if (theChart.series[0] != null)
			{
				tmpArray = theChart.series[0].dataTransform.invertTransform(thePos.x, thePos.y);
				return {x:tmpArray[0], y:tmpArray[1]};
			}
			else
			{
				return null;
			}
		}

		/**
		 * Updates the date range display to reflect the current position of the divided box drag
		 */
		private function setDividerDragDate():void
		{
			var tmpLeftRangeTime:Number = rangeChartPosToRangeTime(leftBox.width);
			var tmpRightRangeTime:Number = rangeChartPosToRangeTime(dividedBox.width - rightBox.width);
		//				var tmpLeftIndex:int = leftBox.width  / rangeDataRatio;
		//				var tmpRightIndex:int = ((dividedBox.width - rightBox.width) / rangeDataRatio) - 1;
			if (tmpLeftRangeTime >= _minimumTime && tmpRightRangeTime <= _maximumTime)
			{
				_selectedDate = labelSummaryDateFormatter.format(new Date(tmpLeftRangeTime)) + ' - ' +
						labelSummaryDateFormatter.format(new Date(tmpLeftRangeTime));
		//					_selectedClose = percentageFormatter.format((Number(rangeData.getItemAt(tmpRightIndex).close) /
		//						Number(rangeData.getItemAt(tmpLeftIndex).close) - 1) * 100) + '%';
				_selectedClose = '(not implemented)';
				_selectedVolume = '';
			}
		}

		/**
		 * Called from form entry for new annotation.  Creates an AnnotationVO instance with the form data, adds it to the array collection
		 * and then sorts to include new annotation date and reset labels correspondingly.
		 */
		private function addAnnotation():void
		{
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(),
													 annDate.selectedDate,
													 annDescription.text,
													 false,
													 ''));
			var dateSort:Sort = new Sort();
			dateSort.fields = [new SortField("date", false, true)];
			dateSort.sort(annotationItems.source);
			setAnnotationLabels();
			annotationItems.refresh();
			refreshAnnotations();
		}

		/**
		 * Whenever an annotation is added, this method is called to update the alphabetical letter
		 */
		private function setAnnotationLabels():void
		{
			for (var i:int = 0; i < annotationItems.length; i++)
			{
				AnnotationVO(annotationItems[i]).letterLabel = alphabet[i];
			}
		}

		;

		// number of extra pixels to grow the selected duration window when selecting an annotation that is currently out of range
		private const GROW_DURATION_PADDING:Number = 30;

		/**
		 * This method is called from list of annotations when an instance is clicked.  It checks to see if the
		 * annotation date is within the currently viewed range.  If not, it finds the appropriate index
		 * value of the range data to expand to, calls the moveSlider function to move left or right to fit the range
		 * and after the movement is completed, this function is re-called by the moveSlider end to check again.
		 * If the item is within the viewable range, we loop through the array of anntations and sets selected to true
		 * on the target annotation, and selected to false on all other annotations.  refreshAnnotations is then
		 * called to update the annotation flags with the selected value
		 */
		public function hightlightAnnotation(args:Array):void
		{
			var targetUID:String = args[0];
			var targetDate:Date = args[1];
		//				var i:int;
		//				var targetIndex:int;

		//				var items:Array = largeSeries.items;

		//				if(targetDate < items[0].item.date)
			if (dateParse(targetDate).time < leftRangeTime)
			{
		//					for(i = 0; i < rangeData.length; i++)
		//					{
		//						if(rangeData.getItemAt(i).date == targetDate)
		//						{
		//							targetIndex = (i >= 10) ?  i - 10 : 0;
		//							break;
		//						}
		//					}
				showAnnotations = false;
		//					moveSlider(leftIndicator, targetIndex, true, hightlightAnnotation, targetUID, targetDate);
				animateRangeTimes(dateParse(targetDate).time - GROW_DURATION_PADDING / mainDataRatio);
				// TODO: highlight the annotation after animating
//						   hightlightAnnotation, targetUID, targetDate);
			}
		//				else if(targetDate > items[items.length - 1].item.date)
			else if (dateParse(targetDate).time > rightRangeTime)
			{
		//					for(i = 0; i < rangeData.length; i++)
		//					{
		//						if(rangeData.getItemAt(i).date == targetDate)
		//						{
		//							targetIndex = (i <= (rangeData.length - 11)) ?  i + 10 : 0;
		//							break;
		//						}
		//					}
				showAnnotations = false;
		//					moveSlider(rightIndicator, targetIndex, true, hightlightAnnotation, targetUID, targetDate);
				animateRangeTimes(NaN, dateParse(targetDate).time + GROW_DURATION_PADDING / mainDataRatio);
				// TODO: highlight the annotation after animating
//						   hightlightAnnotation, targetUID, targetDate);
			}
			else
			{
				for each(var annListItem:AnnotationVO in annotationItems)
				{
					if (annListItem.annID == targetUID)
						annListItem.selected = true;
					else
						annListItem.selected = false;
				}
				annotationItems.refresh();
				refreshAnnotations();
			}
		}

		/**
		 * Loops through the array of annotation objects and sets selected on the target annotation.
		 * refreshAnnotations is then called to update the annotation flags with the selected value
		 */
		private function highlightListAnnotation(event:Event):void
		{
			for each(var annListItem:AnnotationVO in annotationItems)
			{
				if (annListItem.annID == event.target.annID)
					annListItem.selected = true;
				else
					annListItem.selected = false;
			}
			refreshAnnotations();
		}


		/**
		 * Loops through the array of annotation objects and looks for the data array item in the main chart
		 * which matches this annotation's date.  When found, an EventAnnotation object is created and added to
		 * the annotationCanvas (on annotationElements property of mainChart) and positioned to the AreaSeries
		 * renderer instance for the datapoint on the chart.
		 */
		protected function refreshAnnotations():void
		{
			// TODO: dynamic support for disabling annotations
			return;

		//				var items:Array = largeSeries.items;
			if (mainChart.series.length < 1)
				return;
			//throw new Error("Main chart has no series");

			var items:Array = mainChart.series[0].items;

			if (items != null && items.length > 0)
			{
				annotationCanvas.removeAllChildren();
				if (showAnnotations)
				{
					var rangeStart:Date = items[0].item.date;
					var rangeEnd:Date = items[items.length - 1].item.date;
					//loop through the annotation instances
					for each(var annInstance:AnnotationVO in annotationItems)
					{
						//if this annotations date is within the currently viewed range
						if (annInstance.date > rangeStart && annInstance.date < rangeEnd)
						{
							for (var i:int = 0; i < items.length; i++)
							{
								var dataItem:Object = items[i].item;
								//if this data itme matches our annotation, AND, if this isn't going to render
								//off the edge of the graph
								if (dataItem.date == annInstance.date && items.length >= i + 1)
								{
									var newAnn:EventAnnotation = new EventAnnotation();
									newAnn.letterLabel = annInstance.letterLabel;
									newAnn.annID = annInstance.annID;
									newAnn.selected = annInstance.selected;

									//represents the LineSeriesCustomRenderer object for this datapoint on the chart
									//adding one for our getChildAt to compensate for the area child of AreaChart
									var foundItem:AreaSeriesItem = items[i + 1];
									newAnn.x = foundItem.x;
									newAnn.y = foundItem.y - 34;
									newAnn.addEventListener("annotationClicked", highlightListAnnotation);
									annotationCanvas.addChild(newAnn);
								}
							}
						}
					}
				}
			}
		}

		/**
		 * removes all annotations showing on annotationCanvas and sets the showAnnotations flag to false.
		 * called when the chart range is being changed by dragging the main or range chart, the divider
		 * being released and the indicator moveSlider function is called.
		 */
		protected function hideAnnotations():void
		{
			showAnnotations = false;
			annotationCanvas.removeAllChildren();
		}

		/**
		 * Sample annotations
		 */
		private function loadSampleAnnotations():void
		{
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2007-03-15'), 'Test Item 1', false,
													 ''));
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2007-01-03'), 'Test Item 2', false,
													 ''));
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2006-11-29'), 'Test Item 3', false,
													 ''));
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2006-10-19'), 'Test Item 4', false,
													 ''));
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2006-09-12'), 'Test Item 5', false,
													 ''));
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2006-08-08'), 'Test Item 6', false,
													 ''));
			annotationItems.addItem(new AnnotationVO(UIDUtil.createUID(), new Date('2006-07-14'), 'Test Item 7', false,
													 ''));
			setAnnotationLabels();
		}

		protected function dividedBox_resizeHandler(event:ResizeEvent):void
		{
			calculateRangeDataRatio();
		}

		protected function slider_resizeHandler(event:ResizeEvent):void
		{
			var oldFocusTime:Number = _focusTime;
			updateBox();
			refreshAnnotations();
			updateFocusTime(oldFocusTime);
		}

		protected function rangeTodayButton_clickHandler(event:MouseEvent):void
		{
			var delta:Number = rightRangeTime - leftRangeTime;

			var todayTime:Number = today.time;

			// don't try to go beyond the maximum value for which there is data
			var rangeChartMaximum:Number = maximumTime;
			todayTime = Math.min(todayTime, rangeChartMaximum);

			animateRangeTimes(todayTime - delta, todayTime);
			animateFocusTimeMarker(focusTimeMarkerMaxX);
		}

		public function get today():Date
		{
			if (_today != null)
				return _today;
			else
				return new Date();
		}

		public function set today(value:Date):void
		{
			_today = value;
		}

		public function get maximumDate():Date
		{
			return isNaN(_maximumTime) ? null : new Date(_maximumTime);
		}

		public function get maximumTime():Number
		{
			return _maximumTime;
		}

		public function get minimumDate():Date
		{
			return isNaN(_minimumTime) ? null : new Date(_minimumTime);
		}

		public function get minimumTime():Number
		{
			return _minimumTime;
		}

		public function set minimumTime(value:Number):void
		{
			// TODO: support reseting/clearing the minimum/maximum to the default (based on the data)
			if (_traceEvents)
				trace(traceEventsPrefix + "set minimumTime", traceDate(value), "old value", traceDate(minimumTime));
			if (this.rangeChart)
				(this.rangeChart.horizontalAxis as DateTimeAxis).minimum = new Date(value);
			_minimumTime = value;
			initializeChartsFromMinMaxTimes();
		}

		public function set maximumTime(value:Number):void
		{
			if (_traceEvents)
				trace(traceEventsPrefix + "set maximumTime", traceDate(value), "old value", traceDate(maximumTime));
			if (this.rangeChart)
				(this.rangeChart.horizontalAxis as DateTimeAxis).maximum = new Date(value);
			_maximumTime = value;
			initializeChartsFromMinMaxTimes();
		}

		private var focusTimeFirstMousePos:Point;
		private var focusTimeFirstPos:Point;

		[Embed(source="/assets/horizontalMove.png")]
		private var horizontalMoveCursor:Class;
		private var horizontalMoveCursorId:int;

		protected function focusTimeGroup_mouseDownHandler(event:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, focusTimeGroup_mouseMoveHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, focusTimeGroup_mouseUpHandler);

			focusTimeFirstMousePos = this.globalToLocal(event.target.localToGlobal(new Point(event.localX,
																							 event.localY)));
			focusTimeFirstPos = new Point(focusTimeMarker.x, focusTimeMarker.y);

			// TODO: determine why this isn't working and fix; currently disabled because this results in no visible cursor
		//				horizontalMoveCursorId = this.cursorManager.setCursor(horizontalMoveCursor, CursorManagerPriority.MEDIUM, -8, -8);

			event.stopImmediatePropagation();
		}

		private function get focusTimeMarkerMinX():Number
		{
			var mainHorizontalAxisLeft:Number = mainChartContainer.x + mainChart.x + mainChart.computedGutters.left;
			var xMin:Number = mainHorizontalAxisLeft - focusTimeMarker.width / 2;
			return xMin;
		}
		private function get focusTimeMarkerMaxX():Number
		{
			var mainHorizontalAxisRight:Number = mainChartContainer.x + mainChart.x + mainChart.width - mainChart.computedGutters.right;
			var xMax:Number = mainHorizontalAxisRight - focusTimeMarker.width / 2;
			return xMax;
		}
		protected function focusTimeGroup_mouseMoveHandler(event:MouseEvent):void
		{
			var currentMousePos:Point = this.globalToLocal(event.target.localToGlobal(new Point(event.localX,
																								event.localY)));

		//				trace("focusTimeFirstPos.x", focusTimeFirstPos.x, "currentMousePos.x", currentMousePos.x, "focusTimeFirstMousePos.x", focusTimeFirstMousePos.x);
			focusTimeMarker.x = Math.max(focusTimeMarkerMinX,
										 Math.min(focusTimeMarkerMaxX,
												  focusTimeFirstPos.x + currentMousePos.x - focusTimeFirstMousePos.x));

			updateFocusTimeFromMarkerPosition();

			this.dispatchEvent(new FocusTimeEvent());

			event.stopImmediatePropagation();
		}

		private function updateFocusTimeFromMarkerPosition():void
		{
			var focusAxisPosition:Number = (focusTimeMarker.x + focusTimeMarker.width / 2 - mainChartContainer.x - mainChart.x - mainChart.computedGutters.left) /
					(this.mainChart.width - this.mainChart.computedGutters.left - this.mainChart.computedGutters.right);
			updateFocusTimeFromX(focusAxisPosition);
		}

		private function updateFocusTimeFromX(focusAxisPosition:Number):void
		{
			_focusTime = this.mainChart.horizontalAxis.invertTransform(focusAxisPosition) as Number;
		}

		protected function focusTimeGroup_mouseUpHandler(event:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, focusTimeGroup_mouseMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, focusTimeGroup_mouseUpHandler);

			event.stopImmediatePropagation();

			if (horizontalMoveCursorId != 0)
			{
				this.cursorManager.removeCursor(horizontalMoveCursorId);
				horizontalMoveCursorId = 0;
			}
		}

		protected function slider_changeHandler(event:SliderEvent):void
		{
			leftRangeTime = slider.values[0];
			rightRangeTime = slider.values[1];
			updateBox();
			this.dispatchScrollEvent();
		}


		protected function mainChart_resizeHandler(event:ResizeEvent):void
		{
			if (focusTimeMarker)
			{
				updateFocusTime(_focusTime);
			}
		}

		[Bindable]
		public function get initialDurationTime():Number
		{
			return _initialDurationTime;
		}

		public function set initialDurationTime(value:Number):void
		{
			_initialDurationTime = value;
		}

		public static function traceDate(dateValue:Number):String
		{
			var date:Date = new Date(dateValue);
			var formatter:DateTimeFormatter = new DateTimeFormatter("en-US");//, DateTimeStyle.SHORT, DateTimeStyle.SHORT);
			formatter.setDateTimePattern("yyyy-MM-dd'T'HH:mm");
		//	formatter.setDateTimePattern("M/d/yyyy @ h:mma");
		//	formatter.useUTC = true;
			return formatter.formatUTC(date);
		//	return "test!";
		//	return date.toUTCString();
		}

		private function get traceEventsPrefix():String
		{
			return this.id + ".";
		}

		public function get isFocusOnMaximumTime():Boolean
		{
			if (focusTimeMarker)
			{
				if (_traceEvents)
					trace(traceEventsPrefix + "isFocusOnMaximumTime focusTime", traceDate(focusTime), "maximumTime",
						  traceDate(maximumTime),
						  "focusTimeMarker.x", focusTimeMarker.x, "focusTimeMarkerMaxX", focusTimeMarkerMaxX,
						  "rightRangeTime",
						  traceDate(rightRangeTime), "maximumTime", traceDate(maximumTime));
				return focusTime >= maximumTime || (focusTimeMarker.x == focusTimeMarkerMaxX && rightRangeTime >= maximumTime);
			}
			else
			{
				return true;
			}
		}

		private function addAnnotationButton_clickHandler(event:MouseEvent):void
		{
			addAnnotation();
			annDate.selectedDate = null;
			annDescription.text = '';
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);

			if (instance == titleDisplay)
			{
				titleDisplay.text = mainChartTitle;
			}
			else if (instance == mainChart)
			{
				updateMainChart();
				var horizontalAxis:NumericAxis = mainChart.horizontalAxis as DateTimeAxis;
				if (horizontalAxis)
					horizontalAxis.labelFunction = formatDateLabel;

				mainChart.addEventListener(MouseEvent.MOUSE_MOVE, mainChart_mouseMoveHandler);
				mainChart.addEventListener(MouseEvent.MOUSE_OUT, mainChart_mouseOutHandler);
				mainChart.addEventListener(Event.RESIZE, mainChart_resizeHandler);
			}
			else if (instance == mainPrimarySeries)
			{
				mainPrimarySeries.yField = seriesName;
				mainPrimarySeries.addEventListener(FlexEvent.UPDATE_COMPLETE, mainPrimarySeries_updateCompleteHandler)
			}
			else if (instance == mainChartArea)
			{
				mainChartArea.addEventListener(MouseEvent.CLICK, mainChartArea_clickHandler);
				mainChartArea.addEventListener(MouseEvent.MOUSE_DOWN, mainChartArea_mouseDownHandler);
				mainChartArea.addEventListener(MouseEvent.MOUSE_UP, mainChartArea_mouseUpHandler);
			}
			else if (instance == focusTimeMarker)
			{
                focusTimeMarker.visible = showFocusTimeMarker;
				focusTimeMarker.addEventListener(MouseEvent.MOUSE_DOWN, focusTimeGroup_mouseDownHandler);
				_focusTimeMoveEffect.target = focusTimeMarker;
			}
			else if (instance == rangeChart)
			{
				updateRangeChart();
				horizontalAxis = rangeChart.horizontalAxis as DateTimeAxis;
				if (horizontalAxis)
					horizontalAxis.labelFunction = formatDateLabel;
			}
			else if (instance == rangePrimarySeries)
			{
				rangePrimarySeries.yField = seriesName;
			}
			else if (instance == dividedBox)
			{
				dividedBox.addEventListener(DividerEvent.DIVIDER_DRAG, dividedBox_dividerDragHandler);
				dividedBox.addEventListener(DividerEvent.DIVIDER_RELEASE, dividedBox_dividerReleaseHandler);
				dividedBox.addEventListener(Event.RESIZE, dividedBox_resizeHandler);
			}
			else if (instance == middleBox)
			{
				middleBox.addEventListener(MouseEvent.MOUSE_DOWN, middleBox_mouseDownHandler);
				middleBox.addEventListener(MouseEvent.MOUSE_UP, middleBox_mouseUpHandler);
				// TODO: update when rangeDataRatio or minimumDurationTime changes
//				middleBox.minWidth = Math.max(5, Math.min(100, rangeDataRatio * minimumDurationTime));
			}
			else if (instance == mainChartVolume)
			{
				updateMainChartVolume();
				mainChartVolume.addEventListener(MouseEvent.MOUSE_MOVE, mainChartVolume_mouseMoveHandler);
				mainChartVolume.addEventListener(MouseEvent.MOUSE_OUT, mainChartVolume_mouseOutHandler);
			}
			else if (instance == leftScrollButton)
			{
				leftScrollButton.addEventListener(MouseEvent.CLICK, leftScrollButton_clickHandler);
			}
			else if (instance == rightScrollButton)
			{
				rightScrollButton.addEventListener(MouseEvent.CLICK, rightScrollButton_clickHandler);
			}
			else if (instance == slider)
			{
				slider.addEventListener(Event.RESIZE, slider_resizeHandler);
				slider.addEventListener(Event.CHANGE, slider_changeHandler);
				slider.addEventListener(MouseEvent.MOUSE_DOWN, slider_mouseDownHandler);
				slider.addEventListener(MouseEvent.MOUSE_UP, slider_mouseUpHandler);
				updateSliderMinMax();
			}
			else if (instance == showAnnotationsButton)
			{
				showAnnotationsButton.addEventListener(MouseEvent.CLICK, showAnnotationsButton_clickHandler);
			}
			else if (instance == addAnnotationButton)
			{
				addAnnotationButton.addEventListener(MouseEvent.CLICK, addAnnotationButton_clickHandler);
			}
			else if (instance == rangeOneDayButton)
			{
				rangeOneDayButton.addEventListener(MouseEvent.CLICK, rangeOneDayButton_clickHandler);
			}
			else if (instance == rangeOneWeekButton)
			{
				rangeOneWeekButton.addEventListener(MouseEvent.CLICK, rangeOneWeekButton_clickHandler);
			}
			else if (instance == rangeOneMonthButton)
			{
				rangeOneMonthButton.addEventListener(MouseEvent.CLICK, rangeOneMonthButton_clickHandler);
			}
			else if (instance == rangeOneYearButton)
			{
				rangeOneYearButton.addEventListener(MouseEvent.CLICK, rangeOneYearButton_clickHandler);
			}
			else if (instance == rangeMaxButton)
			{
				rangeMaxButton.addEventListener(MouseEvent.CLICK, rangeMaxButton_clickHandler);
			}
			else if (instance == rangeTodayButton)
			{
				rangeTodayButton.addEventListener(MouseEvent.CLICK, rangeTodayButton_clickHandler);
			}
			else if (instance == annotationForm)
			{
				annotationForm.dataProvider = annotationItems;
				// TODO: add event listeners for the annotation buttons for highlighting the correct annotation
				// click="{outerDocument.hightlightAnnotation([data.annID, data.date]); data.selected = true;}"
			}

			// TODO: annDate.selectableRange="{{rangeStart: dateParse(rangeData.getItemAt(0).date), rangeEnd:dateParse(rangeData.getItemAt(rangeData.length - 1).date)}}"
		}

		private function updateSliderMinMax():void
		{
			if (slider)
			{
				slider.minimum = _minimumTime;
				slider.maximum = _maximumTime;
			}
		}

		private function rangeOneDayButton_clickHandler(event:MouseEvent):void
		{
			animateRangeDuration(DAYS_TO_MILLISECONDS);
		}

		private function rangeOneWeekButton_clickHandler(event:MouseEvent):void
		{
			animateRangeDuration(7 * DAYS_TO_MILLISECONDS);
		}

		private function animateRangeDuration(duration:Number):void
		{
			// Maintain the current focusTime
			var currentDuration:Number = rightRangeTime - leftRangeTime;

			var leftToFocus:Number = focusTime - leftRangeTime;
			var focusToRight:Number = rightRangeTime - focusTime;

			leftToFocus *= duration / currentDuration;
			focusToRight *= duration / currentDuration;

			animateRangeTimes(focusTime - leftToFocus, focusTime + focusToRight);
		}

		private function rangeOneMonthButton_clickHandler(event:MouseEvent):void
		{
			animateRangeDuration(31 * DAYS_TO_MILLISECONDS);
		}

		private function rangeOneYearButton_clickHandler(event:MouseEvent):void
		{
			animateRangeDuration(365 * DAYS_TO_MILLISECONDS);
		}

		private function rangeMaxButton_clickHandler(event:MouseEvent):void
		{
			animateRangeTimes(_minimumTime, _maximumTime);
		}

		private function slider_mouseDownHandler(event:MouseEvent):void
		{
			hideAnnotations();
		}

		private function slider_mouseUpHandler(event:MouseEvent):void
		{
			showAnnotations = true; refreshAnnotations();
		}

		private function leftScrollButton_clickHandler(event:MouseEvent):void
		{
			clickUpdate(-20);
		}

		private function rightScrollButton_clickHandler(event:MouseEvent):void
		{
			clickUpdate(20);
		}

		private function mainChartArea_mouseUpHandler(event:MouseEvent):void
		{
			showAnnotations = true;
			refreshAnnotations();
		}

		private function mainChartArea_mouseDownHandler(event:MouseEvent):void
		{
			setMouseDown(mainChart);
		}

		private function mainPrimarySeries_updateCompleteHandler(event:FlexEvent):void
		{
			seriesComplete(event);
		}

		private function mainChart_mouseOutHandler(event:MouseEvent):void
		{
			chartMouseOut();
		}

		private function mainChart_mouseMoveHandler(event:MouseEvent):void
		{
			getChartDataPoint();
		}

		private function middleBox_mouseUpHandler(event:MouseEvent):void
		{
			showAnnotations = true;
			refreshAnnotations();
		}

		private function middleBox_mouseDownHandler(event:MouseEvent):void
		{
			setMouseDown(rangeChart);
		}

		private function dividedBox_dividerDragHandler(event:DividerEvent):void
		{
			setDividerDragDate();
		}

		private function dividedBox_dividerReleaseHandler(event:DividerEvent):void
		{
			updateIndicatorValuesWithEffect();
		}

		private function mainChartVolume_mouseOutHandler(event:MouseEvent):void
		{
			chartMouseOut();
		}

		private function mainChartVolume_mouseMoveHandler(event:MouseEvent):void
		{
			getChartDataPoint();
		}

		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);

			if (instance == addAnnotationButton)
			{
				addAnnotationButton.removeEventListener(MouseEvent.CLICK, addAnnotationButton_clickHandler);
			}
			
			else if (instance == mainChart)
			{
				mainChart.removeEventListener(MouseEvent.MOUSE_MOVE, mainChart_mouseMoveHandler);
				mainChart.removeEventListener(MouseEvent.MOUSE_OUT, mainChart_mouseOutHandler);
				mainChart.removeEventListener(Event.RESIZE, mainChart_resizeHandler);
			}
			else if (instance == mainPrimarySeries)
			{
				mainPrimarySeries.removeEventListener(FlexEvent.UPDATE_COMPLETE, mainPrimarySeries_updateCompleteHandler)
			}
			else if (instance == mainChartArea)
			{
				mainChartArea.removeEventListener(MouseEvent.CLICK, mainChartArea_clickHandler);
//				mainChartArea.removeEventListener(MouseEvent.MOUSE_DOWN, mainChartArea_mouseDownHandler);
//				mainChartArea.removeEventListener(MouseEvent.MOUSE_UP, mainChartArea_mouseUpHandler);
			}
			else if (instance == focusTimeMarker)
			{
				focusTimeMarker.removeEventListener(MouseEvent.MOUSE_DOWN, focusTimeGroup_mouseDownHandler);
				_focusTimeMoveEffect.target = null;
			}
			else if (instance == dividedBox)
			{
				dividedBox.removeEventListener(DividerEvent.DIVIDER_DRAG, dividedBox_dividerDragHandler);
				dividedBox.removeEventListener(DividerEvent.DIVIDER_RELEASE, dividedBox_dividerReleaseHandler);
				dividedBox.removeEventListener(Event.RESIZE, dividedBox_resizeHandler);
			}
			else if (instance == middleBox)
			{
				middleBox.removeEventListener(MouseEvent.MOUSE_DOWN, middleBox_mouseDownHandler);
				middleBox.removeEventListener(MouseEvent.MOUSE_UP, middleBox_mouseUpHandler);
			}
			else if (instance == mainChartVolume)
			{
				updateMainChartVolume();
				mainChartVolume.removeEventListener(MouseEvent.MOUSE_MOVE, mainChartVolume_mouseMoveHandler);
				mainChartVolume.removeEventListener(MouseEvent.MOUSE_OUT, mainChartVolume_mouseOutHandler);
			}
			else if (instance == leftScrollButton)
			{
				leftScrollButton.removeEventListener(MouseEvent.CLICK, leftScrollButton_clickHandler);
			}
			else if (instance == rightScrollButton)
			{
				rightScrollButton.removeEventListener(MouseEvent.CLICK, rightScrollButton_clickHandler);
			}
			else if (instance == slider)
			{
				slider.removeEventListener(Event.RESIZE, slider_resizeHandler);
				slider.removeEventListener(Event.CHANGE, slider_changeHandler);
				slider.removeEventListener(MouseEvent.MOUSE_DOWN, slider_mouseDownHandler);
				slider.removeEventListener(MouseEvent.MOUSE_UP, slider_mouseUpHandler);
			}
			else if (instance == showAnnotationsButton)
			{
				showAnnotationsButton.removeEventListener(MouseEvent.CLICK, showAnnotationsButton_clickHandler);
			}
			else if (instance == addAnnotationButton)
			{
				addAnnotationButton.removeEventListener(MouseEvent.CLICK, addAnnotationButton_clickHandler);
			}
			else if (instance == rangeOneDayButton)
			{
				rangeOneDayButton.removeEventListener(MouseEvent.CLICK, rangeOneDayButton_clickHandler);
			}
			else if (instance == rangeOneWeekButton)
			{
				rangeOneWeekButton.removeEventListener(MouseEvent.CLICK, rangeOneWeekButton_clickHandler);
			}
			else if (instance == rangeOneMonthButton)
			{
				rangeOneMonthButton.removeEventListener(MouseEvent.CLICK, rangeOneMonthButton_clickHandler);
			}
			else if (instance == rangeOneYearButton)
			{
				rangeOneYearButton.removeEventListener(MouseEvent.CLICK, rangeOneYearButton_clickHandler);
			}
			else if (instance == rangeMaxButton)
			{
				rangeMaxButton.removeEventListener(MouseEvent.CLICK, rangeMaxButton_clickHandler);
			}
			else if (instance == rangeTodayButton)
			{
				rangeTodayButton.removeEventListener(MouseEvent.CLICK, rangeTodayButton_clickHandler);
			}
		}

		override public function setStyle(styleProp:String, newValue:*):void
		{
			super.setStyle(styleProp, newValue);

			if (styleProp == "rangeChartVisible")
			{
				updateRangeChart();
			}
			else if (styleProp == "volumeVisible")
			{
				updateMainChartVolume();
			}

		}

		private function updateMainChart():void
		{
			if (mainChart)
				mainChart.dataProvider = mainData;
		}

		private function updateRangeChart():void
		{
			var rangeChartVisible:Boolean = getStyle("rangeChartVisible");
			if (rangeChart)
				rangeChart.dataProvider = rangeChartVisible ? rangeData : null;
		}

		private function updateMainChartVolume():void
		{
			var volumeVisible:Boolean = getStyle("volumeVisible");
			if (mainChartVolume)
				mainChartVolume.dataProvider = volumeVisible ? mainData : null;
		}

		[Bindable]
		public function get mainChartTitle():String
		{
			return _mainChartTitle;
		}

		public function set mainChartTitle(value:String):void
		{
			_mainChartTitle = value;
			if (titleDisplay)
				titleDisplay.text = value;
		}

		public function removeDefaultSeries():void
		{
			if (mainChart)
				mainChart.series = new Array();

			if (rangeChart)
				rangeChart.series = new Array();
		}

		private function mainChartArea_clickHandler(event:MouseEvent):void
		{
			if (!_rangeTimeAnimate.isPlaying)
				selectChartDataPoint();
		}

		public function get minimumDataTime():Number
		{
			return _minimumDataTime;
		}

		public function get maximumDataTime():Number
		{
			return _maximumDataTime;
		}

		protected function get pendingUpdateData():Boolean
		{
			return _pendingUpdateData;
		}

		protected function set pendingUpdateData(value:Boolean):void
		{
			_pendingUpdateData = value;
		}
	}
}
