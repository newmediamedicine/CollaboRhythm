package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.charts.chartClasses.CartesianChart;
	import mx.core.IVisualElement;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Label;

	public class DefaultChartModifier extends ChartModifierBase implements IChartModifier
	{
		public function DefaultChartModifier(chartDescriptor:IChartDescriptor,
														   chartModelDetails:IChartModelDetails,
														   decoratedChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, decoratedChartModifier);
		}

		public function modifyCartesianChart(chart:ScrubChart,
											 cartesianChart:CartesianChart,
											 isMainChart:Boolean):void
		{
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			return seriesDataSets;
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			return currentChartImage;
		}

		public function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void
		{
		}

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			return chartDescriptors;
		}
	}
}
