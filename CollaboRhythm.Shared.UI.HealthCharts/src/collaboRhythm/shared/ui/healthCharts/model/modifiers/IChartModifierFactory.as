package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.ui.healthCharts.model.*;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;

	/**
	 * Factory interface which a CollaboRhythm plugin can use to provide custom IChartModifier instances.
	 * Each factory can support one or more type of chart descriptors. All registered factories will be given a chance
	 * to create or modify the chart modifier for each chart descriptor.
	 * @see IChartModifier
	 */
	public interface IChartModifierFactory
	{
		/**
		 * Creates or modifies a chart modifier for the specified chartDescriptor. If the factory does not have a
		 * different or modified chart modifier to provide for the specified chartDescriptor it should return the
		 * currentChartModifier instead.
		 * @param chartDescriptor Describes the chart to be modified
		 * @param chartModelDetails Model details to be used in association with the chart
		 * @param currentChartModifier The current chart modifier, which can be extended or referenced when creating the new chart modifier
		 * @return A chart modifier to be used for modifying the chart corresponding to the specified chartDescriptor
		 */
		function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails,
									 currentChartModifier:IChartModifier):IChartModifier;
	}
}
