package collaboRhythm.plugins.bloodPressure.view
{
	import assets.images.BloodPressureScheduleItemClockView;

	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.apps.bloodPressure.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.apps.bloodPressure.model.SimulationModel;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.derived.MedicationConcentrationSample;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.view.scroll.TouchScrollerEvent;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SynchronizedAxisCache;
	import com.dougmccune.controls.TouchScrollingScrubChart;
	import com.dougmccune.events.FocusTimeEvent;
	import com.theory9.data.types.OrderedMap;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

	import mx.charts.ChartItem;
	import mx.charts.HitData;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.CartesianDataCanvas;
	import mx.charts.chartClasses.Series;
	import mx.charts.series.AreaSeries;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.effects.Sequence;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.IFocusManagerComponent;
	import mx.rpc.events.FaultEvent;

	import qs.charts.dataShapes.DataDrawingCanvas;
	import qs.charts.dataShapes.Edge;

	import skins.LineSeriesCustomRenderer;

	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Linear;
	import spark.events.SkinPartEvent;
	import spark.layouts.VerticalAlign;

	public class SynchronizedCharts extends VGroup implements IFocusManagerComponent
	{
		public function SynchronizedCharts():void
		{
			// TODO: use CSS instead for these
			percentHeight = 100;
			percentWidth = 100;
			gap = 10;
			paddingLeft = 10;
			paddingRight = 0;
			paddingTop = 10;
			paddingBottom = 8;
			clipAndEnableScrolling = true;
			
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_medicationColorSource = WorkstationKernel.instance.resolve(IMedicationColorSource) as IMedicationColorSource;
			skipUpdateSimulation = modality == Settings.MODALITY_TABLET;
			showFocusTimeMarker = !skipUpdateSimulation;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true);
		}

		private static const STRIP_CHART_VERTICAL_AXIS_MINIMUM:Number = -0.5;
		private static const STRIP_CHART_VERTICAL_AXIS_MAXIMUM:Number = 0.5;

		private static const STRIP_CHART_DAY_COLOR:int = 0xD6D6D6;
		private static const STRIP_CHART_NIGHT_COLOR:int = 0xBFBEBE;

		private var _textFormat:TextFormat = new TextFormat("Myriad Pro, Verdana, Helvetica, Arial", 16, 0, true);

		private var _model:BloodPressureModel;
		protected var _traceEventHandlers:Boolean = false;
		private var _showFocusTimeMarker:Boolean = true;
		private var _scrollEnabled:Boolean = true;
		protected var _logger:ILogger;
		private var _rangeChartVisible:Boolean = false;
		private var _adherenceCharts:OrderedMap = new OrderedMap();
		private var _adherenceChartsCreated:Boolean;
		private var _medicationColorSource:IMedicationColorSource;
		private var _modality:String;

		private var _initialDurationTime:Number = ScrubChart.DAYS_TO_MILLISECONDS * 7;
		private var _useHorizontalTouchScrolling:Boolean = true;

		protected const GOAL_ZONE_COLOR:uint = 0x8DCB86;
		private var seriesSets:Vector.<ScrubChartSeriesSet> = new Vector.<ScrubChartSeriesSet>();
		private var _seriesWithPendingUpdateComplete:ArrayCollection = new ArrayCollection();
		private var _chartsWithPendingCreationComplete:ArrayCollection = new ArrayCollection();
		private var _pendingSynchronizeDateLimits:Boolean;
		private var _useSliceMainData:Boolean;

		private const benchmarkTrialDuration:Number = 2000;
		private var _benchmarkFrameCount:int;
		private var completeTrial:BenchmarkTrial;
		private var synchronizedTrial:BenchmarkTrial;
		private var individualTrials:Vector.<BenchmarkTrial>;
		private var individualChartsQueue:Vector.<TouchScrollingScrubChart>;
		//			private var adherenceTrial:BenchmarkTrial;
		//			private var bloodPressureTrial:BenchmarkTrial;
		//			private var heartRateTrial:BenchmarkTrial;

		private var _singleChartMode:Boolean = false;
		private var _chartFooterVisible:Boolean = true;

		private var _charts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
		private var _customCharts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
		private var _scrollTargetChart:TouchScrollingScrubChart;
		private var _nonTargetCharts:Vector.<TouchScrollingScrubChart>;
		private var _visibleCharts:Vector.<TouchScrollingScrubChart>;
		private var _skipUpdateSimulation:Boolean = false;
		private var _shouldApplyChangesToSimulation:Boolean = true;
		private var _pendingUpdateSimulation:TouchScrollingScrubChart;
		private var _createChildrenComplete:Boolean;

		// TODO: use synchronizedAxisCache to optimize performance or eliminate synchronizedAxisCache
		[Bindable]
		protected var synchronizedAxisCache:SynchronizedAxisCache;

		[Bindable]
		public function get scrollEnabled():Boolean
		{
			return _scrollEnabled;
		}

		public function set scrollEnabled(value:Boolean):void
		{
			_scrollEnabled = value;
			for each (var chart:TouchScrollingScrubChart in _adherenceCharts.values())
			{
				chart.scrollEnabled = scrollEnabled;
			}
			trace("scrollEnabled", scrollEnabled);
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
			return _rangeChartVisible;
		}

		public function set rangeChartVisible(value:Boolean):void
		{
			_rangeChartVisible = value;
			updateRangeChartVisibleStyles();
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
			_model.addEventListener(FlexEvent.UPDATE_COMPLETE, model_updateCompleteHandler, false, 0, true);
			_model.addEventListener(Event.CHANGE, model_changeHandler, false, 0, true);

			if (_createChildrenComplete)
				respondToModelUpdate();
		}

		private function model_changeHandler(event:Event):void
		{
			queueSynchronizeDateLimits();
		}

		private function model_updateCompleteHandler(event:FlexEvent):void
		{
			queueSynchronizeDateLimits();
		}

		private function queueSynchronizeDateLimits():void
		{
			_pendingSynchronizeDateLimits = true;
			invalidateProperties();
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			//trace("model_propertyChangeHandler", event.property);
			if (event.property == "showAdherence" || event.property == "isInitialized" && _createChildrenComplete)
			{
				respondToModelUpdate();
			}
		}

		private function createAdherenceCharts():void
		{
			if (!_adherenceChartsCreated)
			{
				_adherenceChartsCreated = true;
				createMedicationAdherenceCharts();
				createVitalSignAdherenceCharts();
				createCustomCharts();
			}
			else
			{
				updateAdherenceCharts();
			}
		}

		/**
		 * Subclasses should override to create custom charts.
		 */
		protected function createCustomCharts():void
		{
		}

		private function createMedicationAdherenceCharts():void
		{
			for each (var medicationCode:String in model.medicationConcentrationCurvesByCode.keys)
			{
				var medicationFill:MedicationFill = getMedicationFill(medicationCode);
				var medicationAdministrationsCollection:ArrayCollection = model.record.medicationAdministrationsModel.medicationAdministrationsCollectionsByCode.getItem(medicationCode);
				if (medicationAdministrationsCollection && medicationAdministrationsCollection[0])
				{
					var medicationAdministration:MedicationAdministration = medicationAdministrationsCollection[0];
					var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);
					if (medicationModel == null)
						throw new Error("Medication " + medicationCode + " is in model.medicationConcentrationCurvesByCode but not in model.simulation.medicationsByCode");

					var medicationScheduleItem:MedicationScheduleItem = medicationModel.medicationScheduleItem;
					var concentrationChart:TouchScrollingScrubChart = createConcentrationChart(medicationCode,
							medicationFill,
							medicationAdministration);
					var adherenceStripChart:TouchScrollingScrubChart = createMedicationAdherenceStripChart(medicationCode,
							medicationFill
					);
					var medicationView:MedicationScheduleItemChartView = new MedicationScheduleItemChartView();
					medicationView.medicationScheduleItem = medicationScheduleItem;
					medicationView.verticalAlign = VerticalAlign.MIDDLE;
					medicationView.percentHeight = 100;
					createAdherenceGroup(medicationView, concentrationChart, adherenceStripChart);
				}
			}
		}

		private function createConcentrationChart(medicationCode:String, medicationFill:MedicationFill, medicationAdministration:MedicationAdministration):TouchScrollingScrubChart
		{
			var chart:TouchScrollingScrubChart = createAdherenceChart(
					getConcentrationChartKey(medicationCode));
			setMedicationChartStyles(medicationCode, medicationFill, chart);
			chart.setStyle("topBorderVisible", true);
			var nameString:String;
			if (medicationFill)
				nameString = medicationFill.name.text;
			else
				nameString = medicationAdministration.name.text;
			var medicationName:MedicationName = MedicationNameUtil.parseName(nameString);
			chart.mainChartTitle = medicationName.medicationName;

			chart.seriesName = "concentration";
			chart.data = model.medicationConcentrationCurvesByCode.getItem(medicationCode);

			chart.addEventListener(SkinPartEvent.PART_ADDED, medicationAdherenceChart_skinPartAddedHandler, false, 0,
					true);
			chart.addEventListener(FlexEvent.CREATION_COMPLETE, medicationAdherenceChart_creationCompleteHandler,
					false, 0, true);

			return chart;
		}

		private function createMedicationAdherenceStripChart(medicationCode:String, medicationFill:MedicationFill):TouchScrollingScrubChart
		{
			var chart:TouchScrollingScrubChart = createAdherenceChart(
					getAdherenceStripChartKey(medicationCode));

			setMedicationChartStyles(medicationCode, medicationFill, chart);
			initializeAdherenceStripChart(chart, medicationCode);

			chart.addEventListener(SkinPartEvent.PART_ADDED, medicationAdherenceStripChart_skinPartAddedHandler, false, 0,
					true);
			chart.addEventListener(FlexEvent.CREATION_COMPLETE, medicationAdherenceStripChart_creationCompleteHandler,
					false, 0, true);

			return chart;
		}

		private function initializeAdherenceStripChart(chart:TouchScrollingScrubChart, adherenceItemsCode:String):void
		{
			chart.setStyle("topBorderVisible", false);
			chart.height = 20;
			chart.seriesName = "adherence";
			chart.data = model.adherenceItemsCollectionsByCode.getItem(adherenceItemsCode);
			chart.dateField = "dateReported";
		}

		private function createAdherenceChart(chartKey:String):TouchScrollingScrubChart
		{
			var chart:TouchScrollingScrubChart = new TouchScrollingScrubChart();
			chart.id = chartKey;
			chart.setStyle("skinClass", ScrubChartMedicationSkin);
//			chart.setStyle("skinClass", ScrubChartMinimalSkin);
			chart.percentWidth = 100;
			chart.percentHeight = 100;
			chart.setStyle("sliderVisible", false);
			chart.today = model.currentDateSource.now();
			chart.showFps = model.showFps;
			chart.initialDurationTime = initialDurationTime;
			chart.showFocusTimeMarker = false;
			chart.scrollEnabled = scrollEnabled;
			chart.synchronizedAxisCache = synchronizedAxisCache;
			chart.useHorizontalTouchScrolling = useHorizontalTouchScrolling;

			chart.addEventListener(ScrollEvent.SCROLL, chart_scrollHandler, false, 0, true);
			chart.addEventListener(TouchScrollerEvent.SCROLL_START, chart_scrollStartHandler, false, 0,
					true);
			chart.addEventListener(TouchScrollerEvent.SCROLL_STOP, chart_scrollStopHandler, false, 0, true);
			chart.addEventListener(FocusTimeEvent.FOCUS_TIME_CHANGE, chart_focusTimeChangeHandler, false, 0,
					true);

			_chartsWithPendingCreationComplete.addItem(chart);
			_adherenceCharts.addKeyValue(chartKey, chart);
			addChart(chart);
			chart.percentWidth = 100;
			chart.percentHeight = 100;

			return chart;
		}

		private function setMedicationChartStyles(medicationCode:String, medicationFill:MedicationFill, chart:TouchScrollingScrubChart):void
		{
			chart.setStyle("medicationCode", medicationCode);
			if (medicationFill)
				chart.setStyle("ndcCode", medicationFill.ndc.text);
		}

		private function addChart(chart:TouchScrollingScrubChart):void
		{
			_charts.push(chart);
		}
		
		protected function addCustomChart(chart:TouchScrollingScrubChart):void
		{
			addChart(chart);
			_customCharts.push(chart);
		}

		private function getConcentrationChartKey(medicationCode:String):String
		{
			return "medication_" + medicationCode + "_concentration";
		}

		private function getAdherenceStripChartKey(medicationCode:String):String
		{
			return "medication_" + medicationCode + "_adherence";
		}

		private function getVitalSignChartKey(vitalSignKey:String):String
		{
			return "vitalSign_" + vitalSignKey + "_concentration";
		}

		private function getVitalSignAdherenceStripChartKey(vitalSignKey:String):String
		{
			return "vitalSign_" + vitalSignKey + "_adherence";
		}

		private function createAdherenceGroup(image:IVisualElement, concentrationChart:TouchScrollingScrubChart, adherenceStripChart:TouchScrollingScrubChart):void
		{
			var adherenceChartsGroup:VGroup = new VGroup();
			adherenceChartsGroup.gap = 0;
			adherenceChartsGroup.addElement(concentrationChart);
			adherenceChartsGroup.addElement(adherenceStripChart);
			adherenceChartsGroup.percentWidth = 100;
			adherenceChartsGroup.percentHeight = 100;

			var adherenceGroup:HGroup = new HGroup();
			adherenceGroup.gap = 0;
			adherenceGroup.addElement(image);
			adherenceGroup.addElement(adherenceChartsGroup);
			adherenceGroup.percentWidth = 100;
			adherenceGroup.percentHeight = 100;

			this.addElement(adherenceGroup);
		}

		protected function addCustomChartGroup(group:UIComponent):void
		{
			this.addElement(group);
		}

		private function createVitalSignAdherenceCharts():void
		{
			for each (var vitalSignKey:String in vitalSignChartCategories)
			{
				// find any equipment scheduled to be used to collect this vital sign
				var equipmentScheduleItem:EquipmentScheduleItem = getMatchingEquipmentScheduleItem(vitalSignKey);
				var equipment:Equipment = equipmentScheduleItem.scheduledEquipment;
				
				var vitalSignCollection:ArrayCollection = model.record.vitalSignsModel.vitalSignsByCategory[vitalSignKey];

				if (vitalSignCollection && vitalSignCollection.length > 0 && vitalSignCollection[0])
				{
					var vitalSignChart:TouchScrollingScrubChart = createVitalSignChart(vitalSignKey, vitalSignCollection);
					var adherenceStripChart:TouchScrollingScrubChart = createVitalSignAdherenceStripChart(vitalSignKey, equipmentScheduleItem);

					var vitalSignView:BloodPressureScheduleItemClockView = new BloodPressureScheduleItemClockView();
//					vitalSignView.equipmentScheduleItem = equipmentScheduleItem;
					vitalSignView.width = 100;
					vitalSignView.height = 100;
					vitalSignView.verticalCenter = 0;
					createAdherenceGroup(vitalSignView, vitalSignChart, adherenceStripChart);
				}
			}
		}

		/**
		 * Provides the list of vital signs categories (VitalSign.name), such as "Heart Rate", "Blood Pressure Systolic",
		 * etc. that will be used to create the vital sign charts. Subclasses may override this property to exclude
		 * vital sign charts and then create alternative charts for those vital signs (or exclude them entirely).
		 */
		protected function get vitalSignChartCategories():ArrayCollection
		{
			return model.record.vitalSignsModel.vitalSignsByCategory.keys;
		}

		private function createVitalSignChart(vitalSignKey:String, vitalSignCollection:ArrayCollection):TouchScrollingScrubChart
		{
			var chart:TouchScrollingScrubChart = createAdherenceChart(getVitalSignChartKey(vitalSignKey));
			setVitalSignChartStyles(chart, vitalSignKey);

			chart.setStyle("topBorderVisible", true);
			chart.mainChartTitle = vitalSignKey;

			chart.dateField = "dateMeasuredStart";
			chart.seriesName = "resultAsNumber";
			chart.data = model.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignKey);

			chart.addEventListener(SkinPartEvent.PART_ADDED, vitalSignAdherenceChart_skinPartAddedHandler, false, 0,
					true);

			return chart;
		}

		private function setVitalSignChartStyles(chart:TouchScrollingScrubChart, vitalSignKey:String):void
		{
			chart.setStyle("vitalSignKey", vitalSignKey);
		}

		private function createVitalSignAdherenceStripChart(vitalSignKey:String, equipmentScheduleItem:EquipmentScheduleItem):TouchScrollingScrubChart
		{
			var chart:TouchScrollingScrubChart = createAdherenceChart(getVitalSignAdherenceStripChartKey(vitalSignKey));
			setVitalSignChartStyles(chart, vitalSignKey);

			initializeAdherenceStripChart(chart, equipmentScheduleItem.name.text);

			chart.addEventListener(SkinPartEvent.PART_ADDED, vitalSignAdherenceStripChart_skinPartAddedHandler, false, 0,
					true);

			return chart;
		}

		private function getMatchingEquipmentScheduleItem(vitalSignKey:String):EquipmentScheduleItem
		{
			for each (var equipmentScheduleItem:EquipmentScheduleItem in model.record.equipmentScheduleItemsModel.equipmentScheduleItemCollection)
			{
				if (equipmentScheduleItem.instructions.toLowerCase().search(vitalSignKey.toLowerCase()) != -1)
				{
					break;
				}
			}
			return equipmentScheduleItem;
		}

		// TODO: implement and use this method to update the charts when the demo date changes
		private function updateAdherenceCharts():void
		{
			for each (var medicationCode:String in model.medicationConcentrationCurvesByCode.keys)
			{
				updateAdherenceChart(getConcentrationChartKey(medicationCode),
						model.medicationConcentrationCurvesByCode.getItem(medicationCode), "date");
				updateAdherenceChart(getAdherenceStripChartKey(medicationCode),
						model.adherenceItemsCollectionsByCode.getItem(medicationCode), "dateReported");
			}
		}

		private function updateAdherenceChart(chartKey:String, seriesDataCollection:ArrayCollection, dateField:String):void
		{
			var chart:TouchScrollingScrubChart = _adherenceCharts.getValueByKey(chartKey);
			if (chart)
			{
				chart.data = seriesDataCollection;
				chart.clearDataSets();
				chart.addDataSet(seriesDataCollection, dateField);
				var series:Series = chart.mainChart.series[0];
				if (series)
				{
					series.dataProvider = seriesDataCollection;
				}
			}
		}

		private function medicationAdherenceChart_skinPartAddedHandler(event:SkinPartEvent):void
		{
			if (event.partName == "mainChart")
			{
				var chart:ScrubChart = ScrubChart(event.target);
				//			chart.removeDefaultSeries();

				var medicationCode:String = chart.getStyle("medicationCode");
				var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);

				var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
				verticalAxis.minimum = 0;
				verticalAxis.maximum = medicationModel.concentrationAxisMaximum;

				var ndcCode:String = chart.getStyle("ndcCode");
				chart.removeDefaultSeries();
				addConcentrationSeries(chart, medicationCode, ndcCode);

				var mainCanvas:DataDrawingCanvas = chart.mainChart.backgroundElements[0] as DataDrawingCanvas;
				if (mainCanvas)
				{
					updateAdherenceChartSeriesCompleteHandler(chart, mainCanvas,
							mainCanvas ? mainCanvas.getChildAt(0) as Label : null,
							null, medicationCode, ndcCode);
					mainCanvas.invalidateSize();
				}

				var index:int = _chartsWithPendingCreationComplete.getItemIndex(chart);
				if (index != -1)
				{
					_chartsWithPendingCreationComplete.removeItemAt(index);
					checkReadyToSynchronizeDateLimits();
				}

				chart.mainChart.dataTipFunction = adherenceChart_dataTipFunction;
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					verticalAxis = chart.rangeChart.verticalAxis as LinearAxis;
					verticalAxis.minimum = 0;
					verticalAxis.maximum = medicationModel.concentrationAxisMaximum;
				}
			}
		}

		private function vitalSignAdherenceChart_skinPartAddedHandler(event:SkinPartEvent):void
		{
			if (event.partName == "mainChart")
			{
				var chart:ScrubChart = ScrubChart(event.target);
				//			chart.removeDefaultSeries();

				var vitalSignKey:String = chart.getStyle("vitalSignKey");
//				var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);

				var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
				verticalAxis.minimum = 0;
				verticalAxis.maximum = 200;

				chart.removeDefaultSeries();
				addVitalSignSeries(chart,  vitalSignKey);

				var mainCanvas:DataDrawingCanvas = chart.mainChart.backgroundElements[0] as DataDrawingCanvas;
				if (mainCanvas)
				{
					updateVitalSignAdherenceChartSeriesCompleteHandler(chart, mainCanvas,
							mainCanvas ? mainCanvas.getChildAt(0) as Label : null,
							null, vitalSignKey);
					mainCanvas.invalidateSize();
				}

				var index:int = _chartsWithPendingCreationComplete.getItemIndex(chart);
				if (index != -1)
				{
					_chartsWithPendingCreationComplete.removeItemAt(index);
					checkReadyToSynchronizeDateLimits();
				}

				chart.mainChart.dataTipFunction = adherenceChart_dataTipFunction;
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					verticalAxis = chart.rangeChart.verticalAxis as LinearAxis;
					verticalAxis.minimum = 0;
					verticalAxis.maximum = 201;
				}
			}
		}

		protected function medicationAdherenceChart_creationCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				trace("medicationAdherenceChart_creationCompleteHandler");
		}

		private function medicationAdherenceStripChart_skinPartAddedHandler(event:SkinPartEvent):void
		{
			if (event.partName == "mainChartContainer")
			{
				var mainChartContainer:UIComponent = event.instance as UIComponent;
				if (mainChartContainer)
					mainChartContainer.setStyle("backgroundColor", STRIP_CHART_DAY_COLOR);
			}
			else if (event.partName == "mainChart")
			{
				var chart:ScrubChart = ScrubChart(event.target);
				//			chart.removeDefaultSeries();

				var medicationCode:String = chart.getStyle("medicationCode");

				var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
				verticalAxis.minimum = STRIP_CHART_VERTICAL_AXIS_MINIMUM;
				verticalAxis.maximum = STRIP_CHART_VERTICAL_AXIS_MAXIMUM;

				var ndcCode:String = chart.getStyle("ndcCode");

				chart.removeDefaultSeries();
				addAdherenceSeries(chart, medicationCode);

				var mainCanvas:DataDrawingCanvas = chart.mainChart.backgroundElements[0] as DataDrawingCanvas;
				if (mainCanvas)
				{
					updateAdherenceStripChartSeriesCompleteHandler(chart, mainCanvas,
							mainCanvas ? mainCanvas.getChildAt(0) as Label : null, null, medicationCode,
							model.record.medicationScheduleItemsModel.medicationScheduleItemCollection);
					mainCanvas.invalidateSize();
				}

				var index:int = _chartsWithPendingCreationComplete.getItemIndex(chart);
				if (index != -1)
				{
					_chartsWithPendingCreationComplete.removeItemAt(index);
					checkReadyToSynchronizeDateLimits();
				}

				chart.mainChart.dataTipFunction = adherenceChart_dataTipFunction;
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					verticalAxis = chart.rangeChart.verticalAxis as LinearAxis;
					verticalAxis.minimum = STRIP_CHART_VERTICAL_AXIS_MINIMUM;
					verticalAxis.maximum = STRIP_CHART_VERTICAL_AXIS_MAXIMUM;
				}
			}
		}

		private function vitalSignAdherenceStripChart_skinPartAddedHandler(event:SkinPartEvent):void
		{
			if (event.partName == "mainChartContainer")
			{
				var mainChartContainer:UIComponent = event.instance as UIComponent;
				if (mainChartContainer)
					mainChartContainer.setStyle("backgroundColor", STRIP_CHART_DAY_COLOR);
			}
			else if (event.partName == "mainChart")
			{
				var chart:ScrubChart = ScrubChart(event.target);
				//			chart.removeDefaultSeries();

				var vitalSignKey:String = chart.getStyle("vitalSignKey");

				var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
				verticalAxis.minimum = STRIP_CHART_VERTICAL_AXIS_MINIMUM;
				verticalAxis.maximum = STRIP_CHART_VERTICAL_AXIS_MAXIMUM;

				chart.removeDefaultSeries();
				// TODO: get the equipment name to use for the adherence items code
				var scheduleItemName:String = "FORA D40b";
				addAdherenceSeries(chart, scheduleItemName);

				var mainCanvas:DataDrawingCanvas = chart.mainChart.backgroundElements[0] as DataDrawingCanvas;
				if (mainCanvas)
				{
					updateAdherenceStripChartSeriesCompleteHandler(chart, mainCanvas,
							mainCanvas ? mainCanvas.getChildAt(0) as Label : null, null, scheduleItemName,
							model.record.equipmentScheduleItemsModel.equipmentScheduleItemCollection);
					mainCanvas.invalidateSize();
				}

				var index:int = _chartsWithPendingCreationComplete.getItemIndex(chart);
				if (index != -1)
				{
					_chartsWithPendingCreationComplete.removeItemAt(index);
					checkReadyToSynchronizeDateLimits();
				}

				chart.mainChart.dataTipFunction = adherenceChart_dataTipFunction;
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					verticalAxis = chart.rangeChart.verticalAxis as LinearAxis;
					verticalAxis.minimum = STRIP_CHART_VERTICAL_AXIS_MINIMUM;
					verticalAxis.maximum = STRIP_CHART_VERTICAL_AXIS_MAXIMUM;
				}
			}
		}

		protected function medicationAdherenceStripChart_creationCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				trace("medicationAdherenceStripChart_creationCompleteHandler");
		}

		private function adherenceChart_dataTipFunction(hitData:HitData):String
		{
			var adherenceItem:AdherenceItem = hitData.item as AdherenceItem;
			if (adherenceItem)
			{
				return "Medication " + (adherenceItem.adherence ? "<b>Taken</b>" : "<b>Not</b> Taken") + "<br/>" +
						"Date reported: " + adherenceItem.dateReported.toLocaleString();
			}

			var sample:MedicationConcentrationSample = hitData.item as MedicationConcentrationSample;
			if (sample)
			{
				return "Medication concentration " + sample.concentration.toFixed(2) + "<br/>" +
						"Date: " + sample.date.toLocaleString();
			}

			var vitalSign:VitalSign = hitData.item as VitalSign;
			if (vitalSign)
			{
				return vitalSign.name.text + " " + vitalSign.resultAsNumber.toFixed(2) + "<br/>" +
						"Date: " + vitalSign.dateMeasuredStart.toLocaleString();
			}

			return hitData.item.toString();
		}

		private function updateMedicationChartSeries(chart:ScrubChart, medicationCode:String, ndcCode:String):void
		{
			chart.removeDefaultSeries();
			addConcentrationSeries(chart, medicationCode, ndcCode);
			addAdherenceSeries(chart, medicationCode);
		}

		private function addConcentrationSeries(chart:ScrubChart, medicationCode:String, ndcCode:String):void
		{
			var concentrationSeries:AreaSeries = new AreaSeries();
			concentrationSeries.name = "concentration";
			concentrationSeries.id = chart.id + "_concentrationSeries";
			concentrationSeries.xField = "date";
			concentrationSeries.yField = "concentration";
			concentrationSeries.dataProvider = model.medicationConcentrationCurvesByCode.getItem(medicationCode);
//			concentrationSeries.dataProvider = chart.mainData;
			concentrationSeries.setStyle("radius", 2.5);
			concentrationSeries.setStyle("form", "curve");
			concentrationSeries.setStyle("itemRenderer", new ClassFactory(LineSeriesCustomRenderer));
			_seriesWithPendingUpdateComplete.addItem(concentrationSeries);
			concentrationSeries.addEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler);
			concentrationSeries.filterDataValues = "none";
			var color:uint = getMedicationColor(ndcCode);
			concentrationSeries.setStyle("areaStroke", new SolidColorStroke(0x000000, 1));
			concentrationSeries.setStyle("areaFill", new SolidColor(color, 1));

			chart.mainChart.series.push(concentrationSeries);
			chart.addDataSet(model.medicationConcentrationCurvesByCode.getItem(medicationCode), "date");
			addSeriesSet(chart, concentrationSeries);
		}

		private function addVitalSignSeries(chart:ScrubChart, vitalSignKey:String):void
		{
			var vitalSignSeries:PlotSeries = new PlotSeries();
			vitalSignSeries.name = "vitalSignPrimary";
			vitalSignSeries.id = chart.id + "_primarySeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			vitalSignSeries.dataProvider = model.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignKey);
//			vitalSignSeries.dataProvider = chart.mainData;
			vitalSignSeries.setStyle("radius", 2.5);
//			vitalSignSeries.setStyle("form", "curve");
//			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(LineSeriesCustomRenderer));
			_seriesWithPendingUpdateComplete.addItem(vitalSignSeries);
			vitalSignSeries.addEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler);
			vitalSignSeries.filterDataValues = "none";
