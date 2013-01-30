package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	import com.theory9.data.types.OrderedMap;

	public class InsulinTitrationSupportChartModifierFactory implements IChartModifierFactory
	{
		public function InsulinTitrationSupportChartModifierFactory()
		{
		}

		public function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails,
											currentChartModifier:IChartModifier):IChartModifier
		{
			if (isBloodGlucoseChartDescriptor(chartDescriptor) && recordContainsInsulin(chartModelDetails))
				return new InsulinTitrationSupportChartModifier(chartDescriptor, chartModelDetails, currentChartModifier);
			else
				return currentChartModifier;
		}

		private function recordContainsInsulin(chartModelDetails:IChartModelDetails):Boolean
		{
			// TODO: the MedicationOrdersModel could provide a more efficient way to check for the presence of a given medication
			for each (var medicationOrder:MedicationOrder in chartModelDetails.record.medicationOrdersModel.medicationOrdersCollection)
			{
				if (InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES.indexOf(medicationOrder.name.value) != -1)
					return true;
			}
			return false;
		}

		public static function isInsulinChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return chartDescriptor is MedicationChartDescriptor &&
				InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES.indexOf((chartDescriptor as MedicationChartDescriptor).medicationCode) != -1;
		}

		public static function isBloodGlucoseChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return chartDescriptor is VitalSignChartDescriptor &&
					(chartDescriptor as VitalSignChartDescriptor).vitalSignCategory ==
							VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
		}

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			return null;
		}
	}
}
