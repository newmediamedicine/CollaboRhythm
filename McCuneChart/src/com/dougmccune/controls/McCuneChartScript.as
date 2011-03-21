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

import annotations.EventAnnotation;

import com.dougmccune.events.FocusTimeEvent;

import flash.events.Event;
import flash.filters.BitmapFilterQuality;
import flash.sampler.NewObjectSample;
import flash.utils.flash_proxy;

import mx.charts.ChartItem;
import mx.charts.HitData;
import mx.charts.chartClasses.Series;
import mx.charts.series.items.AreaSeriesItem;
import mx.charts.series.items.LineSeriesItem;
import mx.charts.series.items.PlotSeriesItem;
import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Alert;
import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;
import mx.effects.Move;
import mx.effects.easing.Cubic;
import mx.events.DividerEvent;
import mx.events.EffectEvent;
import mx.events.ResizeEvent;
import mx.events.ScrollEvent;
import mx.events.SliderEvent;
import mx.events.TweenEvent;
import mx.graphics.SolidColor;
import mx.graphics.Stroke;
import mx.managers.CursorManagerPriority;
import mx.rpc.events.AbstractEvent;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.UIDUtil;

import skins.GradientBox;

import spark.components.IItemRenderer;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.effects.easing.Power;

import vo.AnnotationVO;

/* STEP 1 */
//			[Bindable] private var MAIN_CHART_HEIGHT:Number = 350;
[Bindable]
private var VOLUME_CHART_HEIGHT:Number = 50;
[Bindable]
private var RANGE_CHART_HEIGHT:Number = 80;
private const RANGE_CHART_OVERLAP:Number = 1;
private const SLIDER_SCROLL_BUTTON_WIDTH:Number = 16;

//			[Bindable] private var MAIN_CHART_HEIGHT:Number = 600;
//the sliced data to appear in the upper area chart, and column volume chart
[Bindable]
protected var mainData:ArrayCollection = new ArrayCollection();
//the full dataset of stock information
[Bindable]
protected var rangeData:ArrayCollection = new ArrayCollection();
[Bindable]
public var mainChartTitle:String;

/* STEP 3 */
//static positions of left and right indicators set in setMouseDown and used in moveChart to calulate new positions
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
private var updateBoxFromSlider:Boolean = true;
//a flag to allow the updateComplete event on AreaSeries to run only once on startup
private var allowUpdateComplete:Boolean = true;
//skins used for scroll button arrows and divider boundar grab points
[Embed(source="/assets/divider.png")]
[Bindable]
public var dividerClass:Class;
[Embed(source="/assets/blank.png")]
[Bindable]
public var blankDividerClass:Class;
[Embed(source="/assets/left_scroll.png")]
[Bindable]
public var leftScroll:Class;
[Embed(source="/assets/right_scroll.png")]
[Bindable]
public var rightScroll:Class;
/* STEP 4 */
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

public static const DAYS_TO_MILLISECONDS:int = 24 * 60 * 60 * 1000;
private const minimumDurationTime:int = 2 * DAYS_TO_MILLISECONDS;

private var _leftRangeTime:Number;
private var _rightRangeTime:Number;
private var _focusTime:Number;
private const defaultInitialDurationTime:Number = 30 * DAYS_TO_MILLISECONDS;
[Bindable]
protected var t0:Number;
[Bindable]
protected var t1:Number;
protected var mainChartDurationTime:Number;
// the ratio between the width of the main chart control and the duration of it's dataset
protected var mainDataRatio:Number;

[Bindable]
public var headerVisible:Boolean = false;
[Bindable]
public var footerVisible:Boolean = true;
[Bindable]
public var sliderVisible:Boolean = true;
[Bindable]
public var topBorderVisible:Boolean = true;
[Bindable]
public var volumeVisible:Boolean = false;
[Bindable]
public var rangeChartVisible:Boolean = true;
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

[Bindable]
private var gapMainRange:Number = 15;

[Bindable]
public function get leftRangeTime():Number
{
	return _leftRangeTime;
}