//			var color:uint = getVitalSignColor(vitalSignKey);
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(0x000000, 2));

			chart.mainChart.series.push(vitalSignSeries);
			chart.addDataSet(model.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignKey), "dateMeasuredStart");
			addSeriesSet(chart, vitalSignSeries);
		}

		protected function addCustomSeries(series:Series):void
		{
			_seriesWithPendingUpdateComplete.addItem(series);
		}

		protected function addCustomSeriesSet(seriesSet:ScrubChartSeriesSet):void
		{
			seriesSets.push(seriesSet);
		}

		protected function series_updateCompleteHandler(event:FlexEvent):void
		{
			var series:Series = event.target as Series;
			series.removeEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler, false);
			checkAllSeriesComplete(series);
		}

		private function addAdherenceSeries(chart:ScrubChart, adherenceItemsCode:String):void
		{
			var adherenceSeries:PlotSeries = new PlotSeries();
			adherenceSeries.name = "adherence";
			adherenceSeries.id = chart.id + "_adherenceSeries";
			adherenceSeries.xField = "dateReported";
//			TODO: position the adherence series without the hack of using adherencePosition
			adherenceSeries.yField = "adherencePosition";
			adherenceSeries.dataProvider = model.adherenceItemsCollectionsByCode.getItem(adherenceItemsCode);
			adherenceSeries.setStyle("itemRenderer", new ClassFactory(AdherencePlotItemRenderer));
//			adherenceSeries.filterFunction = adherenceSeriesFilter;
			_seriesWithPendingUpdateComplete.addItem(adherenceSeries);
			adherenceSeries.addEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler);

			chart.mainChart.series.push(adherenceSeries);
			chart.addDataSet(model.adherenceItemsCollectionsByCode.getItem(adherenceItemsCode), "dateReported");

			addSeriesSet(chart, adherenceSeries);
		}

		private function getMedicationFill(medicationCode:String):MedicationFill
		{
			var medicationFill:MedicationFill;
			var adherenceItemsCollection:ArrayCollection = model.adherenceItemsCollectionsByCode.getItem(medicationCode);
			medicationFill = null;
			if (adherenceItemsCollection)
			{
				for each (var adherenceItem:AdherenceItem in adherenceItemsCollection)
				{
					var medicationScheduleItem:MedicationScheduleItem = adherenceItem.scheduleItem as MedicationScheduleItem;
					if (medicationScheduleItem)
					{
						if (medicationScheduleItem.scheduledMedicationOrder)
						{
							medicationFill = medicationScheduleItem.scheduledMedicationOrder.medicationFill;
							break;
						}
					}
				}
			}
			if (medicationFill == null)
			{
				for each (var currentMedicationFill:MedicationFill in model.record.medicationFillsModel.documents)
				{
					if (currentMedicationFill.name.value == medicationCode)
					{
						medicationFill = currentMedicationFill;
						break;
					}
				}
			}
			return medicationFill;
		}

		private function addSeries(chart:CartesianChart, series:Series):void
		{
			var data:ArrayCollection = series.dataProvider as ArrayCollection;
			if (data && data.length > 0)
				chart.series.push(series);
		}

		public function refresh():void
		{
			if (this)
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

		protected function creationCompleteHandler(event:FlexEvent):void
		{
			updateSeries();
			refresh();
			updateRangeChartVisibleStyles();
		}

		public function drawConcentrationGoalRegion(canvas:DataDrawingCanvas, zoneLabel:Label, medicationCode:String, ndcCode:String):void
		{
			if (_traceEventHandlers)
				trace(this + ".drawConcentrationGoalRegion");

			canvas.clear();

			var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);
			var color:uint = getMedicationColor(ndcCode);
			canvas.lineStyle(1, color);

			canvas.beginFill(color, 0.25);
			canvas.drawRect([Edge.LEFT, -1], medicationModel.goalConcentrationMinimum, [Edge.RIGHT, 1],
					medicationModel.goalConcentrationMaximum);
			canvas.endFill();

			if (zoneLabel)
			{
				zoneLabel.setStyle("color", color);
				canvas.updateDataChild(zoneLabel, {left:Edge.LEFT, top:medicationModel.goalConcentrationMaximum});
			}
		}

		public function drawVitalSignGoalRegion(canvas:DataDrawingCanvas, zoneLabel:Label, vitalSignKey:String):void
		{
			if (_traceEventHandlers)
				trace(this + ".drawVitalSignGoalRegion");

			canvas.clear();

//			var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);
			var color:uint = getVitalSignColor(vitalSignKey);
			canvas.lineStyle(1, color);

			canvas.beginFill(color, 0.25);
			canvas.drawRect([Edge.LEFT, -1], 40, [Edge.RIGHT, 1],
					120);
			canvas.endFill();

			if (zoneLabel)
			{
				zoneLabel.setStyle("color", color);
				canvas.updateDataChild(zoneLabel, {left:Edge.LEFT, top:200});
			}
		}

		private function getVitalSignColor(vitalSignKey:String):uint
		{
			// TODO: implement a better system for coloring the vital sign charts
			return 0x4444FF;
		}

		public function drawAdherenceStripRegions(canvas:DataDrawingCanvas, zoneLabel:Label, scheduleItemName:String, scheduleItemCollection:ArrayCollection):void
		{
			if (_traceEventHandlers)
				trace(this + ".drawAdherenceStripRegions");

			var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();
			var firstDateStart:Date;
			var lastDateEnd:Date;

			for each (var scheduleItem:ScheduleItemBase in scheduleItemCollection)
			{
				if (scheduleItemMatches(scheduleItem, scheduleItemName))
				{
					var newScheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = scheduleItem.getScheduleItemOccurrences();
					scheduleItemOccurrences = scheduleItemOccurrences.concat(newScheduleItemOccurrences);
					if (firstDateStart == null || newScheduleItemOccurrences[0].dateStart.time < firstDateStart.time)
						firstDateStart = newScheduleItemOccurrences[0].dateStart;
					if (lastDateEnd == null || newScheduleItemOccurrences[newScheduleItemOccurrences.length - 1].dateEnd.time > lastDateEnd.time)
						lastDateEnd = newScheduleItemOccurrences[newScheduleItemOccurrences.length - 1].dateEnd;
				}
			}

			canvas.clear();

			canvas.beginFill(STRIP_CHART_NIGHT_COLOR);

			if (firstDateStart != null)
			{
				var currentNightStart:Date = new Date();
				currentNightStart.setTime(firstDateStart.time - 1000 * 60 * 60 * 24);
				currentNightStart.setHours(18, 0, 0, 0);
				var currentNightEnd:Date;
				do
				{
					currentNightEnd = new Date();
					currentNightEnd.setTime(currentNightStart.time + 1000 * 60 * 60 * 12);
					// Because of daylight savings, 6am might not be 12 hours after 6pm, so adjust
					currentNightEnd.setHours(6, 0, 0, 0);

					canvas.drawRect(currentNightStart, [Edge.TOP, -1],
							currentNightEnd, [Edge.BOTTOM, 1]);

					// advance night start to 6pm on the next day
					var nextNightStartTime:Number = currentNightStart.time + 1000 * 60 * 60 * 24;
					currentNightStart = new Date();
					currentNightStart.setTime(nextNightStartTime);
					// Because of daylight savings, 6am might not be 12 hours after 6pm, so adjust
					currentNightStart.setHours(18, 0, 0, 0);
				}
				while (currentNightStart.time < lastDateEnd.time);
			}

			canvas.endFill();

			canvas.beginFill(0xFFFFFF);

			for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
			{
				canvas.drawRect(scheduleItemOccurrence.dateStart, [Edge.TOP, -1],
						scheduleItemOccurrence.dateEnd, [Edge.BOTTOM, 1]);
			}

			canvas.endFill();

			if (zoneLabel)
			{
				canvas.updateDataChild(zoneLabel, {left:Edge.LEFT, top:Edge.TOP});
			}
		}

		private function scheduleItemMatches(scheduleItem:ScheduleItemBase, scheduleItemName:String):Boolean
		{
			if (StringUtils.isEmpty(scheduleItem.name.value))
			{
				return scheduleItem.name.text == scheduleItemName;
			}
			else
			{
				return scheduleItem.name.value == scheduleItemName;
			}
		}

		public function drawAdherenceData2(chart:CartesianChart, canvas:CartesianDataCanvas, zoneLabel:Label, medicationCode:String, ndcCode:String):void
		{
			if (_traceEventHandlers)
				trace(this + ".drawAdherenceData2");

			canvas.clear();

			var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);
			var color:uint = getMedicationColor(ndcCode);
