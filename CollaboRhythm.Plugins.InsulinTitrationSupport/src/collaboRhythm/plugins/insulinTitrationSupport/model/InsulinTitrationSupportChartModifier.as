package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.controller.InsulinTitrationDecisionPanelController;
	import collaboRhythm.plugins.insulinTitrationSupport.view.ConfirmChangePopUp;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationDecisionPanel;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.ChartModifierBase;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.DefaultVitalSignChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.charts.HitData;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.CartesianChart;
	import mx.charts.chartClasses.IAxis;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.managers.PopUpManager;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Group;
	import spark.components.Label;
	import spark.events.PopUpEvent;
	import spark.primitives.Rect;

	public class InsulinTitrationSupportChartModifier extends ChartModifierBase implements IChartModifier
	{
		public static const INSULIN_LEVEMIR_CODE:String = "847241";
		public static const INSULIN_LANTUS_CODE:String = "847232";
		public static const INSULIN_MEDICATION_CODES:Vector.<String> = new <String>[INSULIN_LEVEMIR_CODE, INSULIN_LANTUS_CODE];
		private static const BLOOD_GLUCOSE_CHART_MIN_HEIGHT:int = 200;
		private static const PLOT_ITEM_RADIUS:int = 11;
		private static const PLOT_ITEM_STROKE_WEIGHT:int = 6;

		private var _insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel;
		private var _vitalSignsDataCollection:ArrayCollection;
		private var _seriesDataCollection:ArrayCollection;
		private var confirmChangePopUp:ConfirmChangePopUp = new ConfirmChangePopUp();
		private var _changeConfirmed:Boolean = false;
		private var _panelController:InsulinTitrationDecisionPanelController;

		public function InsulinTitrationSupportChartModifier(chartDescriptor:IChartDescriptor,
															 chartModelDetails:IChartModelDetails,
															 currentChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, currentChartModifier);
			initializeInsulinTitrationDecisionPanelModel();
			_panelController = new InsulinTitrationDecisionPanelController(chartModelDetails.collaborationLobbyNetConnectionServiceProxy,
					_insulinTitrationDecisionPanelModel);
		}

		public function modifyCartesianChart(chart:ScrubChart,
											 cartesianChart:CartesianChart,
											 isMainChart:Boolean):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyCartesianChart(chart, cartesianChart, isMainChart);

			cartesianChart.dataTipFunction = mainChart_dataTipFunction;
			if (isMainChart)
				_insulinTitrationDecisionPanelModel.chartVerticalAxis = cartesianChart.verticalAxis as LinearAxis;
		}

		protected function get vitalSignChartDescriptor():VitalSignChartDescriptor
		{
			return chartDescriptor as VitalSignChartDescriptor;
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			var vitalSignSeries:PlotSeries = new PlotSeries();
			vitalSignSeries.name = "vitalSignPrimary";
			vitalSignSeries.id = chart.id + "_primarySeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			var seriesDataCollection:ArrayCollection = getSeriesDataCollection();
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = vitalSignChartDescriptor.vitalSignCategory;
			vitalSignSeries.setStyle("radius", PLOT_ITEM_RADIUS);
			vitalSignSeries.filterDataValues = "none";
//			var color:uint = getVitalSignColor(vitalSignChartDescriptor.vitalSignCategory);
			var color:uint = 0;
			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(VitalSignForDecisionItemRenderer));
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(color, PLOT_ITEM_STROKE_WEIGHT));
			vitalSignSeries.setStyle("fill", new SolidColor(color));

			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));
			return seriesDataSets;
		}

		public override function getSeriesDataCollection():ArrayCollection
		{
			if (_vitalSignsDataCollection)
			{
				_vitalSignsDataCollection.removeEventListener(CollectionEvent.COLLECTION_CHANGE,
						vitalSignsDataCollection_collectionChangeHandler);
			}

			_vitalSignsDataCollection = chartModelDetails.record.vitalSignsModel.getVitalSignsByCategory(vitalSignChartDescriptor.vitalSignCategory);
			if (_vitalSignsDataCollection)
			{
				_vitalSignsDataCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
						vitalSignsDataCollection_collectionChangeHandler, false, 0, true);
			}

			_seriesDataCollection = createProxiesForDecision(_vitalSignsDataCollection);
			return _seriesDataCollection;
		}

		private function createProxiesForDecision(vitalSignsDataCollection:ArrayCollection):ArrayCollection
		{
			var seriesDataCollection:ArrayCollection = new ArrayCollection();
			for each (var vitalSign:VitalSign in vitalSignsDataCollection)
			{
				seriesDataCollection.addItem(new VitalSignForDecisionProxy(vitalSign, _insulinTitrationDecisionPanelModel));
			}
			return seriesDataCollection;
		}

		private function mainChart_dataTipFunction(hitData:HitData):String
		{
			var proxy:VitalSignForDecisionProxy = hitData.item as VitalSignForDecisionProxy;
			var vitalSign:VitalSign = proxy.vitalSign;
			if (vitalSign)
			{
				var result:String;
				if (vitalSign.result && vitalSign.result.textValue && isNaN(vitalSign.resultAsNumber))
					result = vitalSign.result.textValue;
				else
					result = vitalSign.resultAsNumber.toFixed(2);

				var eligiblePhrase:String = proxy.isEligible ? "Measurement is <b>eligible</b> for algorithm" : "Measurement is <b>not</b> eligible for algorithm";
				return vitalSign.name.text + " " + result + "<br/>" +
						eligiblePhrase + "<br/>" +
						"Date: " + vitalSign.dateMeasuredStart.toLocaleString();
			}

			return hitData.item.toString();
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			return decoratedModifier.createImage(currentChartImage);
		}

		public function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void
		{
			return decoratedModifier.drawBackgroundElements(canvas, zoneLabel);
		}

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			var insulinDescriptorTemplate:MedicationChartDescriptor = new MedicationChartDescriptor();
			var matchingInsulinChartDescriptors:Vector.<IChartDescriptor> = new Vector.<IChartDescriptor>();
			for each (var medicationCode:String in INSULIN_MEDICATION_CODES)
			{
				insulinDescriptorTemplate.medicationCode = medicationCode;
				if (chartDescriptors.getValueByKey(insulinDescriptorTemplate.descriptorKey) != null)
				{
					var matchingInsulinChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey) as
							IChartDescriptor;
					if (matchingInsulinChartDescriptor)
						matchingInsulinChartDescriptors.push(matchingInsulinChartDescriptor);
				}
			}

			var bloodGlucoseDescriptorTemplate:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			bloodGlucoseDescriptorTemplate.vitalSignCategory = VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
			var matchingBloodGlucoseChartDescriptor:IChartDescriptor;
			if (chartDescriptors.getValueByKey(bloodGlucoseDescriptorTemplate.descriptorKey) != null)
			{
				matchingBloodGlucoseChartDescriptor = chartDescriptors.removeByKey(bloodGlucoseDescriptorTemplate.descriptorKey) as
						IChartDescriptor;
			}

			var reorderedChartDescriptors:OrderedMap = new OrderedMap();
			for each (var otherChartDescriptor:IChartDescriptor in chartDescriptors.values())
			{
				reorderedChartDescriptors.addKeyValue(otherChartDescriptor.descriptorKey, otherChartDescriptor);
			}

			if (matchingInsulinChartDescriptors.length > 0)
			{
				for each (matchingInsulinChartDescriptor in matchingInsulinChartDescriptors)
				{
					reorderedChartDescriptors.addKeyValue(matchingInsulinChartDescriptor.descriptorKey,
							matchingInsulinChartDescriptor);
				}
			}
			if (matchingBloodGlucoseChartDescriptor)
				reorderedChartDescriptors.addKeyValue(matchingBloodGlucoseChartDescriptor.descriptorKey,
						matchingBloodGlucoseChartDescriptor);

			return reorderedChartDescriptors;
		}

		public override function prepareAdherenceGroup(chartDescriptor:IChartDescriptor, adherenceGroup:Group):void
		{
			//synchronizedHealthCharts:SynchronizedHealthCharts
			if (chartModelDetails.record.healthChartsModel.decisionPending)
			{
				// TODO: re-evaluate only when data or conditions change that could affect the panel instead of any time the view is shown
				if (InsulinTitrationSupportChartModifierFactory.isBloodGlucoseChartDescriptor(chartDescriptor))
				{
					_insulinTitrationDecisionPanelModel.evaluateForInitialize();
				}

				if (adherenceGroup.numElements == 2)
				{
					var extraPanel:IVisualElement;

					if (InsulinTitrationSupportChartModifierFactory.isBloodGlucoseChartDescriptor(chartDescriptor))
					{
						var panel:InsulinTitrationDecisionPanel = new InsulinTitrationDecisionPanel();
						panel.model = _insulinTitrationDecisionPanelModel;
						panel.controller = _panelController;
						panel.percentHeight = 100;
						extraPanel = panel;

						adherenceGroup.minHeight = BLOOD_GLUCOSE_CHART_MIN_HEIGHT;
					}
					else
					{
						var spacerRect:Rect = new Rect();
						spacerRect.width = InsulinTitrationDecisionPanel.INSULIN_TITRATION_DECISION_PANEL_WIDTH;
						spacerRect.visible = false;
						extraPanel = spacerRect;
					}
					adherenceGroup.addElement(extraPanel);
				}
			}
			else
			{
				while (adherenceGroup.numElements > 2)
					adherenceGroup.removeElementAt(adherenceGroup.numElements - 1);
			}
		}

		private function initializeInsulinTitrationDecisionPanelModel():void
		{
			_insulinTitrationDecisionPanelModel = new InsulinTitrationDecisionPanelModel(chartModelDetails);
			_insulinTitrationDecisionPanelModel.updateAreBloodGlucoseRequirementsMet();
			_insulinTitrationDecisionPanelModel.updateIsAdherencePerfect();
			_insulinTitrationDecisionPanelModel.verticalAxisMinimum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_VERTICAL_AXIS_MINIMUM;
			_insulinTitrationDecisionPanelModel.verticalAxisMaximum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_VERTICAL_AXIS_MAXIMUM;
			_insulinTitrationDecisionPanelModel.goalZoneMinimum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_GOAL_ZONE_MINIMUM;
			_insulinTitrationDecisionPanelModel.goalZoneMaximum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_GOAL_ZONE_MAXIMUM;
			_insulinTitrationDecisionPanelModel.goalZoneColor = DefaultVitalSignChartModifier.GOAL_ZONE_COLOR;
		}

		override public function set chartModelDetails(chartModelDetails:IChartModelDetails):void
		{
			super.chartModelDetails = chartModelDetails;
			if (_insulinTitrationDecisionPanelModel)
			{
				_insulinTitrationDecisionPanelModel.chartModelDetails = chartModelDetails;
				_insulinTitrationDecisionPanelModel.updateForRecordChange();

			}
		}

		override public function save():Boolean
		{
			if (!super.save())
				return false;

			_insulinTitrationDecisionPanelModel.evaluateForSave();

			if (!_insulinTitrationDecisionPanelModel.isChangeSpecified)
			{
				// TODO: Use a better UI to tell the user that a change must be specified to save
				Alert.show("Please choose a change to the dose before saving.");
				return false;
			}
			else if (_changeConfirmed)
			{
				// already showing popup, so assume this is the result of user clicking OK
				_changeConfirmed = false;
				return true;
			}
			else
			{
				confirmChangePopUp.model = new ConfirmChangePopUpModel(_insulinTitrationDecisionPanelModel.previousDoseValue, _insulinTitrationDecisionPanelModel.dosageChangeValueLabel, _insulinTitrationDecisionPanelModel.newDose, _insulinTitrationDecisionPanelModel.confirmationMessage);
				confirmChangePopUp.addEventListener(PopUpEvent.CLOSE, confirmChangePopUp_closeHandler);
				confirmChangePopUp.open(chartModelDetails.owner, true);
				PopUpManager.centerPopUp(confirmChangePopUp);

				return false;
			}
		}

		private function confirmChangePopUp_closeHandler(event:PopUpEvent):void
		{
			if (event.commit)
			{
				if (_insulinTitrationDecisionPanelModel.save())
				{
					_changeConfirmed = true;
					chartModelDetails.healthChartsModel.save();
				}
			}
		}

		private function vitalSignsDataCollection_collectionChangeHandler(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.ADD)
			{
				for each (var vitalSign:VitalSign in event.items)
				{
					_seriesDataCollection.addItem(new VitalSignForDecisionProxy(vitalSign,
							_insulinTitrationDecisionPanelModel));
				}
			}
			else if (event.kind == CollectionEventKind.REMOVE)
			{
				_seriesDataCollection.removeAll();
				var collection:ArrayCollection = createProxiesForDecision(_vitalSignsDataCollection);
				_seriesDataCollection.addAll(collection);
			}
		}

		override public function destroy():void
		{
			super.destroy();
			if (_panelController)
			{
				_panelController.destroy();
			}
		}
	}
}
