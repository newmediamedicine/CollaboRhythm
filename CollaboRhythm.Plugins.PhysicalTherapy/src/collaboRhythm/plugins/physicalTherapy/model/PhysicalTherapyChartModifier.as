package collaboRhythm.plugins.physicalTherapy.model
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MeasurementChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.ChartModifierBase;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.DefaultVitalSignChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.charts.chartClasses.CartesianChart;

	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;

	import mx.core.IVisualElement;
	import mx.graphics.SolidColorStroke;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Group;
	import spark.components.Label;
	import spark.primitives.Rect;

	public class PhysicalTherapyChartModifier extends ChartModifierBase implements IChartModifier
	{

		public function PhysicalTherapyChartModifier(measurementChartDescriptor:MeasurementChartDescriptor,
															 chartModelDetails:IChartModelDetails,
															 currentChartModifier:IChartModifier)
		{
			super(measurementChartDescriptor, chartModelDetails, currentChartModifier);
		}

		public function modifyCartesianChart(chart:ScrubChart, cartesianChart:CartesianChart):void
		{
			return decoratedModifier.modifyCartesianChart(chart, cartesianChart);
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
			// create MeasurementChartDescriptor
		/*	var measurementChartDescriptor:MeasurementChartDescriptor= new MeasurementChartDescriptor();
			measurementChartDescriptor.measurementCode = INSULIN_LEVEMIR_CODE;
			// chart descriptors based on the plan or results
			var matchingInsulinChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey) as IChartDescriptor;
//			if (matchingInsulinChartDescriptor)
//			{
//				matchingInsulinChartDescriptor = chartDescriptors.removeByKey(insulinDescriptorTemplate.descriptorKey);
//			}

			var bloodGlucoseDescriptorTemplate:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			bloodGlucoseDescriptorTemplate.vitalSignCategory = VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
			var matchingBloodGlucoseChartDescriptor:IChartDescriptor = chartDescriptors.removeByKey(bloodGlucoseDescriptorTemplate.descriptorKey) as IChartDescriptor;

			if (matchingInsulinChartDescriptor)
				chartDescriptors.addKeyValue(matchingInsulinChartDescriptor.descriptorKey, matchingInsulinChartDescriptor);
			if (matchingBloodGlucoseChartDescriptor)
				chartDescriptors.addKeyValue(matchingBloodGlucoseChartDescriptor.descriptorKey, matchingBloodGlucoseChartDescriptor);
*/
			return chartDescriptors;
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			var measurementSeries:PlotSeries;
			var seriesDataCollection:ArrayCollection;

			measurementSeries = new PlotSeries();
			measurementSeries.name = "performance";
			measurementSeries.id = chart.id + "_Performance";
			measurementSeries.xField = "dateMeasuredStart";
			measurementSeries.yField = "resultAsNumber";
			seriesDataCollection = chartModelDetails.record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.SYSTOLIC_CATEGORY);
			//seriesDataCollection= new ArrayCollection();
			//seriesDataCollection.addItem();
			measurementSeries.dataProvider = seriesDataCollection;
			measurementSeries.displayName = "Performance";
		//	measurementSeries.setStyle("itemRenderer", new ClassFactory(BloodPressurePlotItemRenderer));
			measurementSeries.filterDataValues = "none";
			measurementSeries.setStyle("stroke", new SolidColorStroke(0x000000, 2));
			seriesDataSets.push(new SeriesDataSet(measurementSeries, seriesDataCollection, "dateMeasuredStart"));

			return seriesDataSets;
		}
	}
}
