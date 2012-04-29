package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;

	import com.dougmccune.controls.ScrubChart;
	import com.dougmccune.controls.SeriesDataSet;
	import com.theory9.data.types.OrderedMap;

	import mx.core.IVisualElement;

	import qs.charts.dataShapes.DataDrawingCanvas;

	import spark.components.Group;
	import spark.components.Label;

	public interface IChartModifier
	{
		function get chartKey():String;

		/**
		 * Modifies the mainChart of the result chart (such as medication concentration chart or vital sign plot chart).
		 * This will get called once for the result ScrubChart in an adherence chart group of the health charts
		 * when the mainChart part of the ScrubChart skin is added.
		 * A modifier can change such things as the vertical axis limits (chart.mainChart.verticalAxis) and the
		 * tooltip (chart.mainChart.dataTipFunction).
		 * @param chart
		 */
		function modifyMainChart(chart:ScrubChart):void;

		/**
		 * Creates or modifies the set of series (and associated data collection and data field for that each series)
		 * to be used with the main chart.
		 * @param chart
		 * @param seriesDataSets
		 * @return
		 */
		function createMainChartSeriesDataSets(chart:ScrubChart,
											   seriesDataSets:Vector.<SeriesDataSet>):Vector.<SeriesDataSet>;

		/**
		 * Creates or modifies the image to be used to the left of the chart to visually identify the contents of the
		 * chart. Image could be the scheduled medication or the equipment used to capture the vital sign.
		 * @param currentChartImage The current image (if any), to allow chaining/decorating of modifiers
		 * @return The new/modified image to use (if any)
		 */
		function createImage(currentChartImage:IVisualElement):IVisualElement;

		/**
		 * Draws background elements, such as the goal region.
		 * @param canvas Canvas to draw on
		 * @param zoneLabel Label to position. Might be null depending on the skin used.
		 */
		function drawBackgroundElements(canvas:DataDrawingCanvas, zoneLabel:Label):void;

		/**
		 * Updates the set of chart descriptors which will be used to create charts.
		 * Descriptors can be removed or reordered. Adding new descriptors is not currently supported.
		 * @param chartDescriptors the current set of chart descriptors
		 * @return the new set of chart descriptors
		 */
		function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap;

		function prepareAdherenceGroup(chartDescriptor:IChartDescriptor, adherenceGroup:Group):void;

		function set chartModelDetails(chartModelDetails:IChartModelDetails):void;
	}
}
