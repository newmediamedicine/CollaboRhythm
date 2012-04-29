package collaboRhythm.shared.ui.healthCharts.view
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.apps.healthCharts.model.MedicationComponentAdherenceModel;
	import collaboRhythm.shared.apps.healthCharts.model.SimulationModel;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.derived.MedicationConcentrationSample;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.IMedicationColorSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.ui.healthCharts.model.AdherenceStripItemProxy;
	import collaboRhythm.shared.ui.healthCharts.model.ChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.HorizontalAxisChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.DefaultChartModifierFactory;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;
	import collaboRhythm.view.scroll.TouchScrollerEvent;

	import com.dougmccune.controls.ChartFooter;
	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.dougmccune.controls.SynchronizedAxisCache;
	import com.dougmccune.controls.TouchScrollingScrubChart;
	import com.dougmccune.events.FocusTimeEvent;
	import com.theory9.data.types.OrderedMap;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;

	import mx.charts.ChartItem;
	import mx.charts.HitData;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.IAxisRenderer;
	import mx.charts.chartClasses.Series;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.HRule;
	import mx.core.ClassFactory;
	import mx.core.FlexGlobals;
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
	import mx.styles.CSSStyleDeclaration;

	import qs.charts.dataShapes.DataDrawingCanvas;
	import qs.charts.dataShapes.Edge;

	import spark.components.BorderContainer;

	import spark.components.BorderContainer;

	import spark.components.Button;
	import spark.components.CalloutButton;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.components.View;
	import spark.components.ViewNavigator;
	import spark.effects.Animate;
	import spark.effects.animation.MotionPath;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.Linear;
	import spark.events.SkinPartEvent;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.layouts.VerticalLayout;
	import spark.primitives.BitmapImage;
	import spark.primitives.Line;
	import spark.primitives.Rect;
	import spark.skins.mobile.ButtonSkin;
	import spark.skins.mobile.CalloutSkin;
	import spark.skins.mobile.TransparentActionButtonSkin;
	import spark.skins.mobile.TransparentNavigationButtonSkin;
	import spark.skins.spark.BorderContainerSkin;

	public class SynchronizedHealthCharts extends Group implements IFocusManagerComponent
	{
		public static const ADHERENCE_STRIP_CHART_HEIGHT:int = 40;

		private static const STRIP_CHART_VERTICAL_AXIS_MINIMUM:Number = -0.5;
		private static const STRIP_CHART_VERTICAL_AXIS_MAXIMUM:Number = 0.5;

		private static const STRIP_CHART_DAY_COLOR:int = 0xD6D6D6;
		private static const STRIP_CHART_NIGHT_COLOR:int = 0xBFBEBE;

		private static const HORIZONTAL_AXIS_CHART_KEY:String = "horizontalAxisChart";

		private static const SPARK_COMPONENTS_CALLOUT_SELECTOR:String = "spark.components.Callout";

		private var _textFormat:TextFormat = new TextFormat("Myriad Pro, Verdana, Helvetica, Arial", 16, 0, true);

		private var _model:HealthChartsModel;
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

		private var _seriesSets:Vector.<ScrubChartSeriesSet> = new Vector.<ScrubChartSeriesSet>();
		private var _seriesWithPendingUpdateComplete:ArrayCollection = new ArrayCollection();
		private var _chartsWithPendingMainChartAdded:ArrayCollection = new ArrayCollection();
		private var _pendingSynchronizeDateLimits:Boolean;
		private var _useSliceMainData:Boolean;

		private const benchmarkTrialDuration:Number = 2000;
		private var _benchmarkFrameCount:int;
		private var _completeTrial:BenchmarkTrial;
		private var _synchronizedTrial:BenchmarkTrial;
		private var _individualTrials:Vector.<BenchmarkTrial>;
		private var _individualChartsQueue:Vector.<TouchScrollingScrubChart>;

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
		protected var _synchronizedAxisCache:SynchronizedAxisCache;
		private var _componentContainer:IComponentContainer;
		private var _chartModifierFactories:Array;
		private var _chartDescriptors:OrderedMap;
		private var _activeAccountId:String;
		private var _chartModifiers:OrderedMap;
		protected var _footer:ChartFooter;
		private var _viewNavigator:ViewNavigator;
		private var _rangeButtonTargetChart:TouchScrollingScrubChart;
		private var _stripChartDataCollections:OrderedMap = new OrderedMap();
		private var _adherenceGroups:OrderedMap = new OrderedMap();
		private var _showAllChartsButton:Button;
		private var _appliedCalloutSkinFix:Boolean;
		private var _pendingUpdateBackgroundElements:Boolean = false;
		private var _shouldRunIndividualBenchmarks:Boolean = false;
		private var _blankBackgrounds:Boolean = false;
		private var _todayHighlight:Rect;
		private var _chartsContainer:VGroup;
		private var _pendingMoveTodayHighlight:Boolean = false;
		private var _useRedrawFix:Boolean = false;

		public function SynchronizedHealthCharts():void
		{
			// TODO: use CSS instead for these
			percentHeight = 100;
			percentWidth = 100;
			clipAndEnableScrolling = true;
			setStyle("fontSize", 20);

			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_medicationColorSource = WorkstationKernel.instance.resolve(IMedicationColorSource) as IMedicationColorSource;
			skipUpdateSimulation = modality == Settings.MODALITY_TABLET;
			showFocusTimeMarker = !skipUpdateSimulation;

			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true);
		}
		
		public function createActionButtons(view:View):void
		{
			if (view && view.actionContent)
			{
				var rangeTodayButton:Button = new Button();
				rangeTodayButton.label = "Today";
				rangeTodayButton.addEventListener(MouseEvent.CLICK, rangeTodayButton_clickHandler, false, 0, true);
				rangeTodayButton.setStyle("skinClass", TransparentActionButtonSkin);
				view.actionContent.unshift(rangeTodayButton);

				_showAllChartsButton = new Button();
				_showAllChartsButton.label = "Show All Charts";
				_showAllChartsButton.addEventListener(MouseEvent.CLICK, showAllChartsButton_clickHandler);
				_showAllChartsButton.setStyle("skinClass", TransparentActionButtonSkin);
				_showAllChartsButton.visible = false;
				_showAllChartsButton.setStyle("skinClass", TransparentActionButtonSkin);
				view.actionContent.unshift(_showAllChartsButton);
			}
		}

		private function rangeTodayButton_clickHandler(event:MouseEvent):void
		{
			if (_rangeButtonTargetChart)
			{
				updateChartsCache(_rangeButtonTargetChart);
				_rangeButtonTargetChart.rangeTodayButton_clickHandler(event);
			}
		}

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
			logDebugEvent("scrollEnabled", scrollEnabled);
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
		public function get model():HealthChartsModel
		{
			return _model;
		}

		public function set model(value:HealthChartsModel):void
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
			if (_traceEventHandlers)
				logDebugEvent("model_changeHandler");

			queueSynchronizeDateLimits();
		}

		private function model_updateCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				logDebugEvent("model_updateCompleteHandler");

			queueSynchronizeDateLimits();
		}

		private function queueMoveTodayHighlight():void
		{
			if (_traceEventHandlers)
				logDebugEvent("queueMoveTodayHighlight");

			_pendingMoveTodayHighlight = true;
			invalidateProperties();
		}

		private function queueSynchronizeDateLimits():void
		{
			if (_traceEventHandlers)
				logDebugEvent("queueSynchronizeDateLimits (and invalidateProperties())");

			_pendingSynchronizeDateLimits = true;
			invalidateProperties();
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			//trace("model_propertyChangeHandler", event.property);
			if ((event.property == "showAdherence" || (event.property == "isInitialized" && event.newValue as Boolean)) && _createChildrenComplete)
			{
				respondToModelUpdate();
			}
		}

		private function createAdherenceCharts():void
		{
			if (!_adherenceChartsCreated)
			{
				_adherenceChartsCreated = true;

				initializeModifierFactories();
				createChartDescriptors();
				createChartModifiers();
				updateChartDescriptors();
				updateAdherenceStripChartDataCollections();
				createChartsContainer();
				createTodayHighlight();
				createChartsFromDescriptors();
				createCustomCharts();
				createHorizontalAxisChart();
				createFooter();
			}
			else
			{
				updateAdherenceStripChartDataCollections();
				updateAdherenceCharts();
			}
		}

		private function updateAdherenceStripChartDataCollections():void
		{
			_stripChartDataCollections = new OrderedMap();
			for each (var chartDescriptor:IChartDescriptor in _chartDescriptors.values())
			{
				var dataCollection:ArrayCollection;
				var scheduleItemCollection:ArrayCollection;
				var medicationChartDescriptor:MedicationChartDescriptor = chartDescriptor as MedicationChartDescriptor;
				if (medicationChartDescriptor)
				{
					scheduleItemCollection = model.record.medicationScheduleItemsModel.medicationScheduleItemCollection;
					dataCollection = createAdherenceStripItemProxies(scheduleItemCollection,
							medicationChartDescriptor.medicationCode, AdherenceStripItemProxy.MEDICATION_TYPE);
				}
				else
				{
					var vitalSignChartDescriptor:VitalSignChartDescriptor = chartDescriptor as VitalSignChartDescriptor;
					if (vitalSignChartDescriptor)
					{
						scheduleItemCollection = model.record.equipmentScheduleItemsModel.equipmentScheduleItemCollection;

						var equipmentScheduleItem:EquipmentScheduleItem = getMatchingEquipmentScheduleItem(vitalSignChartDescriptor.vitalSignCategory);
						if (equipmentScheduleItem)
						{
							var scheduleItemName:String = equipmentScheduleItem.name.text;
							dataCollection = createAdherenceStripItemProxies(scheduleItemCollection, scheduleItemName,
									AdherenceStripItemProxy.EQUIPMENT_TYPE);
						}
					}
				}

				if (dataCollection)
				{
					_stripChartDataCollections.addKeyValue(chartDescriptor.descriptorKey, dataCollection);
				}
			}
		}

		private function getAdherenceStripItemProxies(descriptorKey:String):ArrayCollection
		{
			var dataCollection:ArrayCollection = _stripChartDataCollections.getValueByKey(descriptorKey);
			return dataCollection;
		}

		private function createHorizontalAxisChart():void
		{
			var chart:TouchScrollingScrubChart = createAdherenceChart(HORIZONTAL_AXIS_CHART_KEY, null, false);
			chart.setStyle("skinClass", ScrubChartHorizontalAxisSkin);
			chart.setStyle("footerVisible", false);
			chart.height = 35;

			chart.addEventListener(SkinPartEvent.PART_ADDED, adherenceChart_skinPartAddedHandler, false, 0,
					true);

			var spacer:UIComponent = new UIComponent();
			spacer.width = 100;

			var group:HGroup = createAdherenceGroup(new HorizontalAxisChartDescriptor(), spacer, chart, null);
			group.height = 35;
		}

		private function updateChartDescriptors():void
		{
			for each (var chartModifier:IChartModifier in _chartModifiers.values())
			{
				_chartDescriptors = chartModifier.updateChartDescriptors(_chartDescriptors);
			}
		}

		private function createChartsContainer():void
		{
			_chartsContainer = new VGroup();

			_chartsContainer.percentHeight = 100;
			_chartsContainer.percentWidth = 100;
			_chartsContainer.gap = 10;
			_chartsContainer.paddingLeft = 0;
			_chartsContainer.paddingRight = 10;
			_chartsContainer.paddingTop = 10;
			_chartsContainer.paddingBottom = 0;
			this.addElement(_chartsContainer);
		}

		private function createTodayHighlight():void
		{
			_todayHighlight = new Rect();
			_todayHighlight.top = _chartsContainer.paddingTop;
			_todayHighlight.bottom = _chartsContainer.paddingBottom;
			moveTodayHighlight();
			_todayHighlight.fill = new SolidColor(0xFBB040, 0.3);
//			_todayHighlight.includeInLayout = false;
			this.addElementAt(_todayHighlight, 0);
		}

		private function moveTodayHighlight():void
		{
			if (_traceEventHandlers)
				logDebugEvent("moveTodayHighlight");

			var horizontalAxisChart:TouchScrollingScrubChart = _adherenceCharts.getValueByKey(HORIZONTAL_AXIS_CHART_KEY);
			if (horizontalAxisChart)
			{
				var xOffset:Number = this.globalToLocal(horizontalAxisChart.localToGlobal(new Point())).x;
				var rightLimit:Number = horizontalAxisChart.width;
				var todayLeft:Number = horizontalAxisChart.transformTimeToPosition(horizontalAxisChart.initialRightRangeTime - ScrubChart.DAYS_TO_MILLISECONDS);
				if (todayLeft > rightLimit)
				{
					_todayHighlight.visible = false
				}
				else
				{
					if (todayLeft < 0)
						todayLeft = 0;
					var todayRight:Number = horizontalAxisChart.transformTimeToPosition(horizontalAxisChart.initialRightRangeTime);

					if (todayRight > rightLimit)
						todayRight = rightLimit;

					if (todayRight < 0)
					{
						_todayHighlight.visible = false
					}
					else
					{
						_todayHighlight.x = xOffset + todayLeft;
						_todayHighlight.width = todayRight - todayLeft;
						_todayHighlight.visible = true;
					}
				}
			}
		}

		private function createChartsFromDescriptors():void
		{
			for each (var chartDescriptor:IChartDescriptor in _chartDescriptors.values())
			{
				if (chartDescriptor is MedicationChartDescriptor)
				{
					createMedicationAdherenceChart(chartDescriptor as MedicationChartDescriptor);
				}
				else if (chartDescriptor is VitalSignChartDescriptor)
				{
					createVitalSignAdherenceChart(chartDescriptor as VitalSignChartDescriptor);
				}
			}
		}

		private function initializeModifierFactories():void
		{
			_chartModifierFactories = [new DefaultChartModifierFactory()];
			var factories:Array = componentContainer.resolveAll(IChartModifierFactory);
			if (factories != null)
			{
				_chartModifierFactories = _chartModifierFactories.concat(factories);
			}
		}

		private function createChartDescriptors():void
		{
			_chartDescriptors = new OrderedMap();

			// TODO: make the list of chart descriptors plugable so that new charts can be added (other than the default list of medications and vitals)
			for each (var medicationCode:String in model.medicationConcentrationCurvesByCode.keys)
			{
				var medicationFill:MedicationFill = getMedicationFill(medicationCode);

				var medicationChartDescriptor:MedicationChartDescriptor = new MedicationChartDescriptor();
				medicationChartDescriptor.medicationCode = medicationCode;
				if (medicationFill && medicationFill.ndc)
				medicationChartDescriptor.ndcCode = medicationFill.ndc.text;
				addChartDescriptor(medicationChartDescriptor);
			}

			for each (var vitalSignKey:String in vitalSignChartCategories)
			{
				var vitalSignChartDescriptor:VitalSignChartDescriptor = new VitalSignChartDescriptor();
				vitalSignChartDescriptor.vitalSignCategory = vitalSignKey;
				addChartDescriptor(vitalSignChartDescriptor);
			}
		}

		private function addChartDescriptor(chartDescriptor:IChartDescriptor):void
		{
			_chartDescriptors.addKeyValue(chartDescriptor.descriptorKey, chartDescriptor);
		}

		private function createChartModifiers():void
		{
			_chartModifiers = new OrderedMap();

			for each (var chartDescriptor:IChartDescriptor in _chartDescriptors.values())
			{
				var currentModifier:IChartModifier = null;
				for each (var chartModifierFactory:IChartModifierFactory in _chartModifierFactories)
				{
					currentModifier = chartModifierFactory.createChartModifier(chartDescriptor, createChartModelDetails(), currentModifier);
				}

				if (currentModifier)
				{
					_chartModifiers.addKeyValue(currentModifier.chartKey, currentModifier);
				}
			}
		}

		private function createChartModelDetails():ChartModelDetails
		{
			return new ChartModelDetails(model.record, _activeAccountId, model.currentDateSource);
		}

		/**
		 * Subclasses should override to create custom charts.
		 */
		protected function createCustomCharts():void
		{
		}

		private function createMedicationAdherenceChart(chartDescriptor:MedicationChartDescriptor):void
		{
			var medicationCode:String = chartDescriptor.medicationCode;
			var medicationFill:MedicationFill = getMedicationFill(medicationCode);
			var medicationAdministrationsCollection:ArrayCollection = model.record.medicationAdministrationsModel.medicationAdministrationsCollectionsByCode.getItem(medicationCode);
			if (medicationAdministrationsCollection && medicationAdministrationsCollection[0])
			{
				var medicationAdministration:MedicationAdministration = medicationAdministrationsCollection[0];
				var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);
				if (medicationModel == null)
					throw new Error("Medication " + medicationCode +
							" is in model.medicationConcentrationCurvesByCode but not in model.simulation.medicationsByCode");

				var medicationScheduleItem:MedicationScheduleItem = medicationModel.medicationScheduleItem;
				var concentrationChart:TouchScrollingScrubChart = createConcentrationChart(chartDescriptor,
						medicationFill,
						medicationAdministration);
				var adherenceStripChart:TouchScrollingScrubChart = createMedicationAdherenceStripChart(chartDescriptor,
						medicationFill
				);
				createAdherenceGroup(chartDescriptor, createChartImage(chartDescriptor), concentrationChart, adherenceStripChart);
			}
		}

		private function createChartImage(chartDescriptor:IChartDescriptor):IVisualElement
		{
			var chartModifier:IChartModifier = _chartModifiers.getValueByKey(chartDescriptor.descriptorKey);
			var chartImage:IVisualElement;
			if (chartModifier)
				chartImage = chartModifier.createImage(null);
			return chartImage;
		}

		private function createConcentrationChart(chartDescriptor:MedicationChartDescriptor, medicationFill:MedicationFill, medicationAdministration:MedicationAdministration):TouchScrollingScrubChart
		{
			var medicationCode:String = chartDescriptor.medicationCode;
			var chart:TouchScrollingScrubChart = createAdherenceChart(
					getConcentrationChartKey(medicationCode), chartDescriptor);
			setMedicationChartStyles(medicationCode, medicationFill, chart);
			chart.setStyle("borderVisible", false);
			var nameString:String;
			if (medicationFill)
				nameString = medicationFill.name.text;
			else
				nameString = medicationAdministration.name.text;
			var medicationName:MedicationName = MedicationNameUtil.parseName(nameString);
			chart.mainChartTitle = medicationName.medicationName;

			chart.seriesName = "concentration";
			chart.data = model.medicationConcentrationCurvesByCode.getItem(medicationCode);

			chart.addEventListener(SkinPartEvent.PART_ADDED, adherenceChart_skinPartAddedHandler, false, 0,
					true);
			chart.addEventListener(FlexEvent.CREATION_COMPLETE, medicationAdherenceChart_creationCompleteHandler,
					false, 0, true);

			return chart;
		}

		private function createMedicationAdherenceStripChart(chartDescriptor:MedicationChartDescriptor, medicationFill:MedicationFill):TouchScrollingScrubChart
		{
			var medicationCode:String = chartDescriptor.medicationCode;
			var chart:TouchScrollingScrubChart = createAdherenceChart(
					getMedicationAdherenceStripChartKey(medicationCode), chartDescriptor);

			chart.setStyle("skinClass", AdherenceStripChartSkin);
			setMedicationChartStyles(medicationCode, medicationFill, chart);

			var medicationModel:MedicationComponentAdherenceModel = model.focusSimulation.getMedication(medicationCode);
			if (medicationModel == null)
				throw new Error("Medication " + medicationCode +
						" is in model.medicationConcentrationCurvesByCode but not in model.simulation.medicationsByCode");
			var medicationScheduleItem:MedicationScheduleItem = medicationModel.medicationScheduleItem;

			initializeAdherenceStripChart(chart, medicationScheduleItem);

			chart.addEventListener(SkinPartEvent.PART_ADDED, medicationAdherenceStripChart_skinPartAddedHandler, false, 0,
					true);
			chart.addEventListener(FlexEvent.CREATION_COMPLETE, medicationAdherenceStripChart_creationCompleteHandler,
					false, 0, true);

			return chart;
		}

		private function initializeAdherenceStripChart(chart:TouchScrollingScrubChart, scheduleItem:ScheduleItemBase):void
		{
			chart.setStyle("borderVisible", false);
			chart.height = ADHERENCE_STRIP_CHART_HEIGHT;
			chart.seriesName = "yPosition";

			if (scheduleItem)
			{
				var descriptorKey:String = chart.getStyle("descriptorKey");
				chart.data = getAdherenceStripItemProxies(descriptorKey);
				chart.dateField = "date";
			}
		}

		private function createAdherenceChart(chartKey:String, chartDescriptor:IChartDescriptor, expectCreationComplete:Boolean=true):TouchScrollingScrubChart
		{
			var chart:TouchScrollingScrubChart = new TouchScrollingScrubChart();
			chart.id = chartKey;

			if (chartDescriptor)
				chart.setStyle("descriptorKey", chartDescriptor.descriptorKey);

			chart.setStyle("skinClass", HealthChartSkin);
//			chart.setStyle("skinClass", ScrubChartMinimalSkin);
			chart.percentWidth = 100;
			chart.percentHeight = 100;
			chart.setStyle("sliderVisible", false);
			chart.today = model.currentDateSource.now();
			chart.initialRightRangeTime = chart.today.valueOf();
			chart.showFps = model.showFps;
			chart.initialDurationTime = initialDurationTime;
			chart.showFocusTimeMarker = false;
			chart.scrollEnabled = scrollEnabled;
			chart.synchronizedAxisCache = _synchronizedAxisCache;
			chart.useHorizontalTouchScrolling = useHorizontalTouchScrolling;

			chart.addEventListener(ScrollEvent.SCROLL, chart_scrollHandler, false, 0, true);
			chart.addEventListener(TouchScrollerEvent.SCROLL_START, chart_scrollStartHandler, false, 0,
					true);
			chart.addEventListener(TouchScrollerEvent.SCROLL_STOP, chart_scrollStopHandler, false, 0, true);
			chart.addEventListener(FocusTimeEvent.FOCUS_TIME_CHANGE, chart_focusTimeChangeHandler, false, 0,
					true);

			if (expectCreationComplete)
				_chartsWithPendingMainChartAdded.addItem(chart);

			_adherenceCharts.addKeyValue(chartKey, chart);
			addChart(chart);

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

		/**
		 * Adds the specified chart to the list of charts that are synchronized. Note that this does NOT add the
		 * chart to the visual hierarchy.
		 * @param chart
		 */
		protected function addCustomChart(chart:TouchScrollingScrubChart):void
		{
			addChart(chart);
			_customCharts.push(chart);
		}

		private function getConcentrationChartKey(medicationCode:String):String
		{
			return "medication_" + medicationCode + "_concentration";
		}

		private function getMedicationAdherenceStripChartKey(medicationCode:String):String
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

		/**
		 * Creates a group and adds it to the synchronized charts (at the bottom). The group will use the specified
		 * image (or other component) on the left and the two charts on the right (stacked on on top of the other).
		 * @param image The image representing the health action or other content represented by the charts
		 * @param resultChart The chart representing the results (such as medication concentration or vital signs)
		 * @param adherenceStripChart The adherence strip chart showing the scheduled health actions and the correspond adherence/actions taken
		 */
		public function createAdherenceGroup(chartDescriptor:IChartDescriptor,
											 image:IVisualElement,
											 resultChart:TouchScrollingScrubChart,
											 adherenceStripChart:TouchScrollingScrubChart):HGroup
		{
			var adherenceGroup:HGroup = new HGroup();

			if (!image)
			{
				image = new Rect();
				image.width = 100;
				image.height = 100;
			}

			var adherenceChartsGroup:VGroup = new VGroup();
			adherenceChartsGroup.gap = 0;
			adherenceChartsGroup.addElement(resultChart);
			if (adherenceStripChart)
			{
				var line:HRule = new HRule();
				line.percentWidth = 100;
				line.setStyle("strokeColor", 0x808285);
				adherenceChartsGroup.addElement(line);
				adherenceChartsGroup.addElement(adherenceStripChart);
			}
			adherenceChartsGroup.percentWidth = 100;
			adherenceChartsGroup.percentHeight = 100;
			var adherenceChartsBorderContainer:BorderContainer = new BorderContainer();
			adherenceChartsBorderContainer.setStyle("skinClass", BorderContainerSkin);
			adherenceChartsBorderContainer.addElement(adherenceChartsGroup);
			if (chartDescriptor is HorizontalAxisChartDescriptor)
			{
				adherenceChartsBorderContainer.backgroundFill = new SolidColor(0, 0);
				// make sure there is a 1 pixel invisible border so that the chart is the exact same size as the other charts
				adherenceChartsBorderContainer.borderStroke = new SolidColorStroke(0, 1, 0);
			}
			else
			{
				adherenceChartsBorderContainer.borderStroke = new SolidColorStroke(0x231F20);
			}
			adherenceChartsBorderContainer.percentWidth = 100;
			adherenceChartsBorderContainer.percentHeight = 100;

			fixCalloutSkin();
			var adherenceLeftContentGroup:Group = new Group();
			
			var calloutButton:CalloutButton = new CalloutButton();

			var hideChartButton:Button = new Button();
			hideChartButton.label = "Hide";
			hideChartButton.addEventListener(MouseEvent.CLICK, hideChartButton_clickHandler, false, 0, true);
			initializeChartButton(hideChartButton, chartDescriptor, calloutButton);

			var singleChartButton:Button = new Button();
			singleChartButton.label = "Just This Chart";
			singleChartButton.addEventListener(MouseEvent.CLICK, singleChartButton_clickHandler, false, 0, true);
			initializeChartButton(singleChartButton, chartDescriptor, calloutButton);

			var verticalLayout:VerticalLayout = new VerticalLayout();
			verticalLayout.paddingBottom = verticalLayout.paddingTop = verticalLayout.paddingLeft = verticalLayout.paddingRight = 10;
			verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
			calloutButton.calloutLayout = verticalLayout;
			calloutButton.calloutContent = new Array(hideChartButton, singleChartButton);
			adherenceLeftContentGroup.width = calloutButton.width = 100;
			adherenceLeftContentGroup.maxHeight = calloutButton.maxHeight = 100;
			if (chartDescriptor.descriptorKey == HORIZONTAL_AXIS_CHART_KEY)
			{
/*
				// For debugging, it may be helpfull to allow the horizontal axis to be hidden
				calloutButton.setStyle("skinClass", ButtonSkin);
				calloutButton.label = "Axis";
				calloutButton.visible = false;
				adherenceLeftContentGroup.addEventListener(MouseEvent.MOUSE_OVER, calloutButton_mouseOverHandler, false, 0, true);
				adherenceLeftContentGroup.addEventListener(MouseEvent.MOUSE_OUT, calloutButton_mouseOutHandler, false, 0, true);
*/
			}
			else
			{
				calloutButton.setStyle("skinClass", ChartButtonSkin);
				calloutButton.setStyle("icon", image);
				adherenceLeftContentGroup.addElement(calloutButton);
			}

			adherenceGroup.gap = 0;

			adherenceGroup.addElement(adherenceLeftContentGroup);
			adherenceGroup.addElement(adherenceChartsBorderContainer);
//			adherenceGroup.addElement(adherenceChartsGroup);
			adherenceGroup.percentWidth = 100;
			adherenceGroup.percentHeight = 100;
			adherenceGroup.verticalAlign = VerticalAlign.MIDDLE;

			chartModifiersPrepareAdherenceGroup(chartDescriptor, adherenceGroup);

			_adherenceGroups.addKeyValue(chartDescriptor.descriptorKey, adherenceGroup);
			_chartsContainer.addElement(adherenceGroup);
			return adherenceGroup;
		}

		private function chartModifiersPrepareAdherenceGroup(chartDescriptor:IChartDescriptor,
															 adherenceGroup:HGroup):void
		{
			for each (var chartModifier:IChartModifier in _chartModifiers.values())
			{
				chartModifier.prepareAdherenceGroup(chartDescriptor, adherenceGroup);
			}
		}

		public function prepareAllAdherenceGroups():void
		{
			for each (var key:String in adherenceGroups.arrayOfKeys)
			{
				var chartDescriptor:IChartDescriptor = _chartDescriptors.getValueByKey(key);
				var adherenceGroup:HGroup = adherenceGroups.getValueByKey(key);
				chartModifiersPrepareAdherenceGroup(chartDescriptor, adherenceGroup);
			}
		}

		private function fixCalloutSkin():void
		{
			if (!FlexGlobals.topLevelApplication.styleManager.
					getStyleDeclaration(SPARK_COMPONENTS_CALLOUT_SELECTOR))
			{
				var styleDeclaration:CSSStyleDeclaration = new CSSStyleDeclaration();
				styleDeclaration.defaultFactory = function ():void
				{
					this.skinClass = CalloutSkin;
				};

				FlexGlobals.topLevelApplication.styleManager.
						setStyleDeclaration(SPARK_COMPONENTS_CALLOUT_SELECTOR, styleDeclaration, true);
				_appliedCalloutSkinFix = true;
			}
		}

		private function initializeChartButton(hideChartButton:Button, chartDescriptor:IChartDescriptor,
											   calloutButton:CalloutButton):void
		{
			hideChartButton.setStyle("descriptorKey", chartDescriptor.descriptorKey);
			hideChartButton.setStyle("calloutButton", calloutButton);
			hideChartButton.percentWidth = 100;
			hideChartButton.setStyle("fontSize", 20);
		}

		private function createFooter():void
		{
			if (modality == Settings.MODALITY_WORKSTATION)
			{
				_showAllChartsButton = new Button();
				_showAllChartsButton.label = "Show All";
				_showAllChartsButton.addEventListener(MouseEvent.CLICK, showAllChartsButton_clickHandler);
				_showAllChartsButton.width = 100;
				_showAllChartsButton.setStyle("skinClass", ButtonSkin);
				_showAllChartsButton.visible = false;

				_footer = new ChartFooter();
				_footer.paddingLeft = 16;
				_footer.paddingRight = 16;

				var footerGroup:HGroup = new HGroup();
				footerGroup.percentWidth = 100;
				footerGroup.gap = 0;
				footerGroup.addElement(_showAllChartsButton);
				footerGroup.addElement(_footer);

				_chartsContainer.addElement(footerGroup);
			}
		}

		protected function addCustomChartGroup(group:UIComponent):void
		{
			_chartsContainer.addElement(group);
		}

		private function createVitalSignAdherenceChart(vitalSignChartDescriptor:VitalSignChartDescriptor):void
		{
			var vitalSignKey:String = vitalSignChartDescriptor.vitalSignCategory;

			// find any equipment scheduled to be used to collect this vital sign
			var equipmentScheduleItem:EquipmentScheduleItem = getMatchingEquipmentScheduleItem(vitalSignKey);
			var vitalSignCollection:ArrayCollection = model.record.vitalSignsModel.vitalSignsByCategory[vitalSignKey];

			if (vitalSignCollection && vitalSignCollection.length > 0 && vitalSignCollection[0])
			{
				var vitalSignChart:TouchScrollingScrubChart = createVitalSignChart(vitalSignChartDescriptor, vitalSignCollection);
				if (equipmentScheduleItem)
				{
					var adherenceStripChart:TouchScrollingScrubChart = createVitalSignAdherenceStripChart(vitalSignChartDescriptor,
							equipmentScheduleItem);
				}
				createAdherenceGroup(vitalSignChartDescriptor, createChartImage(vitalSignChartDescriptor), vitalSignChart,
						adherenceStripChart);
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

		private function createVitalSignChart(vitalSignChartDescriptor:VitalSignChartDescriptor, vitalSignCollection:ArrayCollection):TouchScrollingScrubChart
		{
			var vitalSignKey:String = vitalSignChartDescriptor.vitalSignCategory;
			var chart:TouchScrollingScrubChart = createAdherenceChart(getVitalSignChartKey(vitalSignKey), vitalSignChartDescriptor);
			setVitalSignChartStyles(chart, vitalSignKey);

			chart.setStyle("borderVisible", false);
			chart.mainChartTitle = vitalSignKey;

			chart.dateField = "dateMeasuredStart";
			chart.seriesName = "resultAsNumber";
			chart.data = model.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignKey);

			chart.addEventListener(SkinPartEvent.PART_ADDED, adherenceChart_skinPartAddedHandler, false, 0,
					true);

			return chart;
		}

		private function setVitalSignChartStyles(chart:TouchScrollingScrubChart, vitalSignKey:String):void
		{
			chart.setStyle("vitalSignKey", vitalSignKey);
		}

		protected function createVitalSignAdherenceStripChart(vitalSignChartDescriptor:VitalSignChartDescriptor, equipmentScheduleItem:EquipmentScheduleItem):TouchScrollingScrubChart
		{
			var vitalSignKey:String = vitalSignChartDescriptor.vitalSignCategory;
			var chart:TouchScrollingScrubChart = createAdherenceChart(getVitalSignAdherenceStripChartKey(vitalSignKey), vitalSignChartDescriptor);
			setVitalSignChartStyles(chart, vitalSignKey);

			chart.setStyle("skinClass", AdherenceStripChartSkin);

			initializeAdherenceStripChart(chart, equipmentScheduleItem);

			chart.addEventListener(SkinPartEvent.PART_ADDED, vitalSignAdherenceStripChart_skinPartAddedHandler, false, 0,
					true);

			return chart;
		}

		protected function getMatchingEquipmentScheduleItem(vitalSignKey:String):EquipmentScheduleItem
		{
			for each (var equipmentScheduleItem:EquipmentScheduleItem in model.record.equipmentScheduleItemsModel.equipmentScheduleItemCollection)
			{
				// TODO: use something more robust than matching the string in the instructions;
				if (equipmentScheduleItem.instructions &&
						equipmentScheduleItem.instructions.toLowerCase().search(vitalSignKey.toLowerCase()) != -1)
				{
					return equipmentScheduleItem;
				}
				if (equipmentScheduleItem.adherenceItems.size() > 0)
				{
					for each (var adherenceItem:AdherenceItem in equipmentScheduleItem.adherenceItems.values())
					{
						if (adherenceItem.adherence)
						{
							for each (var document:IDocument in adherenceItem.adherenceResults)
							{
								var vitalSign:VitalSign = document as VitalSign;
								if (vitalSign && vitalSign.name.text == vitalSignKey)
								{
									return equipmentScheduleItem;
								}
							}
							// To avoid checking too many adherence items, only check the first adherence item with adherence == true
							break;
						}
					}
				}
			}
			return null;
		}

		protected function getMatchingMedicationScheduleItem(medicationCode:String):MedicationScheduleItem
		{
			for each (var medicationScheduleItem:MedicationScheduleItem in
					model.record.medicationScheduleItemsModel.medicationScheduleItemCollection)
			{
				if (medicationScheduleItem.name.value == medicationCode)
				{
					return medicationScheduleItem;
				}
			}
			return null;
		}

		// TODO: implement and use this method to update the charts when the demo date changes
		private function updateAdherenceCharts():void
		{
			if (_traceEventHandlers)
				logDebugEvent("updateAdherenceCharts");

			for each (var chartDescriptor:IChartDescriptor in _chartDescriptors.values())
			{
				var adherenceStripItemProxies:ArrayCollection = getAdherenceStripItemProxies(chartDescriptor.descriptorKey);

				// TODO: support updating vital sign charts
				var medicationChartDescriptor:MedicationChartDescriptor = chartDescriptor as MedicationChartDescriptor;
				if (medicationChartDescriptor)
				{
					var medicationCode:String = medicationChartDescriptor.medicationCode;
					updateAdherenceChart(getConcentrationChartKey(medicationCode),
							model.medicationConcentrationCurvesByCode.getItem(medicationCode), "date");
					updateAdherenceChart(getMedicationAdherenceStripChartKey(medicationCode),
							adherenceStripItemProxies, "date");
				}
				var vitalSignChartDescriptor:VitalSignChartDescriptor = chartDescriptor as VitalSignChartDescriptor;
				if (vitalSignChartDescriptor)
				{
					updateAdherenceChart(getVitalSignChartKey(vitalSignChartDescriptor.vitalSignCategory),
							model.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignChartDescriptor.vitalSignCategory),
							"dateMeasuredStart");
					updateAdherenceChart(getVitalSignAdherenceStripChartKey(vitalSignChartDescriptor.vitalSignCategory),
							adherenceStripItemProxies, "date");
				}
			}
			queueSynchronizeDateLimits();
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

		private function adherenceChart_skinPartAddedHandler(event:SkinPartEvent):void
		{
			if (event.partName == "mainChart")
			{
				if (_traceEventHandlers)
					logDebugEvent("adherenceChart_skinPartAddedHandler", "mainChart", chartToTraceString(event));

				var chart:ScrubChart = ScrubChart(event.target);
				var chartModifier:IChartModifier = getChartModifier(chart);

				var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
				verticalAxis.minimum = NaN;
				verticalAxis.maximum = NaN;

				chart.removeDefaultSeries();
				if (chartModifier)
					addSeriesDataSets(chartModifier, chart);

				var index:int = _chartsWithPendingMainChartAdded.getItemIndex(chart);
				if (index != -1)
				{
					_chartsWithPendingMainChartAdded.removeItemAt(index);
					checkReadyToSynchronizeDateLimits();
				}

				chart.mainChart.dataTipFunction = adherenceChart_dataTipFunction;
				if (chartModifier)
					chartModifier.modifyMainChart(chart);

				chart.mainChart.addEventListener(Event.RESIZE, chart_mainChart_resizeHandler);
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					verticalAxis = chart.rangeChart.verticalAxis as LinearAxis;
					verticalAxis.minimum = NaN;
					verticalAxis.maximum = NaN;
				}
			}
		}

		private function queueUpdateBackgroundElements():void
		{
			invalidateProperties();
			_pendingUpdateBackgroundElements = true;
		}

		private function fixVerticalAxis(chart:ScrubChart):void
		{
			fixVerticalAxis2(chart.mainChart);
			if (chart.mainChartCover)
			{
				fixVerticalAxis2(chart.mainChartCover);
			}
		}

		private function fixVerticalAxis2(cartesianChart:CartesianChart):void
		{
			for each (var axisRenderer:IAxisRenderer in cartesianChart.verticalAxisRenderers)
			{
				doResizeFix(axisRenderer as UIComponent);
			}
		}

		private function doResizeFix(component:UIComponent):void
		{
			if (_useRedrawFix && component)
			{
				callLater(
						function ():void
						{
							component.invalidateDisplayList();
						}
				);
			}
		}

		public function getChartModifier(chart:ScrubChart):IChartModifier
		{
			var descriptorKey:String = chart.getStyle("descriptorKey");
//				var chartDescriptor:IChartDescriptor;
			var chartModifier:IChartModifier;
			if (!StringUtils.isEmpty(descriptorKey))
			{
//					chartDescriptor = _chartDescriptors.getValueByKey(descriptorKey);
				chartModifier = _chartModifiers.getValueByKey(descriptorKey);
			}
			return chartModifier;
		}

		private function drawBackgroundElements(chartModifier:IChartModifier,
												chart:ScrubChart):void
		{
			if (_traceEventHandlers)
				logDebugEvent("drawBackgroundElements", chartToTraceString(chart));

			var mainCanvas:DataDrawingCanvas = chart.mainChart.backgroundElements[0] as DataDrawingCanvas;
			if (mainCanvas)
			{
				var zoneLabel:Label = (mainCanvas && mainCanvas.numChildren > 0) ? mainCanvas.getChildAt(0) as Label : null;
				if (zoneLabel)
				{
					// Position the zone label to some neutral location so that we don't get rendering errors if the chart modifier doesn't do anything with the label
					mainCanvas.updateDataChild(zoneLabel, {left:Edge.LEFT, bottom:Edge.BOTTOM});
				}

				if (_blankBackgrounds)
				{
					mainCanvas.clear();
				}
				else
				{
					chartModifier.drawBackgroundElements(mainCanvas, zoneLabel);
					if (_useRedrawFix)
					{
						callLater(
								function ():void
								{
									mainCanvas.invalidateDisplayList();
								}
						);
					}
				}

				if (chart.rangeChart)
				{
					// TODO: add support for the range chart
				}

				mainCanvas.invalidateSize();
			}
		}

		protected function medicationAdherenceChart_creationCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				logDebugEvent("medicationAdherenceChart_creationCompleteHandler", chartToTraceString(event));
		}

		private function updateAdherenceStripMainChartAny(chart:ScrubChart):void
		{
			var vitalSignKey:String = chart.getStyle("vitalSignKey");
			var scheduleItem:ScheduleItemBase;
			if (vitalSignKey)
			{
				scheduleItem = getMatchingEquipmentScheduleItem(vitalSignKey);
			}
			else
			{
				var medicationCode:String = chart.getStyle("medicationCode");
				if (medicationCode)
				{
					scheduleItem = getMatchingMedicationScheduleItem(medicationCode);
				}
			}

			updateAdherenceStripMainChart(chart, scheduleItem);
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
				var medicationCode:String = chart.getStyle("medicationCode");
				var scheduleItem:ScheduleItemBase = getMatchingMedicationScheduleItem(medicationCode);
				updateAdherenceStripMainChart(chart, scheduleItem);
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					var verticalAxis:LinearAxis;
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
				var vitalSignKey:String = chart.getStyle("vitalSignKey");
				var scheduleItem:ScheduleItemBase = getMatchingEquipmentScheduleItem(vitalSignKey);
				updateAdherenceStripMainChart(chart, scheduleItem);
			}
			else if (event.partName == "rangeChart")
			{
				chart = ScrubChart(event.target);

				if (chart.rangeChart)
				{
					var verticalAxis:LinearAxis;
					verticalAxis = chart.rangeChart.verticalAxis as LinearAxis;
					verticalAxis.minimum = STRIP_CHART_VERTICAL_AXIS_MINIMUM;
					verticalAxis.maximum = STRIP_CHART_VERTICAL_AXIS_MAXIMUM;
				}
			}
		}

		private function updateAdherenceStripMainChart(chart:ScrubChart, scheduleItem:ScheduleItemBase):void
		{
			var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = STRIP_CHART_VERTICAL_AXIS_MINIMUM;
			verticalAxis.maximum = STRIP_CHART_VERTICAL_AXIS_MAXIMUM;

			chart.removeDefaultSeries();

			if (scheduleItem)
			{
				var scheduleItemName:String = scheduleItem.name.text;
				addAdherenceSeries(chart, scheduleItemName);

				var mainCanvas:DataDrawingCanvas = chart.mainChart.backgroundElements[0] as DataDrawingCanvas;
				if (mainCanvas)
				{
					updateAdherenceStripChartSeriesCompleteHandler(chart, mainCanvas,
							(mainCanvas && mainCanvas.numChildren > 0) ? mainCanvas.getChildAt(0) as Label : null,
							null);
					mainCanvas.invalidateSize();
				}
			}

			var index:int = _chartsWithPendingMainChartAdded.getItemIndex(chart);
			if (index != -1)
			{
				_chartsWithPendingMainChartAdded.removeItemAt(index);
				checkReadyToSynchronizeDateLimits();
			}

			chart.mainChart.dataTipFunction = adherenceChart_dataTipFunction;
		}

		protected function medicationAdherenceStripChart_creationCompleteHandler(event:FlexEvent):void
		{
			if (_traceEventHandlers)
				logDebugEvent("medicationAdherenceStripChart_creationCompleteHandler", chartToTraceString(event));
		}

		// TODO: separate out code for specific charts to different functions
		private function adherenceChart_dataTipFunction(hitData:HitData):String
		{
			var proxy:AdherenceStripItemProxy = hitData.item as AdherenceStripItemProxy;
//			if (proxy == null)
//				throw new Error("hitData.item is a " + ReflectionUtils.getClassInfo(ReflectionUtils.getClass(hitData.item)).name + "; expected AdherenceStripItemProxy");

			if (proxy)
			{
				return proxy.dataTip;
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

		private function addSeriesDataSets(chartModifier:IChartModifier, chart:ScrubChart):void
		{
			if (_traceEventHandlers)
				logDebugEvent("addSeriesDataSets", chartToTraceString(chart));

			var seriesDataSets:Vector.<SeriesDataSet> = new Vector.<SeriesDataSet>();
			
			seriesDataSets = chartModifier.createMainChartSeriesDataSets(chart, seriesDataSets);
			
			for each (var seriesDataSet:SeriesDataSet in seriesDataSets)
			{
				_seriesWithPendingUpdateComplete.addItem(seriesDataSet.series);
				seriesDataSet.series.addEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler);
	
				chart.mainChart.series.push(seriesDataSet.series);
				chart.addDataSet(seriesDataSet.seriesDataCollection, seriesDataSet.dateField);
				addSeriesSet(chart, seriesDataSet.series);
			}
		}

		protected function addCustomSeries(series:Series):void
		{
			_seriesWithPendingUpdateComplete.addItem(series);
		}

		protected function addCustomSeriesSet(seriesSet:ScrubChartSeriesSet):void
		{
			_seriesSets.push(seriesSet);
		}

		protected function series_updateCompleteHandler(event:FlexEvent):void
		{
			var series:Series = event.target as Series;
			if (_traceEventHandlers)
				logDebugEvent("series_updateCompleteHandler", series.id);

			series.removeEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler, false);
			checkAllSeriesComplete(series);
		}

		private function addAdherenceSeries(chart:ScrubChart, scheduleItemName:String):void
		{
			if (_traceEventHandlers)
				logDebugEvent("addAdherenceSeries", chartToTraceString(chart));

			var adherenceSeries:PlotSeries = new PlotSeries();
			adherenceSeries.name = "adherence";
			adherenceSeries.id = chart.id + "_adherenceSeries";
			adherenceSeries.xField = "date";
//			TODO: position the adherence series without the hack of using adherencePosition
			adherenceSeries.yField = "yPosition";
			
			var descriptorKey:String = chart.getStyle("descriptorKey");
			var adherenceStripItemProxies:ArrayCollection = getAdherenceStripItemProxies(descriptorKey);

			adherenceSeries.dataProvider = adherenceStripItemProxies;
			adherenceSeries.setStyle("itemRenderer", new ClassFactory(AdherencePlotItemRenderer));
//			adherenceSeries.filterFunction = adherenceSeriesFilter;
			_seriesWithPendingUpdateComplete.addItem(adherenceSeries);
			adherenceSeries.addEventListener(FlexEvent.UPDATE_COMPLETE, series_updateCompleteHandler);

			chart.mainChart.series.push(adherenceSeries);
			chart.addDataSet(adherenceStripItemProxies, "date");

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

		public function drawVitalSignGoalRegion(canvas:DataDrawingCanvas, zoneLabel:Label, vitalSignKey:String):void
		{
			if (_traceEventHandlers)
				logDebugEvent("drawVitalSignGoalRegion", vitalSignKey);

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

		public function drawAdherenceStripRegions(canvas:DataDrawingCanvas, zoneLabel:Label, descriptorKey:String):void
		{
			if (_traceEventHandlers)
				logDebugEvent("drawAdherenceStripRegions", descriptorKey);
			var adherenceStripItemProxies:ArrayCollection = getAdherenceStripItemProxies(descriptorKey);
			canvas.clear();

			if (!_blankBackgrounds)
			{
				canvas.beginFill(0xFFFFFF);

				for each (var adherenceStripItemProxy:AdherenceStripItemProxy in adherenceStripItemProxies)
				{
					if (adherenceStripItemProxy.scheduleItemOccurrence)
					{
						canvas.drawRect(adherenceStripItemProxy.scheduleItemOccurrence.dateStart, [Edge.TOP, 3],
								adherenceStripItemProxy.scheduleItemOccurrence.dateEnd, [Edge.BOTTOM, -4]);
					}
				}

				canvas.endFill();
			}

			if (zoneLabel)
			{
				canvas.updateDataChild(zoneLabel, {left:Edge.LEFT, top:Edge.TOP});
			}
		}

		/**
		 * Gets an ArrayCollection of AdherenceStripItemProxy objects corresponding to the schedule occurrences for the
		 * specified scheduleItemCollection and scheduleItemName.
		 * @param scheduleItemCollection The collection to search for matching schedule items. This could be a collection of EquipmentScheduleItem or MedicationScheduleItem instances.
		 * @param scheduleItemName The name.value (if any) or name.text (if name.value is null) of the ScheduleItem instances to match. All occurrences from all matching schedule items will be included.
		 * @return The new ArrayCollection of AdherenceStripItemProxy objects. If no schedule items are found matching the specified name, then the resulting ArrayCollection will have no elements.
		 */
		private function createAdherenceStripItemProxies(scheduleItemCollection:ArrayCollection,
														 scheduleItemName:String, proxyType:String):ArrayCollection
		{
			var adherenceStripItemProxies:ArrayCollection = new ArrayCollection();
			var firstDateStart:Date;
			var lastDateEnd:Date;

			for each (var scheduleItem:ScheduleItemBase in scheduleItemCollection)
			{
				if (scheduleItemMatches(scheduleItem, scheduleItemName))
				{
					var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = scheduleItem.getScheduleItemOccurrences();
					for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
					{
						var proxy:AdherenceStripItemProxy = new AdherenceStripItemProxy(model.currentDateSource, proxyType, scheduleItemOccurrence, null);
						adherenceStripItemProxies.addItem(proxy);
					}

					if (firstDateStart == null || scheduleItemOccurrences[0].dateStart.time < firstDateStart.time)
						firstDateStart = scheduleItemOccurrences[0].dateStart;
					if (lastDateEnd == null ||
							scheduleItemOccurrences[scheduleItemOccurrences.length - 1].dateEnd.time >
									lastDateEnd.time)
						lastDateEnd = scheduleItemOccurrences[scheduleItemOccurrences.length - 1].dateEnd;
				}
			}
			
			// Also include all AdherenceItem instances that are not associated with any schedule item
			// Note that in general, there shouldn't be any orphaned AdherenceItem instances, but if it does happen we want
			// to include them anyways.
			var adherenceItemsCollection:ArrayCollection = model.adherenceItemsCollectionsByCode.getItem(scheduleItemName);
			for each (var adherenceItem:AdherenceItem in adherenceItemsCollection)
			{
				if (adherenceItem.scheduleItem == null)
				{
					proxy = new AdherenceStripItemProxy(model.currentDateSource, proxyType, null, adherenceItem);
					adherenceStripItemProxies.addItem(proxy);
				}
			}

			var sort:Sort = new Sort();
			sort.fields = [new SortField("date")];
			adherenceStripItemProxies.sort = sort;
			adherenceStripItemProxies.refresh();
			return adherenceStripItemProxies;
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

		private function synchronizeDateLimits():void
		{
			if (_traceEventHandlers)
				logDebugEvent("synchronizeDateLimits (start)", "minimum " + ScrubChart.traceDate(minimum) + " maximum " + ScrubChart.traceDate(maximum));

			var charts:Vector.<TouchScrollingScrubChart> = _visibleCharts;

			var minimum:Number;
			var maximum:Number;
			var today:Date = model.currentDateSource.now();
			var initialRightRangeTime:Number = getInitialRightRangeTime(today);
			for each (var chart:TouchScrollingScrubChart in charts)
			{
				chart.commitPendingDataChanges();
				if (isNaN(minimum))
					minimum = chart.minimumDataTime;
				else if (!isNaN(chart.minimumDataTime))
					minimum = Math.min(minimum, chart.minimumDataTime);

				if (isNaN(maximum))
					maximum = chart.maximumDataTime;
				else if (!isNaN(chart.maximumDataTime))
					maximum = Math.max(maximum, chart.maximumDataTime);
			}

			if (!isNaN(minimum) && !isNaN(maximum))
			{
				for each (chart in charts)
				{
					chart.today = today;
					chart.initialRightRangeTime = initialRightRangeTime;
					chart.minimumTime = minimum;
					chart.maximumTime = maximum;
//					if (chart.allSeriesUpdated())
//					{
//						// first time initialization complete; nothing else to do
//					}
//					else //if (chart.focusTime == chart.rightRangeTime == chart.maximumTime)
//					{
						chart.rightRangeTime = initialRightRangeTime;
						chart.leftRangeTime = Math.max(minimum, chart.rightRangeTime - initialDurationTime);
						chart.updateForScroll();
						chart.focusTime = today.valueOf();
//					}

					// TODO: it might be more optimal to only draw background elements after the dates have been synchronized
//					var chartModifier:IChartModifier = getChartModifier(chart);
//					if (chartModifier)
//						drawBackgroundElements(chartModifier, chart);

					moveTodayHighlight();
				}
			}

			if (_traceEventHandlers)
				logDebugEvent("synchronizeDateLimits (end)", "minimum " + ScrubChart.traceDate(minimum) + " maximum " + ScrubChart.traceDate(maximum));
		}

		private function getInitialRightRangeTime(today:Date):Number
		{
//			return today.date.valueOf();
			return roundTimeToNextDay(today).valueOf();
		}

		protected function roundTimeToNextDay(date:Date):Date
		{
			var interval:int = 60 * 24;
			var timezoneOffsetMilliseconds:Number = date.getTimezoneOffset() * 60 * 1000;
			var time:Number = date.getTime() - timezoneOffsetMilliseconds;
			var roundNumerator = 60000 * interval; //there are 60000 milliseconds in a minute
			var newTime:Number = (Math.ceil(time / roundNumerator) * roundNumerator);
			date.setTime(newTime + timezoneOffsetMilliseconds);
			return date;
		}

		protected function updateSeries():void
		{
			for each (var seriesSet:ScrubChartSeriesSet in _seriesSets)
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
			if (_traceEventHandlers)
				logDebugEvent("adherenceChart_initializeHandler", chartToTraceString(event));
		}

		private function updateAdherenceStripChartSeriesCompleteHandler(chart:ScrubChart, mainCanvas:DataDrawingCanvas, zoneLabel:Label, rangeCanvas:DataDrawingCanvas):void
		{
			var descriptorKey:String = chart.getStyle("descriptorKey");
			drawAdherenceStripRegions(mainCanvas, zoneLabel, descriptorKey);
			if (_useRedrawFix)
			{
				callLater(
						function ():void
						{
							mainCanvas.invalidateDisplayList();
						}
				);
			}

			if (chart.rangeChart)
			{
				chart.rangeChart.backgroundElements.push(rangeCanvas);
				drawAdherenceStripRegions(rangeCanvas, null, descriptorKey);
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
						_shouldRunIndividualBenchmarks = true;
						runScrollingBenchmark();
						break;
					}
					case Keyboard.G:
					{
						_shouldRunIndividualBenchmarks = false;
						runScrollingBenchmark();
						break;
					}
					case Keyboard.Y:
					{
						_blankBackgrounds = !_blankBackgrounds;

						drawBackgroundElementsForAdherenceCharts(true);
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
						logDebugEvent("_traceEventHandlers = " + _traceEventHandlers);
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

			visibleCharts = getVisibleCharts(allCharts, null, _singleChartMode, model.showAdherence);

			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);

			_individualTrials = new Vector.<BenchmarkTrial>();
			_completeTrial = new BenchmarkTrial();
			_completeTrial.name = "Overall";
			_individualTrials.push(_completeTrial);
			_completeTrial.start(_benchmarkFrameCount);
			_synchronizedTrial = new BenchmarkTrial();
			_synchronizedTrial.name = "Synchronized";
			_individualTrials.push(_synchronizedTrial);
			_synchronizedTrial.start(_benchmarkFrameCount);

			doScrollTest(visibleCharts[0], 1, benchmarkTrialDuration, benchmarkStep2);
		}

		private function benchmarkStep2(event:Event):void
		{
			_synchronizedTrial.stop(_benchmarkFrameCount);

			if (_shouldRunIndividualBenchmarks)
			{
				var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();
				_individualChartsQueue = getVisibleCharts(allCharts, null, _singleChartMode, model.showAdherence);

				startIndividualTrial();
			}
			else
			{
				finishScrollingBenchmark();
			}
		}

		private function startIndividualTrial():void
		{
			setSingleChartMode(_individualChartsQueue[0], true);
			var trial:BenchmarkTrial = new BenchmarkTrial();
			trial.name = _individualChartsQueue[0].id;
			_individualTrials.push(trial);
			trial.start(_benchmarkFrameCount);
			doScrollTest(_individualChartsQueue[0], 1, benchmarkTrialDuration, benchmarkStep3);
		}

		private function stopIndividualTrial():void
		{
			_individualTrials[_individualTrials.length - 1].stop(_benchmarkFrameCount);
			setSingleChartMode(_individualChartsQueue[0], false);
			_individualChartsQueue.shift();
		}

		private function benchmarkStep3(event:Event):void
		{
			stopIndividualTrial();

			if (_individualChartsQueue.length > 0)
				startIndividualTrial();
			else
			{
				finishScrollingBenchmark();
			}
		}

		private function finishScrollingBenchmark():void
		{
			_completeTrial.stop(_benchmarkFrameCount);

			logDebugEvent("======= Benchmark Results ========");

			for each (var trial:BenchmarkTrial in _individualTrials)
			{
				logDebugEvent("  " + StringUtils.padRight(trial.name + ":", " ",
						20) + " " + trial.fps.toFixed(2));
			}
		}

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
			updateChartsVisibility(targetChart);
		}

		private function updateChartsVisibility(targetChart:TouchScrollingScrubChart):void
		{
			var someChartsHidden:Boolean = false;
			var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();

			for each (var chart:TouchScrollingScrubChart in allCharts)
			{
				var visible:Boolean = _visibleCharts.indexOf(chart) != -1;
				chart.visible = visible;
				chart.includeInLayout = visible;
				if (!visible)
					someChartsHidden = true;
			}

			for each (var adherenceGroup:Group in _adherenceGroups.values())
			{
				var groupVisible:Boolean = false;
				for each (var chart:TouchScrollingScrubChart in getChartsInGroup(adherenceGroup))
				{
					if (_visibleCharts.indexOf(chart) != -1)
						groupVisible = true;
				}
				adherenceGroup.visible = groupVisible;
				adherenceGroup.includeInLayout = groupVisible;
			}

			if (_visibleCharts.length > 1 && targetChart != null)
			{
				var nonTargetCharts:Vector.<TouchScrollingScrubChart> = getVisibleNonTargetCharts(_visibleCharts,
						targetChart);
				synchronizeScrollPositions(targetChart, nonTargetCharts);
				synchronizeFocusTimes(targetChart, nonTargetCharts);
			}

			if (_visibleCharts && _visibleCharts.length > 0)
			{
				_rangeButtonTargetChart = _visibleCharts[0];
			}
			else
			{
				_rangeButtonTargetChart = null;
			}

			if (_footer)
			{
				_footer.chart = _rangeButtonTargetChart;
			}

			if (_showAllChartsButton)
			{
				_showAllChartsButton.visible = someChartsHidden;
			}
		}

		private function getChartsInGroup(adherenceGroup:Group):Vector.<TouchScrollingScrubChart>
		{
			var charts:Vector.<TouchScrollingScrubChart> = new Vector.<TouchScrollingScrubChart>();
			
			var chartsGroup:Group = getChartsGroup(adherenceGroup);
			if (chartsGroup)
			{
				for (var i:int = 0; i < chartsGroup.numElements; i++)
				{
					var chart:TouchScrollingScrubChart = chartsGroup.getElementAt(i) as TouchScrollingScrubChart;
					if (chart)
					{
						charts.push(chart);
					}
				}
			}
			return charts;
		}

		private function getChartsGroup(adherenceGroup:Group):Group
		{
//			return adherenceGroup.getElementAt(1) as Group;
			var borderContainer:BorderContainer = adherenceGroup.getElementAt(1) as BorderContainer;
			return borderContainer ? borderContainer.getElementAt(0) as Group : null;
		}

		protected function getAllCharts():Vector.<TouchScrollingScrubChart>
		{
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

			if (!_singleChartMode)
			{
				synchronizeScrollPositions(targetChart, _nonTargetCharts);
			}

			queueUpdateSimulation(targetChart);
		}

		protected function synchronizeScrollPositions(targetChart:TouchScrollingScrubChart, otherCharts:Vector.<TouchScrollingScrubChart>, visibleOnly:Boolean = true):void
		{
			for each (var otherChart:TouchScrollingScrubChart in otherCharts)
			{
				if (otherChart.visible || !visibleOnly)
				{
					otherChart.synchronizeScrollPosition(targetChart);
				}
			}
			queueMoveTodayHighlight();
		}

		protected function synchronizeFocusTimes(targetChart:TouchScrollingScrubChart, otherCharts:Vector.<TouchScrollingScrubChart>):void
		{
			for each (var otherChart:TouchScrollingScrubChart in otherCharts)
			{
				if (otherChart.visible)
				{
					otherChart.focusTime = targetChart.focusTime;
				}
			}
		}

		protected function chart_scrollStartHandler(event:TouchScrollerEvent):void
		{
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);
			updateChartsCache(targetChart);

			if (_traceEventHandlers)
				logDebugEvent("chart_scrollStartHandler", chartToTraceString(targetChart));
		}

		protected function chart_scrollStopHandler(event:TouchScrollerEvent):void
		{
			var targetChart:TouchScrollingScrubChart = TouchScrollingScrubChart(event.currentTarget);

			if (_traceEventHandlers)
				logDebugEvent("chart_scrollStopHandler", chartToTraceString(targetChart));

			updateChartsAfterScrollStop();
		}

		private function updateChartsAfterScrollStop():void
		{
			var charts:Vector.<TouchScrollingScrubChart> = _visibleCharts;
			for each (var chart:TouchScrollingScrubChart in charts)
			{
				// TODO: ensure that _visibleCharts is up-to-date so that this additional check is unnecessary
				if (chart.visible)
				{
					chart.resetAfterQuickScroll();
				}
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
				_visibleCharts = getVisibleCharts(allCharts, targetChart, _singleChartMode, model.showAdherence);
				_nonTargetCharts = getVisibleNonTargetCharts(_visibleCharts, targetChart);
				_scrollTargetChart = targetChart;
			}
		}

		public function get doneUpdating():Boolean
		{
			return !_pendingSynchronizeDateLimits && !_pendingUpdateSimulation;
		}

		override protected function commitProperties():void
		{
			if (_traceEventHandlers)
				logDebugEvent("commitProperties");

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

			if (_pendingUpdateBackgroundElements)
			{
				drawBackgroundElementsForAdherenceCharts();
				_pendingUpdateBackgroundElements = false;
			}

			if (_pendingMoveTodayHighlight)
			{
				moveTodayHighlight();
				_pendingMoveTodayHighlight = false;
			}
		}

		private function drawBackgroundElementsForAdherenceCharts(updateStripCharts:Boolean = false):void
		{
			for each (var chartDescriptor:IChartDescriptor in _chartDescriptors.values())
			{
				var chartKey:String;
				var stripChartKey:String;
				var medicationChartDescriptor:MedicationChartDescriptor = chartDescriptor as MedicationChartDescriptor;
				if (medicationChartDescriptor)
				{
					var medicationCode:String = medicationChartDescriptor.medicationCode;
					chartKey = getConcentrationChartKey(medicationCode);
					stripChartKey = getMedicationAdherenceStripChartKey(medicationCode);
				}
				else
				{
					var vitalSignChartDescriptor:VitalSignChartDescriptor = chartDescriptor as VitalSignChartDescriptor;
					if (vitalSignChartDescriptor)
					{
						chartKey = getVitalSignChartKey(vitalSignChartDescriptor.vitalSignCategory);
						stripChartKey = getVitalSignAdherenceStripChartKey(vitalSignChartDescriptor.vitalSignCategory);
					}
				}

				if (chartKey)
				{
					var chart:TouchScrollingScrubChart;
					chart = _adherenceCharts.getValueByKey(chartKey);
					if (chart)
					{
						var chartModifier:IChartModifier = getChartModifier(chart);
						if (chartModifier)
							drawBackgroundElements(chartModifier, chart);
					}
				}

				if (stripChartKey && updateStripCharts)
				{
					var stripChart:TouchScrollingScrubChart = _adherenceCharts.getValueByKey(stripChartKey);
					if (stripChart)
					{
						updateAdherenceStripMainChartAny(stripChart);
					}
				}
			}
		}

		private function updateSimulation(targetChart:TouchScrollingScrubChart):void
		{
			if (skipUpdateSimulation)
				return;

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
				logDebugEvent("updateSimulation", chartToTraceString(targetChart), "focusTime " +
						ScrubChart.traceDate(model.focusSimulation.date.time) + " dateMeasuredStart " +
						(model.focusSimulation.dataPointDate ? ScrubChart.traceDate(model.focusSimulation.dataPointDate.time) : "(unavailable)") +
						" systolic " +
						model.focusSimulation.systolic + dataIndexMessage +
						" [" + medicationUpdateDescriptions.join(", ") + "]");
		}

		/**
		 * Gets a string describing the chart that is suitable for logging or trace messages.
		 * @param chartOrEvent the Event or ScrubChart
		 * @return string describing the chart
		 */
		private function chartToTraceString(chartOrEvent:*):String
		{
			var scrubChart:ScrubChart;
			var event:Event = chartOrEvent as Event;
			if (event != null)
			{
				scrubChart = event.target as ScrubChart;
			}
			if (scrubChart == null)
			{
				scrubChart = chartOrEvent as ScrubChart;
			}

			if (scrubChart)
				return scrubChart.id;
			else
				return "(no chart)";
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

		private function logDebugEvent(... rest):void
		{
			var message:String = rest.join(" ");
			// Rely on the trace target of the logger for tracing
//			trace(message, rest);
			_logger.debug(message);
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
				logDebugEvent("Warning: No medication found in the model.simulation for key " + medicationCode + ". This will happen if there are no MedicationAdministration documents in the record for this medication.");
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
			if (_traceEventHandlers)
				logDebugEvent("checkReadyToSynchronizeDateLimits", "_seriesWithPendingUpdateComplete.length =", _seriesWithPendingUpdateComplete.length, "_chartsWithPendingMainChartAdded.length =", _chartsWithPendingMainChartAdded.length);

			if (_seriesWithPendingUpdateComplete.length == 0 && _chartsWithPendingMainChartAdded.length == 0)
			{
				for each (var chart:TouchScrollingScrubChart in getAllCharts())
				{
					chart.allSeriesUpdated();
				}
				queueSynchronizeDateLimits();
				queueUpdateBackgroundElements();
			}
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
			logDebugEvent("useSliceMainData", useSliceMainData);
		}

		public function get shouldApplyChangesToSimulation():Boolean
		{
			return _shouldApplyChangesToSimulation;
		}

		public function set shouldApplyChangesToSimulation(value:Boolean):void
		{
			_shouldApplyChangesToSimulation = value;
			logDebugEvent("shouldApplyChangesToSimulation", shouldApplyChangesToSimulation);
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
			_seriesSets.push(seriesSet);
		}

		private function respondToModelUpdate():void
		{
			if (_traceEventHandlers)
				logDebugEvent("respondToModelUpdate", "model =", model, "model.isInitialized =", model.isInitialized);

			_seriesWithPendingUpdateComplete.removeAll();

			if (model && model.isInitialized)
			{
				initializeSeriesSets();
				updateChartModifiers();
			}

			if (model && model.isInitialized && model.showAdherence)
			{
				createAdherenceCharts();
				updateSeries();
			}

			setSingleChartMode(null, false);
		}

		private function updateChartModifiers():void
		{
			if (_chartModifiers)
			{
				for each (var chartModifier:IChartModifier in _chartModifiers.values())
				{
					chartModifier.chartModelDetails = createChartModelDetails();
				}
			}
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

		public function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function set componentContainer(value:IComponentContainer):void
		{
			_componentContainer = value;
		}

		public function get activeAccountId():String
		{
			return _activeAccountId;
		}

		public function set activeAccountId(value:String):void
		{
			_activeAccountId = value;
		}

		public function set viewNavigator(viewNavigator:ViewNavigator):void
		{
			_viewNavigator = viewNavigator;
		}

		private function hideChartButton_clickHandler(event:MouseEvent):void
		{
			var descriptorKey:String = handleChartButton(event);
			if (descriptorKey)
			{
				var adherenceGroup:Group = _adherenceGroups.getValueByKey(descriptorKey);
				if (adherenceGroup)
				{
					for each (var chart:TouchScrollingScrubChart in getChartsInGroup(adherenceGroup))
					{
						chart.visible = false;
						chart.includeInLayout = false;
					}
					
					_visibleCharts = new Vector.<TouchScrollingScrubChart>();
					for each (chart in getAllCharts())
					{
						if (chart.visible)
							_visibleCharts.push(chart);
					}
					
					adherenceGroup.visible = false;
					adherenceGroup.includeInLayout = false;
					if (_showAllChartsButton)
					{
						_showAllChartsButton.visible = true;
					}
				}
			}
		}

		private function singleChartButton_clickHandler(event:MouseEvent):void
		{
			// hide all charts except for those in the group associated with the button

			var descriptorKey:String = handleChartButton(event);
			if (descriptorKey)
			{
				var adherenceGroup:Group = _adherenceGroups.getValueByKey(descriptorKey);
				if (adherenceGroup)
				{
					var allCharts:Vector.<TouchScrollingScrubChart> = getAllCharts();

					_visibleCharts = getChartsInGroup(adherenceGroup);
					var horizontalAxisChart:TouchScrollingScrubChart = _adherenceCharts.getValueByKey(HORIZONTAL_AXIS_CHART_KEY);
					if (horizontalAxisChart)
					{
						_visibleCharts.push(horizontalAxisChart);
					}

					for each (var chart:TouchScrollingScrubChart in allCharts)
					{
						var visible:Boolean = _visibleCharts.indexOf(chart) != -1;
						chart.visible = visible;
						chart.includeInLayout = visible;
					}

					updateChartsVisibility(null);
				}
			}
		}

		private function handleChartButton(event:MouseEvent):String
		{
			var button:Button = event.target as Button;
			var calloutButton:CalloutButton = button.getStyle("calloutButton");

			if (calloutButton)
				calloutButton.closeDropDown();

			var descriptorKey:String = button.getStyle("descriptorKey");
			return descriptorKey;
		}

		private function showAllChartsButton_clickHandler(event:MouseEvent):void
		{
			var firstVisibleChart:TouchScrollingScrubChart = (_visibleCharts && _visibleCharts.length > 0) ? _visibleCharts[0] : null;
			synchronizeScrollPositions(firstVisibleChart, getAllCharts(), false);
			setSingleChartMode(null, false);
		}

		private function calloutButton_mouseOverHandler(event:MouseEvent):void
		{
			var calloutButton:CalloutButton = getCalloutButton(event);
			if (calloutButton)
			{
				calloutButton.visible = true;
			}
		}

		private function getCalloutButton(event:MouseEvent):CalloutButton
		{
			var adherenceLeftContentGroup:Group = event.currentTarget as Group;
			if (adherenceLeftContentGroup)
			{
				var calloutButton:CalloutButton = adherenceLeftContentGroup.getElementAt(0) as CalloutButton;
				return calloutButton;
			}
			return null;
		}

		private function calloutButton_mouseOutHandler(event:MouseEvent):void
		{
			var calloutButton:CalloutButton = getCalloutButton(event);
			if (calloutButton)
			{
				calloutButton.visible = false;
			}
		}

		private function removedFromStageHandler(event:Event):void
		{
			if (_appliedCalloutSkinFix && FlexGlobals.topLevelApplication.styleManager.
								getStyleDeclaration(SPARK_COMPONENTS_CALLOUT_SELECTOR))
			{
				FlexGlobals.topLevelApplication.styleManager.clearStyleDeclaration(SPARK_COMPONENTS_CALLOUT_SELECTOR, false);
			}
		}

		public function get adherenceGroups():OrderedMap
		{
			return _adherenceGroups;
		}

		private function chart_mainChart_resizeHandler(event:Event):void
		{
			if (_traceEventHandlers)
				logDebugEvent("chart_mainChart_resizeHandler", chartToTraceString(event));

			queueMoveTodayHighlight();
		}
	}
}
