package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModifierFactory;
	import collaboRhythm.shared.ui.healthCharts.model.VitalSignChartDescriptor;

	public class BloodPressureChartModifierFactory implements IChartModifierFactory
	{
		public function BloodPressureChartModifierFactory()
		{
		}

		public function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails, currentChartModifier:IChartModifier):IChartModifier
		{
			if (chartDescriptor is VitalSignChartDescriptor && (chartDescriptor as VitalSignChartDescriptor).vitalSignCategory == VitalSignsModel.SYSTOLIC_CATEGORY)
				return new BloodPressureChartModifier(chartModelDetails, currentChartModifier);
			else
				return currentChartModifier;
		}
	}
}
