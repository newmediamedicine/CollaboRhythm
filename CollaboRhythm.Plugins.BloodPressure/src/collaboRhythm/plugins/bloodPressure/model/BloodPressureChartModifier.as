package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.ui.healthCharts.model.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModifier;

	import mx.charts.chartClasses.Series;

	public class BloodPressureChartModifier implements IChartModifier
	{
		public function BloodPressureChartModifier(chartModelDetails:IChartModelDetails,
												   currentChartModifier:IChartModifier)
		{
		}

		public function createSeriesVector(chartDescriptor:IChartDescriptor):Vector.<Series>
		{
			return null;
		}
	}
}
