package collaboRhythm.plugins.problems.HIV.model
{
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.ui.healthCharts.model.IChartModelDetails;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.IChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.descriptors.VitalSignChartDescriptor;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifier;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	import com.theory9.data.types.OrderedMap;


	public class HIVChartModifierFactory implements IChartModifierFactory
	{
		public function HIVChartModifierFactory()
		{

		}

		public function updateChartDescriptors(chartDescriptors:OrderedMap):OrderedMap
		{
			return null;
		}

		public function createChartModifier(chartDescriptor:IChartDescriptor, chartModelDetails:IChartModelDetails,
											currentChartModifier:IChartModifier):IChartModifier
		{
			if (chartDescriptor is VitalSignChartDescriptor &&
					(((chartDescriptor as VitalSignChartDescriptor).vitalSignCategory ==
							VitalSignsModel.TCELL_COUNT_CATEGORY) ||
							((chartDescriptor as VitalSignChartDescriptor).vitalSignCategory ==
									VitalSignsModel.VIRAL_LOAD_CATEGORY)))
			{
				return new HIVChartModifier(chartDescriptor as VitalSignChartDescriptor, chartModelDetails,
						currentChartModifier);
			}
			else
			{
				return currentChartModifier;
			}
		}
	}
}
