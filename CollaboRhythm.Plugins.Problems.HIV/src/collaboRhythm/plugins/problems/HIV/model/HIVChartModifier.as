package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.ChartModifierBase;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.charts.chartClasses.CartesianChart;
	import mx.core.IVisualElement;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Label;

	public class HIVChartModifier extends ChartModifierBase implements IChartModifier
	{
		public function HIVChartModifier(chartDescriptor:VitalSignChartDescriptor, chartModelDetails:IChartModelDetails,
										 decoratedChartModifier:IChartModifier)
		{
			super(chartDescriptor, chartModelDetails, decoratedChartModifier)
		}

		public function modifyCartesianChart(chart:ScrubChart, cartesianChart:CartesianChart, isMainChart:Boolean):void
		{
		}

		public function createMainChartSeriesDataSets(chart:ScrubChart,
													  seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>
		{
			return null;
		}

		public function createImage(currentChartImage:IVisualElement):IVisualElement
		{
			return null;
		}

		public function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void
		{
		}

		override public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			var viralLoadDescriptor:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			viralLoadDescriptor.vitalSignCategory = VitalSignsModel.VIRAL_LOAD_CATEGORY;
			chartDescriptors.removeByKey(viralLoadDescriptor.descriptorKey);
			var tCellCountDescriptor:VitalSignChartDescriptor = new VitalSignChartDescriptor();
			tCellCountDescriptor.vitalSignCategory = VitalSignsModel.TCELL_COUNT_CATEGORY;
			chartDescriptors.removeByKey(tCellCountDescriptor.descriptorKey);
			return chartDescriptors;
		}
	}
}
