package collaboRhythm.plugins.bloodPressure.view.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.titration.HypertensionMedicationTitrationDecisionPanelController;
	import collaboRhythm.plugins.bloodPressure.model.titration.PersistableHypertensionMedicationTitrationModel;

	import spark.components.Group;

	public class HypertensionMedicationTitrationDecisionPanel extends Group
	{
		public static const TITRATION_DECISION_PANEL_WIDTH:Number = 567;
		private var _model:PersistableHypertensionMedicationTitrationModel;
		private var _controller:HypertensionMedicationTitrationDecisionPanelController;

		public function HypertensionMedicationTitrationDecisionPanel()
		{
			super();
		}

		public function get model():PersistableHypertensionMedicationTitrationModel
		{
			return _model;
		}

		public function set model(model:PersistableHypertensionMedicationTitrationModel):void
		{
			_model = model;
		}

		public function get controller():HypertensionMedicationTitrationDecisionPanelController
		{
			return _controller;
		}

		public function set controller(controller:HypertensionMedicationTitrationDecisionPanelController):void
		{
			_controller = controller;
		}
	}
}
