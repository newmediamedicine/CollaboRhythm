package collaboRhythm.shared.ui.healthCharts.view
{
	import mx.charts.LineChart;

	/**
	 * Special version of the LineChart which eliminates the mask used for series (plotting items) so that items can
	 * extend beyond the chart.
	 */
	public class LineChartEx extends LineChart
	{
		public function LineChartEx()
		{
		}

		protected override function updateDisplayList(
		        unscaledWidth:Number, unscaledHeight:Number):void
		{
		    super.updateDisplayList(unscaledWidth, unscaledHeight);

			_seriesHolder.mask = null;
		}
	}
}
