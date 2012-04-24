package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportChartModifier;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
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
			if (isInsulinChartDescriptor(chartDescriptor))
				return new InsulinTitrationSupportChartModifier(chartDescriptor as MedicationChartDescriptor, chartModelDetails, currentChartModifier);
			else
				return currentChartModifier;
		}

		public static function isInsulinChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return chartDescriptor is MedicationChartDescriptor &&
					(chartDescriptor as MedicationChartDescriptor).medicationCode ==
							InsulinTitrationSupportChartModifier.INSULIN_LEVEMIR_CODE;
		}

		public static function isBloodGlucoseChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return chartDescriptor is VitalSignChartDescriptor &&
					(chartDescriptor as VitalSignChartDescriptor).vitalSignCategory ==
							VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
		}
	}
}
