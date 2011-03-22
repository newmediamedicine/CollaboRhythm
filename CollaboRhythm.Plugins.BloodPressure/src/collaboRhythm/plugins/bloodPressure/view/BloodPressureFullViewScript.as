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
		import com.dougmccune.controls.TouchScrollingMcCuneChart;

		import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
		import collaboRhythm.shared.model.StringUtils;
		import collaboRhythm.view.scroll.TouchScrollerEvent;

		import com.dougmccune.controls.McCuneChart;
		import com.dougmccune.events.FocusTimeEvent;

		import flash.events.MouseEvent;
		import flash.profiler.showRedrawRegions;

import flash.text.TextFormat;

import mx.charts.ChartItem;
		import mx.charts.LinearAxis;
		import mx.charts.renderers.TriangleItemRenderer;
		import mx.collections.ArrayCollection;
		import mx.containers.Canvas;
		import mx.controls.Alert;
		import mx.controls.LinkButton;
		import mx.effects.Sequence;
		import mx.events.EffectEvent;
		import mx.events.FlexEvent;
		import mx.events.PropertyChangeEvent;
		import mx.events.ResizeEvent;
		import mx.events.ScrollEvent;
		import mx.events.TweenEvent;
		import mx.graphics.SolidColor;
		import mx.graphics.SolidColorStroke;
		import mx.graphics.Stroke;
		import mx.logging.ILogger;
		import mx.logging.Log;
		import mx.rpc.events.FaultEvent;
		import mx.rpc.events.ResultEvent;
		import mx.utils.StringUtil;

		import qs.charts.dataShapes.Edge;

		import spark.effects.Animate;
		import spark.effects.animation.MotionPath;
		import spark.effects.animation.SimpleMotionPath;
		import spark.effects.easing.Linear;
		import spark.effects.easing.Power;

		private var _textFormat:TextFormat = new TextFormat("Myriad Pro, Verdana, Helvetica, Arial", 16, 0, true);

		private var _model:BloodPressureModel;
		private var _traceEventHandlers:Boolean = true;
		private var _showFocusTimeMarker:Boolean = true;
		private var _scrollEnabled:Boolean = true;

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
		}

		public function get rangeChartVisible():Boolean
		{
			return bloodPressureChart.rangeChartVisible;
		}

		public function set rangeChartVisible(value:Boolean):void
		{
			for each (var chart:McCuneChart in getAllCharts())
			{
				chart.rangeChartVisible = value;
			}
		}

		[Bindable]
		public function get model():BloodPressureModel
		{
			return _model;
		}

		public function set model(value:BloodPressureModel):void
		{
			_model = value;
			refresh();

			_model.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler, false, 0, true);
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "showAdherence")
				setSingleChartMode(null, false);
		}

		public function refresh():void
		{
			setSingleChartMode(null, false);
		}

		private function adherenceSeriesFilter(cache:Array):Array
		{
			var filteredCache:Array = new Array();

			for each (var element:ChartItem in cache)
			{
				if (element.item.hasOwnProperty("adherence"))
					filteredCache.push(element);
			}

			return filteredCache;
		}

		protected function group1_creationCompleteHandler(event:FlexEvent):void
		{
			refresh();
			simulationOnlyViewMode = false;
			updateComponentsForSimulationOnlyViewMode();
		}

		private const GOAL_ZONE_COLOR:uint = 0x8DCB86;

		public function drawBloodPressureData(canvas:DataDrawingCanvas):void
		{
			if (_traceEventHandlers)
				trace(this + ".drawBloodPressureData");

			canvas.clear();

			canvas.lineStyle(1, GOAL_ZONE_COLOR);

			// systolic normal
			canvas.beginFill(GOAL_ZONE_COLOR, 0.2);
			canvas.drawRect([Edge.LEFT, -1], 120, [Edge.RIGHT, 1], 90);
			canvas.endFill();

//				// diastolic normal
//				canvas.beginFill(GOAL_ZONE_COLOR, 0.2);
//				canvas.drawRect(Edge.LEFT, 80, Edge.RIGHT, 60);
//				canvas.endFill();

			if (canvas == bloodPressureMainCanvas)
			{
				canvas.updateDataChild(systolicZoneLabel, {left: Edge.LEFT, top: 120});
				//				canvas.updateDataChild(diastolicZoneLabel, {left: Edge.LEFT, bottom: 60});
			}
		}

		public function drawAdherenceData(canvas:DataDrawingCanvas):void
		{
			if (_traceEventHandlers)
				trace(this + ".drawAdherenceData");

			canvas.clear();

			canvas.lineStyle(1, GOAL_ZONE_COLOR);

			canvas.beginFill(GOAL_ZONE_COLOR, 0.2);
			canvas.drawRect([Edge.LEFT, -1], 0.35, [Edge.RIGHT, 1], 0.05);
			canvas.endFill();

			if (canvas == adherenceMainCanvas)
			{
				canvas.updateDataChild(goalMedicationZoneLabel, {left: Edge.LEFT, top: 0.35});
			}
		}

		//			private function offsetDataToToday(data:ArrayCollection, newDate:Date):void
		//			{
		//				var lastDate:Date = bloodPressureChart.dateParse(data[data.length - 1].date);
		//				var delta:Number = newDate.time - lastDate.time;
		//
		//				for each (var dataItem:Object in data)
		//				{
		//					var dataItemDate:Date = bloodPressureChart.dateParse(dataItem.date);
		//					dataItemDate.time += delta;
		//					var formattedDate:String = fullDateFormat.format(dataItemDate);
		//
		//					dataItem.date = formattedDate;
		//				}
		//			}

		/**
		 * If an error occurs loading the XML chart info
		 */
		private function faultResult(event:FaultEvent):void
		{
			Alert.show("Error retrieving XML data", "Error");
		}


		protected function bloodPressureChart_creationCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".bloodPressureChart_creationCompleteHandler");

			var mcCuneChart:McCuneChart = McCuneChart(event.target);

			mcCuneChart.mainChart.series = new Array();
			mcCuneChart.mainChart.series.push(systolicSeries);
			mcCuneChart.mainChart.series.push(diastolicSeries);

			mcCuneChart.rangeChart.series = new Array();
			mcCuneChart.rangeChart.series.push(systolicRangeSeries);
			mcCuneChart.rangeChart.series.push(diastolicRangeSeries);

			var verticalAxis:LinearAxis = mcCuneChart.mainChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = 40;
			verticalAxis.maximum = 160;

			verticalAxis = mcCuneChart.rangeChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = 40;
			verticalAxis.maximum = 160;

