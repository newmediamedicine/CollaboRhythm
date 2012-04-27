package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	public class InsulinTitrationSupportChartModifierFactory implements IChartModifierFactory
	{
		public function InsulinTitrationSupportChartModifierFactory()
		{
		}

		public function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails,
											currentChartModifier:IChartModifier):IChartModifier
		{
			if (chartDescriptor is MedicationChartDescriptor &&
					(chartDescriptor as MedicationChartDescriptor).medicationCode == InsulinTitrationSupportChartModifier.INSULIN_LEVEMIR_CODE)
				return new InsulinTitrationSupportChartModifier(chartDescriptor as MedicationChartDescriptor, chartModelDetails, currentChartModifier);
			else
				return currentChartModifier;
		}
	}
}
