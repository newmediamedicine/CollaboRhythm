package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionBase;

	public class HypertensionMedicationTitrationSupportHealthAction extends HealthActionBase
	{
		public static const HEALTH_ACTION_TYPE:String = "Hypertension Medication Titration";

		public function HypertensionMedicationTitrationSupportHealthAction()
		{
			super(HEALTH_ACTION_TYPE);
		}
	}
}