//				synchronizeDateLimits();

			updateBloodPressureChartBackgroundElements(mcCuneChart);
		}

		private function synchronizeDateLimits():void
		{
			var charts:Vector.<TouchScrollingMcCuneChart> = new Vector.<TouchScrollingMcCuneChart>();
			charts.push(adherenceChart);
			charts.push(bloodPressureChart);
//			charts.push(heartRateChart);

			var minimum:Number = charts[0].minimumTime;
			var maximum:Number = charts[0].maximumTime;
			for each (var chart:TouchScrollingMcCuneChart in charts)
			{
				minimum = Math.max(minimum, chart.minimumTime);
				maximum = Math.min(maximum, chart.maximumTime);
			}

			for each (chart in charts)
			{
				chart.minimumTime = minimum;
				chart.maximumTime = maximum;
			}
		}

		protected function adherenceChart_creationCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				trace("adherenceChart_creationCompleteHandler");
			var mcCuneChart:McCuneChart = McCuneChart(event.target);

			mcCuneChart.mainChart.series = new Array();
			mcCuneChart.mainChart.series.push(adherenceSeries);
			mcCuneChart.mainChart.series.push(concentrationSeries);

			mcCuneChart.rangeChart.series = new Array();
			mcCuneChart.rangeChart.series.push(concentrationRangeSeries);

			var verticalAxis:LinearAxis = mcCuneChart.mainChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = 0;
			verticalAxis.maximum = 0.4;

			verticalAxis = mcCuneChart.rangeChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = 0;
			verticalAxis.maximum = 0.4;

			updateAdherenceChartSeriesCompleteHandler(mcCuneChart);
		}

		protected function adherenceChart_initializeHandler(event:FlexEvent):void
		{
			// TODO Auto-generated method stub
			if (_traceEventHandlers)
				trace("adherenceChart_initializeHandler");
		}

		protected function heartRateChart_creationCompleteHandler(event:FlexEvent):void
		{
			var mcCuneChart:McCuneChart = McCuneChart(event.target);

			var verticalAxis:LinearAxis = mcCuneChart.mainChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = 50;
			verticalAxis.maximum = 100;
		}

		private function updateAdherenceChartSeriesCompleteHandler(mcCuneChart:McCuneChart):void
		{
			mcCuneChart.mainChart.backgroundElements.push(adherenceMainCanvas);
			drawAdherenceData(adherenceMainCanvas);
			mcCuneChart.rangeChart.backgroundElements.push(adherenceRangeCanvas);
			drawAdherenceData(adherenceRangeCanvas);
		}

		protected function adherenceChart_seriesCompleteHandler(event:Event):void
		{
			if (_traceEventHandlers)
				trace("adherenceChart_seriesCompleteHandler");
		}

		private function updateBloodPressureChartBackgroundElements(mcCuneChart:McCuneChart):void
		{
			mcCuneChart.mainChart.backgroundElements.push(bloodPressureMainCanvas);
			drawBloodPressureData(bloodPressureMainCanvas);
			mcCuneChart.rangeChart.backgroundElements.push(bloodPressureRangeCanvas);
			drawBloodPressureData(bloodPressureRangeCanvas);
		}

		protected function bloodPressureChart_seriesCompleteHandler(event:Event):void
		{
			if (_traceEventHandlers)
				trace("bloodPressureChart_seriesCompleteHandler");
		}

		protected function heartRateChart_seriesCompleteHandler(event:Event):void
		{
			// TODO Auto-generated method stub
		}

		protected function group1_keyDownHandler(event:KeyboardEvent):void
		{
			if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.F)
			{
				model.showFps = !model.showFps;
			}
			else if (event.altKey && event.ctrlKey)
			{
				switch (event.keyCode)
				{
					case (Keyboard.NUMBER_1):
					{
						this.stage.frameRate = 0;
						break;
					}
					case (Keyboard.NUMBER_2):
					{
						this.stage.frameRate = 24;
						break;
					}
					case (Keyboard.NUMBER_6):
					{
						this.stage.frameRate = 60;
						break;
					}
					case (Keyboard.NUMBER_7):
					{
						this.stage.frameRate = 120;
						break;
					}
					case Keyboard.B:
					{
						runScrollingBenchmark();
						break;
					}
				}
			}
		}

		private const benchmarkTrialDuration:Number = 2000;
		private var _benchmarkFrameCount:int;
		private var completeTrial:BenchmarkTrial;
		private var synchronizedTrial:BenchmarkTrial;
		private var individualTrials:Vector.<BenchmarkTrial>;
		private var individualChartsQueue:Vector.<TouchScrollingMcCuneChart>;
		//			private var adherenceTrial:BenchmarkTrial;
		//			private var bloodPressureTrial:BenchmarkTrial;
		//			private var heartRateTrial:BenchmarkTrial;
		public function runScrollingBenchmark():void
		{
			_benchmarkFrameCount = 0;

			var allCharts:Vector.<TouchScrollingMcCuneChart> = getAllCharts();
			var visibleCharts:Vector.<TouchScrollingMcCuneChart> = new Vector.<TouchScrollingMcCuneChart>();
			for each (var chart:TouchScrollingMcCuneChart in allCharts)
			{
				if (chart.visible)
					visibleCharts.push(chart);
			}
			setSingleChartMode(visibleCharts[0], false);

			visibleCharts = getVisibleCharts(allCharts, null, _singleChartMode, model.showAdherence,
											 model.showHeartRate);

			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);

			individualTrials = new Vector.<BenchmarkTrial>();
			completeTrial = new BenchmarkTrial();
			completeTrial.name = "Overall";
			individualTrials.push(completeTrial);
			completeTrial.start(_benchmarkFrameCount);
			synchronizedTrial = new BenchmarkTrial();
			synchronizedTrial.name = "Synchronized";
			individualTrials.push(synchronizedTrial);
			synchronizedTrial.start(_benchmarkFrameCount);

			doScrollTest(visibleCharts[0], 1, benchmarkTrialDuration, benchmarkStep2);
		}

		private function benchmarkStep2(event:Event):void
		{
			synchronizedTrial.stop(_benchmarkFrameCount);

			var allCharts:Vector.<TouchScrollingMcCuneChart> = getAllCharts();
			individualChartsQueue = getVisibleCharts(allCharts, null, _singleChartMode, model.showAdherence,
													 model.showHeartRate);

			startIndividualTrial();
		}

		private function startIndividualTrial():void
		{
			setSingleChartMode(individualChartsQueue[0], true);
			var trial:BenchmarkTrial = new BenchmarkTrial();
			trial.name = individualChartsQueue[0].id;
			individualTrials.push(trial);
			trial.start(_benchmarkFrameCount);
			doScrollTest(individualChartsQueue[0], 1, benchmarkTrialDuration, benchmarkStep3);
		}

		private function stopIndividualTrial():void
		{
			individualTrials[individualTrials.length - 1].stop(_benchmarkFrameCount);
			setSingleChartMode(individualChartsQueue[0], false);
			individualChartsQueue.shift();
		}

		private function benchmarkStep3(event:Event):void
		{
			stopIndividualTrial();

			if (individualChartsQueue.length > 0)
				startIndividualTrial();
			else
			{
				completeTrial.stop(_benchmarkFrameCount);

				trace("======= Benchmark Results ========");
//					trace("  Overall:        ", completeTrial.fps.toFixed(2));
//					trace("  Synchronized:   ", synchronizedTrial.fps.toFixed(2));
//					trace("  Adherence:      ", adherenceTrial.fps.toFixed(2));
//					trace("  Blood Pressure: ", bloodPressureTrial.fps.toFixed(2));
//					trace("  Heart Rate:     ", heartRateTrial.fps.toFixed(2));

				for each (var trial:BenchmarkTrial in individualTrials)
				{
					trace("  " + StringUtils.padRight(trial.name + ":", " ", 20), trial.fps.toFixed(2));
				}
			}
		}

		//			private function benchmarkStep4(event:Event):void
		//			{
		//				bloodPressureTrial.stop(_benchmarkFrameCount);
		//				setSingleChartMode(bloodPressureChart, false);
		//				setSingleChartMode(heartRateChart, true);
		//				heartRateTrial = new BenchmarkTrial();
		//				heartRateTrial.start(_benchmarkFrameCount);
		//				doScrollTest(heartRateChart, 1, 6000, benchmarkStep5);
		//			}

		//			private function benchmarkStep5(event:Event):void
		//			{
		//				heartRateTrial.stop(_benchmarkFrameCount);
		//				setSingleChartMode(heartRateChart, false);
		//
		//			}

		private function doScrollTest(chart:TouchScrollingMcCuneChart, screensToScroll:Number, timeToScroll:Number,
									  effectEndHandler:Function):void
		{
			var scrollRightAnimate:Animate = new Animate(chart);
//				scrollRightAnimate.easer = new Power(0.5, 3);
			scrollRightAnimate.easer = new Linear();
			scrollRightAnimate.duration = timeToScroll;
//				scrollRightAnimate.addEventListener(TweenEvent.TWEEN_UPDATE, function():void { this.validateNow(); });
//				scrollRightAnimate.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
			scrollRightAnimate.motionPaths = new Vector.<MotionPath>();

			var scrollRightPath:SimpleMotionPath = new SimpleMotionPath();
			scrollRightPath.property = "contentPositionX";
//				scrollRightPath.valueFrom = -chart.scrollableAreaWidth + chart.panelWidth;
			scrollRightPath.valueFrom = chart.contentPositionX;
			scrollRightPath.valueTo = scrollRightPath.valueFrom + chart.panelWidth * screensToScroll;
			scrollRightAnimate.motionPaths.push(scrollRightPath);

			var scrollLeftAnimate:Animate = new Animate(chart);
//				scrollLeftAnimate.easer = new Power(0.5, 3);
			scrollLeftAnimate.easer = new Linear();
			scrollLeftAnimate.duration = timeToScroll;
//				scrollLeftAnimate.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);
			scrollLeftAnimate.motionPaths = new Vector.<MotionPath>();

			var scrollLeftPath:SimpleMotionPath = new SimpleMotionPath();
			scrollLeftPath.property = "contentPositionX";
			scrollLeftPath.valueTo = scrollRightPath.valueFrom;
			scrollLeftAnimate.motionPaths.push(scrollLeftPath);

			var sequence:Sequence = new Sequence(chart);
			sequence.addChild(scrollRightAnimate);
			sequence.addChild(scrollLeftAnimate);
			sequence.addEventListener(EffectEvent.EFFECT_END, effectEndHandler);

			sequence.play();
		}

		private function enterFrameHandler(event:Event):void
		{
			_benchmarkFrameCount++;
		}

		private var _singleChartMode:Boolean = false;
		private var _chartFooterVisible:Boolean = true;

		protected function chart_doubleClickHandler(event:MouseEvent):void
		{
			var targetChart:TouchScrollingMcCuneChart = TouchScrollingMcCuneChart(event.currentTarget);

			setSingleChartMode(targetChart, !_singleChartMode);
		}

		protected function setSingleChartMode(targetChart:TouchScrollingMcCuneChart, mode:Boolean):void
		{
			_singleChartMode = mode;

			_scrollTargetChart = null;
			updateChartsCache(targetChart);

//				targetChart.headerVisible = true;
//				targetChart.sliderVisible = true;
//				targetChart.topBorderVisible = true;

			var allCharts:Vector.<TouchScrollingMcCuneChart> = getAllCharts();
//				var visibleCharts:Vector.<TouchScrollingMcCuneChart> = getVisibleCharts(allCharts, targetChart, _singleChartMode, model.showAdherence, model.showHeartRate);
//				var otherCharts:Vector.<TouchScrollingMcCuneChart> = getOtherCharts(targetChart);
//				for (var i:int = 0; i < chartsGroup.numElements; i++)
//				{
//					var chart:TouchScrollingMcCuneChart = chartsGroup.getElementAt(i) as TouchScrollingMcCuneChart;
			for (var i:int = 0; i < _visibleCharts.length; i++)
			{
				var chart:TouchScrollingMcCuneChart = _visibleCharts[i] as TouchScrollingMcCuneChart;

				// middle chart
				chart.headerVisible = false;
				chart.footerVisible = false;
				chart.sliderVisible = false;
				chart.topBorderVisible = true;

				if (i == 0)
				{
					// top chart
					chart.topBorderVisible = true;
				}

				if (i == _visibleCharts.length - 1)
				{
					// bottom chart
					chart.footerVisible = chartFooterVisible;
//						chart.sliderVisible = true;
				}
			}

			for each (chart in allCharts)
			{
				var visible:Boolean = _visibleCharts.indexOf(chart) != -1;
				chart.visible = visible;
				chart.includeInLayout = visible;

//					trace("Visibility of", chart.id, ":", visible);
			}

			if (_visibleCharts.length > 1 && targetChart != null)
			{
				var nonTargetCharts:Vector.<TouchScrollingMcCuneChart> = getVisibleNonTargetCharts(_visibleCharts,
																								   targetChart);
				synchronizeScrollPositions(targetChart, nonTargetCharts);
				synchronizeFocusTimes(targetChart, nonTargetCharts);
			}
		}

		protected function getAllCharts():Vector.<TouchScrollingMcCuneChart>
		{
			var allCharts:Vector.<TouchScrollingMcCuneChart> = new Vector.<TouchScrollingMcCuneChart>();
			for (var i:int = 0; i < chartsGroup.numElements; i++)
			{
				var chart:TouchScrollingMcCuneChart = chartsGroup.getElementAt(i) as TouchScrollingMcCuneChart;
				if (chart != null)
					allCharts.push(chart);
			}
			return allCharts;
		}

		protected function getVisibleCharts(allCharts:Vector.<TouchScrollingMcCuneChart>,
											targetChart:TouchScrollingMcCuneChart, singleChartMode:Boolean,
											showAdherence:Boolean,
											showHeartRate:Boolean):Vector.<TouchScrollingMcCuneChart>
		{
			var visibleCharts:Vector.<TouchScrollingMcCuneChart> = new Vector.<TouchScrollingMcCuneChart>();
			for each (var chart:TouchScrollingMcCuneChart in allCharts)
			{
				if (singleChartMode)
				{
					if (chart == targetChart)
						visibleCharts.push(chart);
				}
				else if (chart == adherenceChart)
				{
					if (showAdherence)
						visibleCharts.push(chart);
				}
//				else if (chart == heartRateChart)
//				{
//					if (showHeartRate)
//						visibleCharts.push(chart);
//				}
				else
				{
					visibleCharts.push(chart);
				}
			}
			return visibleCharts;
		}

		protected function getVisibleNonTargetCharts(visibleCharts:Vector.<TouchScrollingMcCuneChart>,
													 targetChart:TouchScrollingMcCuneChart):Vector.<TouchScrollingMcCuneChart>
		{
			var visibleNonTargetCharts:Vector.<TouchScrollingMcCuneChart> = new Vector.<TouchScrollingMcCuneChart>();
			for each (var chart:TouchScrollingMcCuneChart in visibleCharts)
			{
				if (chart != targetChart)
				{
					visibleNonTargetCharts.push(chart);
				}
			}
			return visibleNonTargetCharts;
		}

		private var _scrollTargetChart:TouchScrollingMcCuneChart;
		private var _nonTargetCharts:Vector.<TouchScrollingMcCuneChart>;
		private var _visibleCharts:Vector.<TouchScrollingMcCuneChart>;

		protected function chart_scrollHandler(event:ScrollEvent):void
		{
			var targetChart:TouchScrollingMcCuneChart = TouchScrollingMcCuneChart(event.currentTarget);
			updateChartsCache(targetChart);

			if (!_singleChartMode)
			{
				synchronizeScrollPositions(targetChart, _nonTargetCharts);
			}

			updateSimulation(targetChart);
		}

		protected function synchronizeScrollPositions(targetChart:TouchScrollingMcCuneChart,
													  otherCharts:Vector.<TouchScrollingMcCuneChart>):void
		{
			for each (var otherChart:TouchScrollingMcCuneChart in otherCharts)
			{
				if (otherChart.visible)
				{
					otherChart.stopInertiaScrolling();
					otherChart.leftRangeTime = targetChart.leftRangeTime;
					otherChart.rightRangeTime = targetChart.rightRangeTime;
					otherChart.updateForScroll();
				}
			}
		}

		protected function synchronizeFocusTimes(targetChart:TouchScrollingMcCuneChart,
												 otherCharts:Vector.<TouchScrollingMcCuneChart>):void
		{
			for each (var otherChart:TouchScrollingMcCuneChart in otherCharts)
			{
				if (otherChart.visible)
				{
//						otherChart.stopInertiaScrolling();
//						otherChart.leftRangeTime = targetChart.leftRangeTime;
//						otherChart.rightRangeTime = targetChart.rightRangeTime;
//						otherChart.updateForScroll();
					otherChart.focusTime = targetChart.focusTime;
				}
			}
		}

		protected function chart_scrollStartHandler(event:TouchScrollerEvent):void
		{
			var targetChart:TouchScrollingMcCuneChart = TouchScrollingMcCuneChart(event.currentTarget);

			if (_traceEventHandlers)
				trace(this.id + ".chart_scrollStartHandler " + targetChart.id);
		}

		protected function chart_scrollStopHandler(event:TouchScrollerEvent):void
		{
			var targetChart:TouchScrollingMcCuneChart = TouchScrollingMcCuneChart(event.currentTarget);

			if (_traceEventHandlers)
				trace(this.id + ".chart_scrollStopHandler " + targetChart.id);
		}

		protected function chart_focusTimeChangeHandler(event:FocusTimeEvent):void
		{
			var targetChart:TouchScrollingMcCuneChart = TouchScrollingMcCuneChart(event.currentTarget);

			updateChartsCache(targetChart);

			if (!_singleChartMode)
			{
				synchronizeFocusTimes(targetChart, _nonTargetCharts);
			}

			updateSimulation(targetChart);
		}

		private function updateChartsCache(targetChart:TouchScrollingMcCuneChart):void
		{
			if (targetChart == null || _scrollTargetChart != targetChart)
			{
				var allCharts:Vector.<TouchScrollingMcCuneChart> = getAllCharts();
				_visibleCharts = getVisibleCharts(allCharts, targetChart, _singleChartMode, model.showAdherence,
												  model.showHeartRate);
				_nonTargetCharts = getVisibleNonTargetCharts(_visibleCharts, targetChart);
				_scrollTargetChart = targetChart;
			}
		}

		private function updateSimulation(targetChart:TouchScrollingMcCuneChart):void
		{
			model.simulation.date = new Date(targetChart.focusTime);

			var bloodPressureDataPoint:Object = bloodPressureChart.findPreviousDataPoint(model.simulation.date.time);
			var concentrationDataPoint:Object = adherenceChart.findPreviousDataPoint(model.simulation.date.time);

			model.simulation.dataPointDate = bloodPressureDataPoint == null ? null : bloodPressureDataPoint.date;
			model.simulation.systolic = bloodPressureDataPoint == null ? NaN : bloodPressureDataPoint.systolic;
			model.simulation.diastolic = bloodPressureDataPoint == null ? NaN : bloodPressureDataPoint.diastolic;

			var hypertensionSeverity:Number = 0;
			if (!isNaN(model.simulation.systolic))
			{
				hypertensionSeverity = Math.max(0, (model.simulation.systolic - 120) / 20);
			}

//				simulationGlow.alpha = hypertensionSeverity;

			// TODO: show the date for the concentration data point
			model.simulation.concentration = concentrationDataPoint == null ? NaN : concentrationDataPoint.concentration;
		}

		private var simulationOnlyViewMode:Boolean = false;
		private var _chartsOnlyViewMode:Boolean = false;
		private var _initialDurationTime:Number = McCuneChart.DAYS_TO_MILLISECONDS * 30;

		public function get chartsOnlyViewMode():Boolean
		{
			return _chartsOnlyViewMode;
		}

		public function set chartsOnlyViewMode(value:Boolean):void
		{
			_chartsOnlyViewMode = value;
		}

		protected function simulationView_doubleClickHandler(event:MouseEvent):void
		{
			simulationOnlyViewMode = !simulationOnlyViewMode;
			updateComponentsForSimulationOnlyViewMode();
		}

		private function updateComponentsForSimulationOnlyViewMode():void
		{
			if (simulationOnlyViewMode)
			{
				chartsGroup.percentWidth = 0;
				chartsGroup.visible = false;
				simulationView.width = NaN;
				simulationView.percentWidth = 100;
				simulationView.visible = true;
			}
			else if (chartsOnlyViewMode)
			{
				chartsGroup.percentWidth = 100;
				chartsGroup.visible = true;
				simulationView.width = NaN;
				simulationView.percentWidth = 0;
				simulationView.visible = false;
			}
			else
			{
				chartsGroup.percentWidth = 100;
				chartsGroup.visible = true;
				simulationView.percentWidth = NaN;
				simulationView.width = 260;
				simulationView.visible = true;
			}
		}

		public function get chartFooterVisible():Boolean
		{
			return _chartFooterVisible;
		}

		public function set chartFooterVisible(value:Boolean):void
		{
			_chartFooterVisible = value;
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
