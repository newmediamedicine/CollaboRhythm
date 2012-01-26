package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;

	public class DefaultChartModifierFactory implements IChartModifierFactory
	{
		public function DefaultChartModifierFactory()
		{
		}

		public function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails,
											currentChartModifier:IChartModifier):IChartModifier
		{
			if (chartDescriptor is MedicationChartDescriptor)
			{
				return new DefaultMedicationChartModifier(chartDescriptor as MedicationChartDescriptor, chartModelDetails, currentChartModifier);
			}
			else if (chartDescriptor is VitalSignChartDescriptor)
			{
				return new DefaultVitalSignChartModifier(chartDescriptor as VitalSignChartDescriptor, chartModelDetails, currentChartModifier);
			}
			return currentChartModifier;
		}
	}
}