public function set leftRangeTime(value:Number):void
{
	_leftRangeTime = value;
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

	focusTimeMarker.x = focusAxisPosition * (this.mainChart.width - this.mainChart.computedGutters.left - this.mainChart.computedGutters.right) -
			(focusTimeMarker.width / 2 - mainChartContainer.x - mainChart.x - mainChart.computedGutters.left);
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

		if (_showFps)
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		else
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
}

protected function showBtn_clickHandler(event:MouseEvent):void
{
	if (showBtn.selected)
		this.currentState = "showAnnotationControls";
	else
		this.currentState = "hideAnnotationControls";
}

private function getLeftBoxWidth(leftBoxWidth:Number, middleBoxX:Number, rightBoxX:Number):Number
{
	return groupBetweenMainRange.width - rightBox.width - middleBox.width;
}

/* STEP 1 */
/**
 * Application creationComplete
 */
private function createComplete():void
{
//				stockInfo.send();
	if (_showFps)
		this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
}

private var _data:ArrayCollection;

public function get data():ArrayCollection
{
	return _data;
}

private var _initialDurationTime:Number = defaultInitialDurationTime;

public function set data(value:ArrayCollection):void
{
	if (value)
	{
		allowUpdateComplete = true;
		_data = value;

		rangeData = _data;

		try
		{
			mainData = new ArrayCollection(_data.source);
		} catch(e:Error)
		{
			trace("Error setting mainData: " + e.message);
		}

		//setting default range values for loading
		var i0:Number = 0;
		try
		{
			var i1:Number = rangeData.source.length - 1;
		} catch(e:Error)
		{
			trace("Error setting i1: " + e.message);
		}
		t0 = dateParse(rangeData.source[i0].date).time;
		t1 = dateParse(rangeData.source[i1].date).time;

		try
		{
			rightRangeTime = t1;
		} catch(e:Error)
		{
			trace("Error setting rightRangeTime: " + e.message);
		}

		try
		{
			leftRangeTime = Math.max(t0, t1 - initialDurationTime);
		} catch(e:Error)
		{
			trace("Error setting leftRangeTime: " + e.message);
		}

//				calculateIndicatorConversionRatio();

		calculateRangeDataRatio();
	}
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
	rangeDataRatio = slider.width / (slider.maximum - slider.minimum);
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
public function seriesComplete():void
{
	if (mainData.length > 0 && allowUpdateComplete)
	{
		allowUpdateComplete = false;
		updateBoxFromSlider = true;
		rightRangeTime = t1;
		leftRangeTime = Math.max(t0, t1 - defaultInitialDurationTime);
		updateBox();
		callLater(refreshAnnotations);
		this.visible = true;
//					loadSampleAnnotations();

		// TODO: Figure out how to remove this. This is a hack to get the axis labels to render correctly when the data is initially loaded; otherwise, we see "1970" at the far left edge of the axis
		rangeChart.horizontalAxis.dataChanged();

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

private var focustTimePositionLocked:Boolean = true;

private function updateFocusTimeBox():void
{
//				focusTimeMarker.x = mainChartContainer.x + mainChart.x + mainChart.width - (focusTimeMarker.width / 2);

	if (focustTimePositionLocked)
		updateFocusTimeValueFromPosition();
	else
		updateFocusTime(_focusTime);
}

private function sliceMainData():void
{
	var i0:int = 0;
	var i1:int = rangeData.source.length - 1;

	for (var i:int = 0; i < rangeData.source.length; i++)
	{
		var dataItem:Object = rangeData.source[i];
		// use the first data point that is just before crossing the left edge
		if ((dataItem["date"] as Date).time > leftRangeTime)
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
		if ((dataItem["date"] as Date).time > rightRangeTime)
		{
			i1 = i + 1;
			break;
		}
	}

//				trace("slicing in", this.id, i0, i1);
	mainData.source = rangeData.source.slice(i0, i1);
//				mainData.source = rangeData.source.slice(0, rangeData.source.length);
//				mainChart.validateNow();
}

private function updateMainDataSource():void
{
//				mainData.source = rangeData.source.slice(leftIndicator.x, rightIndicator.x);
//				var i0:int = Math.max(0, Math.floor(leftIndicator.x) - 10);
//				var i1:int = Math.min(rangeData.source.length, Math.ceil(rightIndicator.x) + 10);

//				mainData.source = rangeData.source.slice(i0, i1);
//				mainData.source = rangeData.source;
//				mainData = new ArrayCollection(_data.source);

//				sliceMainData();

	var minimum:Number = leftRangeTime;
	var maximum:Number = rightRangeTime;

	mainChartDurationTime = maximum - minimum;
	var daysApart:Number = (maximum - minimum) / DAYS_TO_MILLISECONDS;

	mainDataRatio = mainChartArea.width / mainChartDurationTime;

	//trace("updateMainDataSource", "leftIndicator.x", leftIndicator.x.toFixed(2), "rightIndicator.x", rightIndicator.x.toFixed(2), "i0", i0, "i1", i1, "minimum", minimum.toFixed(0), "maximum", maximum.toFixed(0), "daysApart", daysApart.toFixed(2));
//				if (traceRangeTimes)
//					trace("updateMainDataSource", "leftRangeTime", leftRangeTime.toFixed(2), "rightRangeTime", rightRangeTime.toFixed(2), "minimum", minimum.toFixed(0), "maximum", maximum.toFixed(0), "daysApart", daysApart.toFixed(2));

	(this.mainChart.horizontalAxis as DateTimeAxis).minimum = new Date(minimum);
	(this.mainChart.horizontalAxis as DateTimeAxis).maximum = new Date(maximum);
	if (volumeVisible)
	{
		(this.mainChartVolume.horizontalAxis as DateTimeAxis).minimum = (this.mainChart.horizontalAxis as DateTimeAxis).minimum;
		(this.mainChartVolume.horizontalAxis as DateTimeAxis).maximum = (this.mainChart.horizontalAxis as DateTimeAxis).maximum;
	}

	if (_performanceCounter != null)
		_performanceCounter["updateMainDataSource"] += 1;
}

private function updateFps():void
{
	if (_showFps)
	{
		var now:Date = new Date();
		if (_lastUpdate != null)
		{
			var totalDiff:Number = now.time - _lastUpdatesStack[0].time;
			var averageFps:Number = 1000 * _lastUpdatesStack.length / totalDiff;

			var diff:Number = now.time - _lastUpdate.time;
			var fps:Number = 1000 / diff;
			fpsLabel.text =
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
	if (updateBoxFromSlider)
	{
		//setting the box width value to the slider value times the ratio (to decrease
		//it to the equivalent width percentage
		//eg. full divided box width = 500, rangeDataRatio = 1/5 would equal 100 for the
		//proper left box width equal to range index value
		if (leftBox)
			leftBox.width = sliderValueToRangeChartPos(leftRangeTime);
		if (rightBox)
			rightBox.width = dividedBox.width - sliderValueToRangeChartPos(rightRangeTime);
//					middleBox.width = NaN;
		if (!isNaN(slider.values[0]))
			leftRangeTime = slider.values[0];
		if (!isNaN(slider.values[1]))
			rightRangeTime = slider.values[1];
		updateMainData();
//					(groupBetweenMainRange.getElementAt(1) as Line).validateNow();
	}
}

private function sliderValueToRangeChartPos(value:Number):Number
{
	return (value - slider.minimum) * rangeDataRatio;
}

private function rangeChartPosToSliderValue(value:Number):Number
{
	return (value / rangeDataRatio) + slider.minimum;
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
	slider.dispatchEvent(new SliderEvent('change'));
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

	hideAnnotations();
	moveSlider(leftIndicator, rangeChartPosToSliderValue(leftBox.width), false);
	moveSlider(rightIndicator, rangeChartPosToSliderValue(dividedBox.width - rightBox.width), false);
}

/**
 * Called from the thumbRelease on the slider instance, as well as creationComplete
 * to set the initial range values.
 * Updates the left and right indicator x values without the move effect.
 */
private function updateIndicatorsQuietly():void
{
	//these two values are mapped 1:1 as the slider values and indicator values equal the rangeData length exactly
	leftRangeTime = slider.values[0];
	rightRangeTime = slider.values[1];
}

/**
 * Moves the left and right indicator x values with an easing transition applied.  update
 * dictates whether this should update the divided box range measurements (false if we're calling this
 * from the divided box release) callbackFunc can be passed to get called when the move is finished.
 */
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

//				var moveIndicator:Move = new Move();
//				moveIndicator.end();
//				moveIndicator.easingFunction = Cubic.easeOut;
//				moveIndicator.duration = 750;
//				moveIndicator.target = target;
//				moveIndicator.xTo = xTo;
//				moveIndicator.addEventListener(EffectEvent.EFFECT_START, function():void {updateBoxFromSlider = update});
//				moveIndicator.addEventListener(TweenEvent.TWEEN_UPDATE, function():void { updateMainDataSource()});
//				moveIndicator.addEventListener(EffectEvent.EFFECT_END, function():void {updateBoxFromSlider = true;
//					showAnnotations = true;
//					callLater(refreshAnnotations);
//					if(callbackFunc != null) callbackFunc.call(this, rest)});
//				moveIndicator.play();
}

/**
 * Called from range chart or main chart and determines the position of the mouse as well as left
 * and right indicators (for static comparison when moving) and adds systemManager events
 * to capture mouse movement.  The values set here are used in the moveChart function to calculate
 * new position differences with start position
 */
private function setMouseDown(theChart:CartesianChart):void
{
	//don't capture for drag if we're viewing the entire range of data
	if (!(leftRangeTime == t0 && rightRangeTime == t1))
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
		rightRangeTime = Math.min(t1, leftRangeTime + minimumDurationTime);
		leftRangeTime = Math.max(t0, rightRangeTime - minimumDurationTime);
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
		var rangeChartPixelsToTime:Number = (t1 - t0) / rangeChart.width;
		targetLeftRangeTime = staticLeftBoundary - (mouseXRef - this.mouseX) * rangeChartPixelsToTime;
//					targetRightRangeTime = staticRightBoundary - (mouseXRef - this.mouseX) * rangeChartPixelsToTime;
	}

	var leftToRight:Number = rightRangeTime - leftRangeTime;

	// constrain drag to be within min/max values
	leftRangeTime = Math.max(t0, Math.min(t1 - leftToRight, targetLeftRangeTime));
//				var constrainLeftDelta:Number = leftRangeTime - targetLeftRangeTime;
	rightRangeTime = leftRangeTime + leftToRight;

	updateBoxFromSlider = true;
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
	if (updateBoxFromSlider)
	{
//					var chartPoint:Object = getChartCoordinates(new Point(mainChart.mouseX, mainChart.mouseY), mainChart);
//					var formattedDate:String = fullDateFormat.format(new Date(chartPoint.x));
//					trace("getChartDataPoint", formattedDate);
//
//					if (mainChart.series[0].numChildren - 1 == mainData.length)
//					{
//						var result:int = findDataPoint(mainData, chartPoint.x);
//						if (result > -1)
//						{
//							//						var dataItem:Object = mainData.getItemAt(result);
//							mainChart.series[0].getChildAt(result). (true);
//							//							mainChartVolume.series[0].getChildAt(result).showRenderer(true);
//						}
//					}

//					selectChartDataPoint();

//					for(var i:int = 0; i < mainData.length; i++)
//					{
//						var dataItem:Object = mainData.getItemAt(i);
//						if(dataItem.date == formattedDate)
//						{
//							_selectedDate = labelSummaryDateFormatter.format(dateParse(dataItem.date));
//							_selectedClose = 'Price: ' + dollarFormatter.format(Number(dataItem.close));
//							_selectedVolume = 'Vol: ' + volumeFormatter.format(Number(dataItem.volume));
//							mainChart.series[0].getChildAt(i + 1).showRenderer(true);
//							mainChartVolume.series[0].getChildAt(i + 1).showRenderer(true);
//						}
//						else
//						{
//							mainChart.series[0].getChildAt(i + 1).showRenderer(false);
//							mainChartVolume.series[0].getChildAt(i + 1).showRenderer(false);
//						}
//					}
//					for(var i:int = 0; i < mainChart.series[0].numChildren; i++)
//					{
//						mainChart.series[0].getChildAt(i).showRenderer(true);
//						mainChartVolume.series[0].getChildAt(i).showRenderer(true);
//					}

	}
}

private function selectChartDataPoint():void
{
	for (var s:int = 0; s < mainChart.series.length; s++)
	{
		var series:Series = mainChart.series[s] as Series;

		var points:Array = series.findDataPoints(series.mouseX, series.mouseY, 10);
		if (points.length > 0)
		{
//						trace("getChartDataPoint", points.length, "points", points[0]);
			var hitData:HitData = points[0] as HitData;
			if (hitData != null && highlightedItem != hitData.chartItem)
			{
				highlightChartItem(hitData.chartItem);
			}
		}
	}
}


private function highlightChartItem(chartItem:ChartItem):void
{
	highlightChartItemGroup.visible = true;

//				var itemRenderer:IFlexDisplayObject = hitData.chartItem.itemRenderer;
//				if (itemRenderer != null)
//				{
//					itemRenderer.visible = true;
//					itemRenderer.scaleX = 2;
//					itemRenderer.scaleY = 2;
//				}
	highlightChartItemEffect.stop();
	highlightedItem = chartItem;

	var chartItemX:Number;
	var chartItemY:Number;
	if (chartItem.hasOwnProperty("x"))
		chartItemX = chartItem["x"];
	else
		chartItemX = chartItem.itemRenderer.x + chartItem.itemRenderer.width / 2;

	if (chartItem.hasOwnProperty("y"))
		chartItemY = chartItem["y"];
	else
		chartItemY = chartItem.itemRenderer.y + chartItem.itemRenderer.width / 2;

//				plotSeriesItem:PlotSeriesItem = chartItem as PlotSeriesItem;


//				highlightChartItemBullsEye.x = highlightedItem.itemRenderer.x - highlightChartItemBullsEye.width / 2;
//				highlightChartItemBullsEye.y = highlightedItem.itemRenderer.y - highlightChartItemBullsEye.height / 2;
	highlightChartItemBullsEye.horizontalCenter = chartItemX - highlightedItem.element.width / 2;
	highlightChartItemBullsEye.verticalCenter = chartItemY - highlightedItem.element.height / 2;
//				highlightChartItemBullsEye.horizontalCenter = - highlightedItem.element.width / 2;
//				highlightChartItemBullsEye.verticalCenter = - highlightedItem.element.height / 2;
	highlightChartItemScopeLeft.verticalCenter = chartItemY - highlightedItem.element.height / 2;
	highlightChartItemEffectScopeLeftMove.xFrom = 0;
	highlightChartItemEffectScopeLeftMove.xTo = chartItemX - highlightChartItemScopeLeft.width;

//				highlightChartItemEffect.target = chartItem;
	highlightChartItemEffect.play();

//				chartItem.element.x
//				chartItem.itemRenderer.x
}

private function hideDataPointHighlight():void
{
	highlightChartItemGroup.visible = false;
}

public function findPreviousDataPoint(dateValue:Number):Object
{
	var dataCollection:ArrayCollection = rangeData;

	if (dataCollection != null)
	{
		for (var i:int = dataCollection.length - 1; i >= 0; i--)
		{
			var dataItem:Object = dataCollection.getItemAt(i);
			if (dataItem.date.time <= dateValue)
			{
				return dataItem;
			}
		}
	}

	return null;
}

private function findDataPoint(dataCollection:ArrayCollection, dateValue:Number):int
{
	const delta:Number = 1 * DAYS_TO_MILLISECONDS;
	for (var i:int = 0; i < dataCollection.length; i++)
	{
		var dataItem:Object = dataCollection.getItemAt(i);
		if (Math.abs(dataItem.date.time - dateValue) < delta)
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
				if (volumeVisible)
					mainChartVolume.series[0].getChildAt(i).showRenderer(false);
			}
			catch(e:Error)
			{
			}
			;
		}
		_selectedDate = labelSummaryDateFormatter.format(dateParse(mainData.getItemAt(0).date)) + ' - ' +
				labelSummaryDateFormatter.format(dateParse(mainData.getItemAt(mainData.length - 1).date));
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
	var tmpLeftRangeTime:Number = rangeChartPosToSliderValue(leftBox.width);
	var tmpRightRangeTime:Number = rangeChartPosToSliderValue(dividedBox.width - rightBox.width);
//				var tmpLeftIndex:int = leftBox.width  / rangeDataRatio;
//				var tmpRightIndex:int = ((dividedBox.width - rightBox.width) / rangeDataRatio) - 1;
	if (tmpLeftRangeTime >= t0 && tmpRightRangeTime <= t1)
	{
		_selectedDate = labelSummaryDateFormatter.format(new Date(tmpLeftRangeTime)) + ' - ' +
				labelSummaryDateFormatter.format(new Date(tmpLeftRangeTime));
//					_selectedClose = percentageFormatter.format((Number(rangeData.getItemAt(tmpRightIndex).close) /
//						Number(rangeData.getItemAt(tmpLeftIndex).close) - 1) * 100) + '%';
		_selectedClose = '(not implemented)';
		_selectedVolume = '';
	}
}

/*Step 5 */
/**
 * Prevents rollover or selection effects in the list control
 */
private function myEasingFunction(t:Number, b:Number, c:Number, d:Number):Number
{
	return 0;
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
		moveSlider(leftIndicator, dateParse(targetDate).time - GROW_DURATION_PADDING / mainDataRatio, true,
				   hightlightAnnotation, targetUID, targetDate);
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
		moveSlider(rightIndicator, dateParse(targetDate).time + GROW_DURATION_PADDING / mainDataRatio, true,
				   hightlightAnnotation, targetUID, targetDate);
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

protected function todayLinkButton_clickHandler(event:MouseEvent):void
{
	showAnnotations = false;

	var delta:Number = rightRangeTime - leftRangeTime;

	// TODO: use ICurrentDateSource
//				var today:Date = new Date();
	var todayTime:Number = today.time;

	// don't try to go beyond the maximum value for which there is data
	var rangeChartMaximum:Number = maximumTime;
	todayTime = Math.min(todayTime, rangeChartMaximum);

	moveSlider(leftIndicator, todayTime - delta, true);
	moveSlider(rightIndicator, todayTime, true);
}

public function get today():Date
{
	if (_today != null)
		return _today
	else
		return new Date();
}

public function set today(value:Date):void
{
	_today = value;
}

public function get maximumDate():Date
{
	return (this.rangeChart.horizontalAxis as DateTimeAxis).maximum;
}

public function get maximumTime():Number
{
	return (this.rangeChart.horizontalAxis as DateTimeAxis).maximum.time;
}

public function get minimumDate():Date
{
	return (this.rangeChart.horizontalAxis as DateTimeAxis).minimum;
}

public function get minimumTime():Number
{
	return (this.rangeChart.horizontalAxis as DateTimeAxis).minimum.time;
}

public function set minimumTime(value:Number):void
{
	(this.rangeChart.horizontalAxis as DateTimeAxis).minimum.time = value;
}

public function set maximumTime(value:Number):void
{
	(this.rangeChart.horizontalAxis as DateTimeAxis).maximum.time = value;
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

protected function focusTimeGroup_mouseMoveHandler(event:MouseEvent):void
{
	var currentMousePos:Point = this.globalToLocal(event.target.localToGlobal(new Point(event.localX,
																						event.localY)));

//				trace("focusTimeFirstPos.x", focusTimeFirstPos.x, "currentMousePos.x", currentMousePos.x, "focusTimeFirstMousePos.x", focusTimeFirstMousePos.x);
	var mainHorizontalAxisLeft:Number = mainChartContainer.x + mainChart.x + mainChart.computedGutters.left;
	var mainHorizontalAxisRight:Number = mainChartContainer.x + mainChart.x + mainChart.width - mainChart.computedGutters.right;
	focusTimeMarker.x = Math.max(mainHorizontalAxisLeft - focusTimeMarker.width / 2,
								 Math.min(mainHorizontalAxisRight - focusTimeMarker.width / 2,
										  focusTimeFirstPos.x + currentMousePos.x - focusTimeFirstMousePos.x));

	updateFocusTimeValueFromPosition();

	this.dispatchEvent(new FocusTimeEvent());

	event.stopImmediatePropagation();
}

private function updateFocusTimeValueFromPosition():void
{
	var focusAxisPosition:Number = (focusTimeMarker.x + focusTimeMarker.width / 2 - mainChartContainer.x - mainChart.x - mainChart.computedGutters.left) /
			(this.mainChart.width - this.mainChart.computedGutters.left - this.mainChart.computedGutters.right);
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
