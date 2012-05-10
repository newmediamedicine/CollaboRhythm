package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationDecisionPanel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.TitrationPanelMockup;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.ChartModelDetails;
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

	import mx.collections.ArrayCollection;

	import mx.core.IVisualElement;
	import mx.core.UIComponent;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Group;
	import spark.components.Label;
	import spark.primitives.Rect;

	public class InsulinTitrationSupportChartModifier extends ChartModifierBase implements IChartModifier
	{
		public static const INSULIN_LEVEMIR_CODE:String = "847241";

		public function InsulinTitrationSupportChartModifier(medicationChartDescriptor:MedicationChartDescriptor,
															 chartModelDetails:IChartModelDetails,
															 currentChartModifier:IChartModifier)
		{
			super(medicationChartDescriptor, chartModelDetails, currentChartModifier);
		}

		public function modifyMainChart(chart:ScrubChart):void
		{
			return decoratedModifier.modifyMainChart(chart);
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			return decoratedModifier.createMainChartSeriesDataSets(chart, seriesDataSets);
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

		private var _insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel;

		public override function prepareAdherenceGroup(chartDescriptor:IChartDescriptor, adherenceGroup:Group):void
		{
			//synchronizedHealthCharts:SynchronizedHealthCharts
//			for each (var adherenceGroup:Group in synchronizedHealthCharts.adherenceGroups.values())
//			{
//				for each (var chart:TouchScrollingScrubChart in getChartsInGroup(adherenceGroup))
//				{
//				}
			if (chartModelDetails.record.healthChartsModel.decisionPending)
			{
				if (adherenceGroup.numElements == 2)
				{
					var extraPanel:IVisualElement;

					if (InsulinTitrationSupportChartModifierFactory.isBloodGlucoseChartDescriptor(chartDescriptor))
					{
						var panel:InsulinTitrationDecisionPanel = new InsulinTitrationDecisionPanel();
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
//			}
		}


		override public function set chartModelDetails(chartModelDetails:IChartModelDetails):void
		{
			super.chartModelDetails = chartModelDetails;
			if (_insulinTitrationDecisionPanelModel)
			{
				_insulinTitrationDecisionPanelModel.chartModelDetails = chartModelDetails;
			}
		}
	}
}
