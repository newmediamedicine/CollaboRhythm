package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.plugins.bloodPressure.controller.BloodPressureMedicationTitrationFAQController;

	public class BloodPressureMedicationTitrationFAQModelAndController
	{
		private var _bloodPressureMedicationTitrationFAQModel:BloodPressureMedicationTitrationFAQModel;
		private var _bloodPressureMedicationTitrationFAQController:BloodPressureMedicationTitrationFAQController;

		public function BloodPressureMedicationTitrationFAQModelAndController(bloodPressureMedicationTitrationFAQModel:BloodPressureMedicationTitrationFAQModel,
															  bloodPressureMedicationTitrationFAQController:BloodPressureMedicationTitrationFAQController)
		{
			_bloodPressureMedicationTitrationFAQModel = bloodPressureMedicationTitrationFAQModel;
			_bloodPressureMedicationTitrationFAQController = bloodPressureMedicationTitrationFAQController;
		}

		public function get bloodPressureMedicationTitrationFAQModel():BloodPressureMedicationTitrationFAQModel
		{
			return _bloodPressureMedicationTitrationFAQModel;
		}

		public function get bloodPressureMedicationTitrationFAQController():BloodPressureMedicationTitrationFAQController
		{
			return _bloodPressureMedicationTitrationFAQController;
		}
	}
}

