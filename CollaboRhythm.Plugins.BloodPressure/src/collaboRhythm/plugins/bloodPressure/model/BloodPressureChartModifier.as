package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureDiastolicPlotItemRenderer;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressurePlotItemRenderer;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureScheduleItemClockView;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.ChartModifierBase;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.charts.HitData;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.Series;
	import mx.charts.series.PlotSeries;
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IVisualElement;
	import mx.graphics.SolidColorStroke;

	import qs.charts.dataShapes.DataDrawingCanvas;
	import qs.charts.dataShapes.Edge;

	import spark.components.Label;

	public class BloodPressureChartModifier extends ChartModifierBase implements IChartModifier
	{
		private static const BLOOD_PRESSURE_VERTICAL_AXIS_MAXIMUM:Number = 180;
		private static const BLOOD_PRESSURE_VERTICAL_AXIS_MINIMUM:Number = 40;

		protected const GOAL_ZONE_COLOR:uint = 0x8DCB86;

		public function BloodPressureChartModifier(chartDescriptor:VitalSignChartDescriptor,
												   chartModelDetails:IChartModelDetails,
												   decoratedChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, decoratedChartModifier)
		}

		protected function get vitalSignChartDescriptor():VitalSignChartDescriptor
		{
			return chartDescriptor as VitalSignChartDescriptor;
		}

		private function bloodPressureChart_dataTipFunction(hitData:HitData):String
		{
			var vitalSign:VitalSign = hitData.item as VitalSign;
			if (vitalSign)
			{
				return (hitData.chartItem.element as Series).displayName + "<br/>" +
						"<b>" + vitalSign.result.value + "</b> (" + vitalSign.result.unit.abbrev + ")<br/>" +
						"Date measured: " + vitalSign.dateMeasuredStart.toLocaleString();
			}
			return hitData.displayText;
		}

		public function modifyMainChart(chart:ScrubChart):void
		{
			if (decoratedModifier)
				decoratedModifier.modifyMainChart(chart);
			chart.mainChartTitle = "Blood Pressure (mmHg)";

			var verticalAxis:LinearAxis = chart.mainChart.verticalAxis as LinearAxis;
			verticalAxis.minimum = BLOOD_PRESSURE_VERTICAL_AXIS_MINIMUM;
			verticalAxis.maximum = BLOOD_PRESSURE_VERTICAL_AXIS_MAXIMUM;
			if (chart.mainChartCover)
			{
				verticalAxis = chart.mainChartCover.verticalAxis as LinearAxis;
				verticalAxis.minimum = BLOOD_PRESSURE_VERTICAL_AXIS_MINIMUM;
				verticalAxis.maximum = BLOOD_PRESSURE_VERTICAL_AXIS_MAXIMUM;
			}

			chart.mainChart.dataTipFunction = bloodPressureChart_dataTipFunction;
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			var vitalSignSeries:PlotSeries;
			var seriesDataCollection:ArrayCollection;

			vitalSignSeries = new PlotSeries();
			vitalSignSeries.name = "systolic";
			vitalSignSeries.id = chart.id + "_systolicSeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			seriesDataCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory.getItem(VitalSignsModel.SYSTOLIC_CATEGORY);
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = "Blood Pressure Systolic";
			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(BloodPressurePlotItemRenderer));
			vitalSignSeries.filterDataValues = "none";
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(0x000000, 2));
			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));

			vitalSignSeries = new PlotSeries();
			vitalSignSeries.name = "diastolic";
			vitalSignSeries.id = chart.id + "_diastolicSeries";
			vitalSignSeries.xField = "dateMeasuredStart";
			vitalSignSeries.yField = "resultAsNumber";
			seriesDataCollection = chartModelDetails.record.vitalSignsModel.vitalSignsByCategory.getItem(VitalSignsModel.DIASTOLIC_CATEGORY);
			vitalSignSeries.dataProvider = seriesDataCollection;
			vitalSignSeries.displayName = "Blood Pressure Diastolic";
			vitalSignSeries.setStyle("itemRenderer", new ClassFactory(BloodPressureDiastolicPlotItemRenderer));
			vitalSignSeries.filterDataValues = "none";
			vitalSignSeries.setStyle("stroke", new SolidColorStroke(0x808080, 2));
			seriesDataSets.push(new SeriesDataSet(vitalSignSeries, seriesDataCollection, "dateMeasuredStart"));

			return seriesDataSets;
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			var image:BloodPressureScheduleItemClockView = new BloodPressureScheduleItemClockView();
			image.width = 100;
			image.height = 100;
			image.verticalCenter = 100;
			return image;
		}

		public function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void
		{
			canvas.clear();

			var color:uint = GOAL_ZONE_COLOR;
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

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			var diastolicDescriptor:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			diastolicDescriptor.vitalSignCategory = VitalSignsModel.DIASTOLIC_CATEGORY;
			chartDescriptors.removeByKey(diastolicDescriptor.descriptorKey);
			return chartDescriptors;
		}
	}
}
