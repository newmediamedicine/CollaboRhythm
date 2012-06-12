package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.ui.healthCharts.model.ChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;

	import spark.components.Group;
	import spark.components.View;

	public class ChartModifierBase
	{
		protected var _chartDescriptor:IChartDescriptor;
		private var _chartModelDetails:IChartModelDetails;
		private var _decoratedModifier:IChartModifier;

		public function ChartModifierBase(chartDescriptor:IChartDescriptor,
										  chartModelDetails:IChartModelDetails,
										  decoratedChartModifier:IChartModifier)
		{
			_chartDescriptor = chartDescriptor;
			_chartModelDetails = chartModelDetails;
			_decoratedModifier = decoratedChartModifier;
		}

		public function get chartKey():String
		{
			return _chartDescriptor.descriptorKey;
		}

		public function get chartDescriptor():IChartDescriptor
		{
			return _chartDescriptor;
		}

		public function get decoratedModifier():IChartModifier
		{
			return _decoratedModifier;
		}

		public function get chartModelDetails():IChartModelDetails
		{
			return _chartModelDetails;
		}

		public function prepareAdherenceGroup(chartDescriptor:IChartDescriptor, adherenceGroup:Group):void
		{
		}

		public function set chartModelDetails(chartModelDetails:IChartModelDetails):void
		{
			_chartModelDetails = chartModelDetails;
		}

		public function updateSparkView(view:View):void
		{
		}

		public function save():Boolean
		{
			return true;
		}
	}
}
