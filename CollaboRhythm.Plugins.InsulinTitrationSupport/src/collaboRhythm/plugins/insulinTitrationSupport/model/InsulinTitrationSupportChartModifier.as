package collaboRhythm.plugins.insulinTitrationSupport.model
{
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
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.events.CollectionEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Group;
	import spark.components.Label;
	import spark.primitives.Rect;

	public class InsulinTitrationSupportChartModifier extends ChartModifierBase implements IChartModifier
	{
		public static const INSULIN_LEVEMIR_CODE:String = "847241";

		private var _insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel;
		private var _vitalSignsDataCollection:ArrayCollection;

		public function InsulinTitrationSupportChartModifier(chartDescriptor:IChartDescriptor,
															 chartModelDetails:IChartModelDetails,
															 currentChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, currentChartModifier);
			initializeInsulinTitrationDecisionPanelModel();
		}

		public function modifyMainChart(chart:ScrubChart):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyMainChart(chart);
			chart.mainChart.dataTipFunction = mainChart_dataTipFunction;
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
			vitalSignSeries.setStyle("radius", 11);
			vitalSignSeries.filterDataValues = "none";
//			var color:uint = getVitalSignColor(vitalSignChartDescriptor.vitalSignCategory);
			var color:uint = 0;
			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(VitalSignForDecisionItemRenderer));
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(color, 6));
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

			_vitalSignsDataCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory.getItem(vitalSignChartDescriptor.vitalSignCategory);
			_vitalSignsDataCollection.addEventListener(CollectionEvent.COLLECTION_CHANGE,
					vitalSignsDataCollection_collectionChangeHandler, false, 0, true);

			var seriesDataCollection:ArrayCollection = createProxiesForDecision(_vitalSignsDataCollection);
			return seriesDataCollection;
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
			insulinDescriptorTemplate.medicationCode = INSULIN_LEVEMIR_CODE;
			var matchingInsulinChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey) as IChartDescriptor;
//			if (matchingInsulinChartDescriptor)
//			{
//				matchingInsulinChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey);
//			}

			var bloodGlucoseDescriptorTemplate:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			bloodGlucoseDescriptorTemplate.vitalSignCategory = VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
			var matchingBloodGlucoseChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(bloodGlucoseDescriptorTemplate.descriptorKey) as IChartDescriptor;

			var reorderedChartDescriptors:OrderedMap = new OrderedMap();
			for each (var otherChartDescriptor:IChartDescriptor in chartDescriptors.values())
			{
				reorderedChartDescriptors.addKeyValue(otherChartDescriptor.descriptorKey, otherChartDescriptor);
			}

			if (matchingInsulinChartDescriptor)
				reorderedChartDescriptors.addKeyValue(matchingInsulinChartDescriptor.descriptorKey, matchingInsulinChartDescriptor);
			if (matchingBloodGlucoseChartDescriptor)
				reorderedChartDescriptors.addKeyValue(matchingBloodGlucoseChartDescriptor.descriptorKey, matchingBloodGlucoseChartDescriptor);

			return reorderedChartDescriptors;
		}

		public override function prepareAdherenceGroup(chartDescriptor:IChartDescriptor, adherenceGroup:Group):void
		{
			//synchronizedHealthCharts:SynchronizedHealthCharts
			if (chartModelDetails.record.healthChartsModel.decisionPending)
			{
				if (adherenceGroup.numElements == 2)
				{
					var extraPanel:IVisualElement;

					if (InsulinTitrationSupportChartModifierFactory.isBloodGlucoseChartDescriptor(chartDescriptor))
					{
						var panel:InsulinTitrationDecisionPanel = new InsulinTitrationDecisionPanel();
						panel.model = _insulinTitrationDecisionPanelModel;
						panel.percentHeight = 100;
						extraPanel = panel;
					}
					else
					{
						var spacerRect:Rect = new Rect();
						spacerRect.width = 478;
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
			// TODO: only average consecutive blood glucose readings in the last 3 days
			_insulinTitrationDecisionPanelModel.isAverageAvailable = !isNaN(_insulinTitrationDecisionPanelModel.bloodGlucoseAverage);
			// TODO: determine whether adherence is perfect
			_insulinTitrationDecisionPanelModel.isAdherencePerfect = true;
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
			}
		}

		override public function save():Boolean
		{
			if (!super.save())
				return false;

			return _insulinTitrationDecisionPanelModel.save();
		}

		private function vitalSignsDataCollection_collectionChangeHandler(event:CollectionEvent):void
		{
		}
	}
}
