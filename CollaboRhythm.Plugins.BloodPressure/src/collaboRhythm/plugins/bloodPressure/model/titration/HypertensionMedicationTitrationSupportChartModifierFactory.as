package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.medications.TitrationHealthActionCreator;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.MedicationChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	import com.theory9.data.types.OrderedMap;

	public class HypertensionMedicationTitrationSupportChartModifierFactory implements IChartModifierFactory
	{
		public function HypertensionMedicationTitrationSupportChartModifierFactory()
		{
		}

		public function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails,
											currentChartModifier:IChartModifier):IChartModifier
		{
			var creator:TitrationHealthActionCreator = new TitrationHealthActionCreator(chartModelDetails.accountId,
					chartModelDetails.record);

			creator.decisionPlanSystem = "CollaboRhythm Hypertension Titration Support";
			creator.decisionPlanName = PersistableHypertensionMedicationTitrationModel.HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME;
			creator.decisionPlanInstructions = "Use CollaboRhythm to follow the algorithm for changing your dose of hypertension medications.";
			creator.indication = "Type II Diabetes Mellitus";

			if (isSystolicChartDescriptor(chartDescriptor) && creator.getTitrationDecisionPlan(false) != null)
				return new HypertensionMedicationTitrationSupportChartModifier(chartDescriptor, chartModelDetails, currentChartModifier);
			else
				return currentChartModifier;
		}

		public static function isSystolicChartDescriptor(chartDescriptor:IChartDescriptor):Boolean
		{
			return chartDescriptor is VitalSignChartDescriptor &&
					(chartDescriptor as VitalSignChartDescriptor).vitalSignCategory ==
							VitalSignsModel.SYSTOLIC_CATEGORY;
		}

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			return null;
		}
	}
}