//			canvas.lineStyle(1, color, 0.5);

			canvas.beginFill(color, 0.25);
			canvas.drawRect(new Date(1970), medicationModel.goalConcentrationMinimum,
					model.currentDateSource.now(),
					medicationModel.goalConcentrationMaximum / 2);
			canvas.endFill();

			if (zoneLabel)
			{
				zoneLabel.setStyle("color", color);
				canvas.updateDataChild(zoneLabel, {left:Edge.LEFT, top:medicationModel.goalConcentrationMaximum});
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

		private function synchronizeDateLimits():void
		{
			var charts:Vector.<TouchScrollingScrubChart> = _visibleCharts;

			var minimum:Number;
			var maximum:Number;
			var today:Date = model.currentDateSource.now();
			for each (var chart:TouchScrollingScrubChart in charts)
			{
				chart.commitPendingDataChanges();
				if (isNaN(minimum))
					minimum = chart.minimumDataTime;
				else
					minimum = Math.min(minimum, chart.minimumDataTime);

				if (isNaN(maximum))
					maximum = chart.maximumDataTime;
				else
					maximum = Math.max(maximum, chart.maximumDataTime);
			}

			if (!isNaN(minimum) && !isNaN(maximum))
			{
				for each (chart in charts)
				{
					chart.today = today;
					chart.minimumTime = minimum;
					chart.maximumTime = maximum;
					if (chart.allSeriesUpdated())
					{
						// first time initialization complete; nothing else to do
					}
					else //if (chart.focusTime == chart.rightRangeTime == chart.maximumTime)
					{
						chart.rightRangeTime = maximum;
						chart.leftRangeTime = Math.max(minimum, maximum - initialDurationTime);
						chart.updateForScroll();
						chart.focusTime = maximum;
					}
				}
			}

			if (_traceEventHandlers)
				trace("synchronizeDateLimits minimum " + ScrubChart.traceDate(minimum) + " maximum " + ScrubChart.traceDate(maximum));
		}

		protected function updateSeries():void
		{
			for each (var seriesSet:ScrubChartSeriesSet in seriesSets)
			{
				seriesSet.chart.series = new Array();
				for each (var series:Series in seriesSet.series)
				{
					addSeries(seriesSet.chart, series);
				}
			}
		}

		protected function adherenceChart_initializeHandler(event:FlexEvent):void
		{
			// TODO Auto-generated method stub
			if (_traceEventHandlers)
				trace("adherenceChart_initializeHandler");
		}

		protected function heartRateChart_creationCompleteHandler(event:FlexEvent):void
		{
			var chart:ScrubChart = ScrubChart(event.target);

			var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = 50;
			verticalAxis.maximum = 100;
		}

		private function updateAdherenceChartSeriesCompleteHandler(chart:ScrubChart, mainCanvas:DataDrawingCanvas, zoneLabel:Label, rangeCanvas:DataDrawingCanvas, medicationCode:String, ndcCode:String):void
		{
			drawConcentrationGoalRegion(mainCanvas, zoneLabel, medicationCode, ndcCode);
			callLater(
					function ():void
					{
						mainCanvas.invalidateDisplayList();
					}
			);

			if (chart.rangeChart)
			{
				chart.rangeChart.backgroundElements.push(rangeCanvas);
				drawConcentrationGoalRegion(rangeCanvas, null, medicationCode, ndcCode);
			}
		}

		private function updateVitalSignAdherenceChartSeriesCompleteHandler(chart:ScrubChart, mainCanvas:DataDrawingCanvas, zoneLabel:Label, rangeCanvas:DataDrawingCanvas, vitalSignKey:String):void
		{
			drawVitalSignGoalRegion(mainCanvas, zoneLabel, vitalSignKey);
			callLater(
					function ():void
					{
						mainCanvas.invalidateDisplayList();
					}
			);

			if (chart.rangeChart)
			{
				chart.rangeChart.backgroundElements.push(rangeCanvas);
				drawVitalSignGoalRegion(rangeCanvas, null, vitalSignKey);
			}
		}

		private function updateAdherenceStripChartSeriesCompleteHandler(chart:ScrubChart, mainCanvas:DataDrawingCanvas, zoneLabel:Label, rangeCanvas:DataDrawingCanvas, scheduleItemName:String, scheduleItemCollection:ArrayCollection):void
		{
			drawAdherenceStripRegions(mainCanvas, zoneLabel, scheduleItemName, scheduleItemCollection);
			callLater(
					function ():void
					{
						mainCanvas.invalidateDisplayList();
					}
			);

			if (chart.rangeChart)
			{
				chart.rangeChart.backgroundElements.push(rangeCanvas);
				drawAdherenceStripRegions(rangeCanvas, null, scheduleItemName, scheduleItemCollection);
			}
		}

		private function checkAllSeriesComplete(series:Series):void
		{
			if (_seriesWithPendingUpdateComplete.contains(series))
			{
				_seriesWithPendingUpdateComplete.removeItemAt(_seriesWithPendingUpdateComplete.getItemIndex(series));
				checkReadyToSynchronizeDateLimits();
			}
		}

		protected override function keyDownHandler(event:KeyboardEvent):void
		{
			if (event.altKey && event.ctrlKey && event.keyCode == Keyboard.F)
			{
				model.showFps = !model.showFps;
			}
			else if (event.altKey && event.ctrlKey && !event.shiftKey)
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
					case Keyboard.R:
					{
						rangeChartVisible = !rangeChartVisible;
						break;
					}
					case Keyboard.H:
					{
						scrollEnabled = !scrollEnabled;
						break;
					}
					case Keyboard.T:
					{
						_traceEventHandlers = !_traceEventHandlers;
						trace("_traceEventHandlers " + _traceEventHandlers);
						break;
					}
					case Keyboard.A:
					{
						shouldApplyChangesToSimulation = !shouldApplyChangesToSimulation;
						break;
					}
					case Keyboard.L:
					{
						useSliceMainData = !useSliceMainData;
						break;
					}
					case Keyboard.U:
					{
						skipUpdateSimulation = !skipUpdateSimulation;
						break;
					}
				}
			}
		}

		public function runScrollingBenchmark():void
		{
			_benchmarkFrameCount = 0;

			var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();
			var visibleCharts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
			for each (var chart:TouchScrollingScrubChart in allCharts)
			{
				if (chart.visible)
					visibleCharts.push(chart);
			}
			setSingleChartMode(visibleCharts[0], false);

			visibleCharts = getVisibleCharts(allCharts, null, _singleChartMode, model.showAdherence
			);

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

			var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();
			individualChartsQueue = getVisibleCharts(allCharts, null, _singleChartMode, model.showAdherence
			);

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

				traceAndLog("======= Benchmark Results ========");

				//					trace("  Overall:        ", completeTrial.fps.toFixed(2));
				//					trace("  Synchronized:   ", synchronizedTrial.fps.toFixed(2));
				//					trace("  Adherence:      ", adherenceTrial.fps.toFixed(2));
				//					trace("  Blood Pressure: ", bloodPressureTrial.fps.toFixed(2));
				//					trace("  Heart Rate:     ", heartRateTrial.fps.toFixed(2));

				for each (var trial:BenchmarkTrial in individualTrials)
				{
					traceAndLog("  " + StringUtils.padRight(trial.name + ":", " ",
							20) + " " + trial.fps.toFixed(2));
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

		private function doScrollTest(chart:TouchScrollingScrubChart, screensToScroll:Number, timeToScroll:Number, effectEndHandler:Function):void
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

		protected function chart_doubleClickHandler(event:MouseEvent):void
		{
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);

			setSingleChartMode(targetChart, !_singleChartMode);
		}

		protected function setSingleChartMode(targetChart:TouchScrollingScrubChart, mode:Boolean):void
		{
			_singleChartMode = mode;

			_scrollTargetChart = null;
			updateChartsCache(targetChart);

			var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();
			for (var i:int = 0; i < _visibleCharts.length; i++)
			{
				var chart:TouchScrollingScrubChart = _visibleCharts[i] as TouchScrollingScrubChart;

				// middle chart
				chart.setStyle("headerVisible", false);
				chart.setStyle("footerVisible", false);
				chart.setStyle("sliderVisible", false);
				chart.setStyle("rangeChartVisible", rangeChartVisible);

				if (i == 0)
				{
					// top chart
//					chart.setStyle("topBorderVisible", true);
				}

				// TODO: the order of the charts in _charts is currently inconsistent with the order the charts are in visually
				if (i == _visibleCharts.length - 1)
				{
					// bottom chart
					chart.setStyle("footerVisible", chartFooterVisible);
				}
			}

			for each (chart in allCharts)
			{
				var visible:Boolean = _visibleCharts.indexOf(chart) != -1;
				chart.visible = visible;
				chart.includeInLayout = visible;
			}

			if (_visibleCharts.length > 1 && targetChart != null)
			{
				var nonTargetCharts:Vector.<TouchScrollingScrubChart> = getVisibleNonTargetCharts(_visibleCharts,
						targetChart);
				synchronizeScrollPositions(targetChart, nonTargetCharts);
				synchronizeFocusTimes(targetChart, nonTargetCharts);
			}
		}

		protected function getAllCharts():Vector.<TouchScrollingScrubChart>
		{
//			var allCharts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
//			for each (var chart:TouchScrollingScrubChart in _adherenceCharts.values())
//			{
//				allCharts.push(chart);
//			}
//			if (bloodPressureChart)
//			{
//				allCharts.push(bloodPressureChart);
//			}
//			return allCharts;
//			return _charts;
			var allCharts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
			for each (var chart:TouchScrollingScrubChart in _adherenceCharts.values())
			{
				allCharts.push(chart);
			}
			allCharts = allCharts.concat(_customCharts);
			return allCharts;
		}

		protected function getVisibleCharts(allCharts:Vector.<TouchScrollingScrubChart>, targetChart:TouchScrollingScrubChart, singleChartMode:Boolean, showAdherence:Boolean):Vector.<TouchScrollingScrubChart>
		{
			var visibleCharts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
			for each (var chart:TouchScrollingScrubChart in allCharts)
			{
				if (singleChartMode)
				{
					if (chart == targetChart)
						visibleCharts.push(chart);
				}
				else if (isAdherenceChart(chart))
				{
					if (showAdherence)
						visibleCharts.push(chart);
				}
				else
				{
					visibleCharts.push(chart);
				}
			}
			return visibleCharts;
		}

		protected function isAdherenceChart(chart:TouchScrollingScrubChart):Boolean
		{
			return _adherenceCharts.values().indexOf(chart) != -1;
		}

		protected function getVisibleNonTargetCharts(visibleCharts:Vector.<TouchScrollingScrubChart>, targetChart:TouchScrollingScrubChart):Vector.<TouchScrollingScrubChart>
		{
			var visibleNonTargetCharts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
			for each (var chart:TouchScrollingScrubChart in visibleCharts)
			{
				if (chart != targetChart)
				{
					visibleNonTargetCharts.push(chart);
				}
			}
			return visibleNonTargetCharts;
		}

		protected function chart_scrollHandler(event:ScrollEvent):void
		{
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);
			updateChartsCache(targetChart);

			if (!_singleChartMode)
			{
				synchronizeScrollPositions(targetChart, _nonTargetCharts);
			}

			queueUpdateSimulation(targetChart);
		}

		protected function synchronizeScrollPositions(targetChart:TouchScrollingScrubChart, otherCharts:Vector.<TouchScrollingScrubChart>):void
		{
			for each (var otherChart:TouchScrollingScrubChart in otherCharts)
			{
				if (otherChart.visible)
				{
					otherChart.synchronizeScrollPosition(targetChart);
				}
			}
		}

		protected function synchronizeFocusTimes(targetChart:TouchScrollingScrubChart, otherCharts:Vector.<TouchScrollingScrubChart>):void
		{
			for each (var otherChart:TouchScrollingScrubChart in otherCharts)
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
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);

			if (_traceEventHandlers)
				trace(this.id + ".chart_scrollStartHandler " + targetChart.id);
		}

		protected function chart_scrollStopHandler(event:TouchScrollerEvent):void
		{
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);

			if (_traceEventHandlers)
				trace(this.id + ".chart_scrollStopHandler " + targetChart.id);

			updateChartsAfterScrollStop();
		}

		private function updateChartsAfterScrollStop():void
		{
			var charts:Vector.<TouchScrollingScrubChart> = _visibleCharts;
			for each (var chart:TouchScrollingScrubChart in charts)
			{
				chart.resetAfterQuickScroll();
			}
		}

		protected function chart_focusTimeChangeHandler(event:FocusTimeEvent):void
		{
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);

			updateChartsCache(targetChart);

			if (!_singleChartMode)
			{
				synchronizeFocusTimes(targetChart, _nonTargetCharts);
			}

			queueUpdateSimulation(targetChart);
		}

		private function queueUpdateSimulation(targetChart:TouchScrollingScrubChart):void
		{
			_pendingUpdateSimulation = targetChart;
			invalidateProperties();
		}

		private function updateChartsCache(targetChart:TouchScrollingScrubChart):void
		{
			if (targetChart == null || _scrollTargetChart != targetChart)
			{
				var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();
				_visibleCharts = getVisibleCharts(allCharts, targetChart, _singleChartMode, model.showAdherence
				);
				_nonTargetCharts = getVisibleNonTargetCharts(_visibleCharts, targetChart);
				_scrollTargetChart = targetChart;
			}
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if (_pendingSynchronizeDateLimits)
			{
				synchronizeDateLimits();
				_pendingSynchronizeDateLimits = false;
			}
			if (_pendingUpdateSimulation)
			{
				updateSimulation(_pendingUpdateSimulation);
				_pendingUpdateSimulation = null;
			}
		}

		private function updateSimulation(targetChart:TouchScrollingScrubChart):void
		{
			if (skipUpdateSimulation)
				return;

//			if (shouldApplyChangesToSimulation)
			model.focusSimulation.date = new Date(targetChart.focusTime);
			var dataIndexMessage:String = updateSimulationForCustomCharts();
			var medicationUpdateDescriptions:Array = new Array();
			if (model.isAdherenceLoaded)
			{
				for each (var medicationCode:String in model.medicationConcentrationCurvesByCode.keys)
				{
					medicationUpdateDescriptions.push(updateSimulationMedicationModel(medicationCode));
				}
			}

			if (shouldApplyChangesToSimulation && targetChart.isFocusOnMaximumTime)
			{
				model.focusSimulation.mode = SimulationModel.MOST_RECENT_MODE;
			}
			else
			{
				model.focusSimulation.mode = SimulationModel.HISTORY_MODE;
			}

			if (_traceEventHandlers)
				trace("updateSimulation " + targetChart.id + " focusTime " +
						ScrubChart.traceDate(model.focusSimulation.date.time) + " dateMeasuredStart " +
						(model.focusSimulation.dataPointDate ? ScrubChart.traceDate(model.focusSimulation.dataPointDate.time) : "(unavailable)") +
						" systolic " +
						model.focusSimulation.systolic + dataIndexMessage +
						" [" + medicationUpdateDescriptions.join(", ") + "]");
		}

		protected function updateSimulationForCustomCharts():String
		{
			return null;
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

		private function traceAndLog(message:String):void
		{
			trace(message);
			_logger.info(message);
		}

		private function updateRangeChartVisibleStyles():void
		{
			for each (var chart:ScrubChart in getAllCharts())
			{
				chart.setStyle("rangeChartVisible", rangeChartVisible);
			}
		}


		override protected function createChildren():void
		{
			super.createChildren();
			initializeSeriesSets();
			_createChildrenComplete = true;
			respondToModelUpdate();
		}

		protected function initializeSeriesSets():void
		{
			
		}
		
		[Bindable]
		public function get useHorizontalTouchScrolling():Boolean
		{
			return _useHorizontalTouchScrolling;
		}

		public function set useHorizontalTouchScrolling(value:Boolean):void
		{
			_useHorizontalTouchScrolling = value;
		}

		private function getMedicationColor(ndcCode:String):uint
		{
			var color:uint;
			if (_medicationColorSource)
				color = _medicationColorSource.getMedicationColor(ndcCode);

			if (color == 0)
				color = 0x4252A4;

			return color;
		}

		public function get modality():String
		{
			return _modality;
		}

		public function set modality(value:String):void
		{
			_modality = value;
		}

		public function updateSimulationMedicationModel(medicationCode:String):String
		{
			var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);

			if (medicationModel == null)
			{
				trace("Warning: No medication found in the model.simulation for key " + medicationCode + ". This will happen if there are no MedicationAdministration documents in the record for this medication.");
				return medicationCode + " not found";
			}
			else
			{
				var currentAdherenceChart:ScrubChart = _adherenceCharts.getValueByKey(getConcentrationChartKey(medicationCode));

				var concentrationDataPoint:MedicationConcentrationSample;
				if (currentAdherenceChart)
				{
					var series:Series = currentAdherenceChart.mainChart.series[0];
					var chartItem:ChartItem = null;
					if (series)
					{
						var dataCollection:ArrayCollection = series.dataProvider as ArrayCollection;
						var concentrationDataIndex:int = currentAdherenceChart.findPreviousDataIndex(dataCollection,
								model.focusSimulation.date.time);
						if (concentrationDataIndex != -1)
						{
							concentrationDataPoint = dataCollection.getItemAt(concentrationDataIndex) as MedicationConcentrationSample;
							series.selectedIndex = concentrationDataIndex;
							if (series.items)
							{
								chartItem = series.items[concentrationDataIndex] as ChartItem;
							}
						}
					}
					if (chartItem)
						currentAdherenceChart.highlightChartItem(chartItem);
					else
						currentAdherenceChart.hideDataPointHighlight();
				}

				// TODO: show the date for the concentration data point
				var concentration:Number = concentrationDataPoint == null ? 0 : concentrationDataPoint.concentration;

				if (shouldApplyChangesToSimulation)
				{
					medicationModel.concentration = concentration;
				}
				return medicationCode + "=" + concentration.toFixed(2) + (concentrationDataPoint ? (" " + ScrubChart.traceDate(concentrationDataPoint.date.time) + " (" + (concentrationDataIndex + 1) + " of " + dataCollection.length + ")") : ("(data unavailable)"));
			}
		}

		private function chartsGroup_resizeHandler(event:ResizeEvent):void
		{
//			resizeFocusTimeMarker();
		}

		private function checkReadyToSynchronizeDateLimits():void
		{
			if (_seriesWithPendingUpdateComplete.length == 0 && _chartsWithPendingCreationComplete.length == 0)
				queueSynchronizeDateLimits();
		}

		public function get useSliceMainData():Boolean
		{
			return _useSliceMainData;
		}

		public function set useSliceMainData(value:Boolean):void
		{
			_useSliceMainData = value;
			for each (var chart:TouchScrollingScrubChart in getAllCharts())
			{
				chart.useSliceMainData = useSliceMainData;
			}
			trace("useSliceMainData", useSliceMainData);
		}

		public function get shouldApplyChangesToSimulation():Boolean
		{
			return _shouldApplyChangesToSimulation;
		}

		public function set shouldApplyChangesToSimulation(value:Boolean):void
		{
			_shouldApplyChangesToSimulation = value;
			trace("shouldApplyChangesToSimulation", shouldApplyChangesToSimulation);
		}

		private function addSeriesSet(chart:ScrubChart, series:Series):void
		{
			if (chart == null)
				throw new ArgumentError("chart must not be null");
			if (chart.mainChart == null)
				throw new ArgumentError("chart.mainChart must not be null");

			var seriesSet:ScrubChartSeriesSet;
			seriesSet = new ScrubChartSeriesSet();
			seriesSet.chart = chart.mainChart;
			seriesSet.series.push(series);
			seriesSets.push(seriesSet);
		}

		private function respondToModelUpdate():void
		{
			_seriesWithPendingUpdateComplete.removeAll();

			if (model.isInitialized)
				initializeSeriesSets();

			if (model.isInitialized && model.showAdherence)
			{
				createAdherenceCharts();
				updateSeries();
			}

			setSingleChartMode(null, false);
		}

		public function get skipUpdateSimulation():Boolean
		{
			return _skipUpdateSimulation;
		}

		public function set skipUpdateSimulation(value:Boolean):void
		{
			_skipUpdateSimulation = value;
		}

		protected function removeItem(categories:ArrayCollection, item:String):void
		{
			var itemIndex:int = categories.getItemIndex(item);
			if (itemIndex != -1)
				categories.removeItemAt(itemIndex);
		}

		//		mx_internal override function $invalidateDisplayList():void
		//		{
		//			super.mx_internal::$invalidateDisplayList();
		//		}

	}
}
