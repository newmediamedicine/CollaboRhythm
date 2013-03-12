package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.BloodPressureMedicationTitrationFAQController;
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModel;
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModelAndController;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationActionSynchronizationDetails;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationTitrationModel;
	import collaboRhythm.plugins.bloodPressure.model.titration.PersistableHypertensionMedicationTitrationModel;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMedicationTitrationFAQView;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.controller.TitrationDecisionPanelControllerBase;

	import spark.components.ViewNavigator;

	public class HypertensionMedicationTitrationDecisionPanelController extends TitrationDecisionPanelControllerBase implements ITitrationMapController
	{
		private var _model:PersistableHypertensionMedicationTitrationModel;

		public function HypertensionMedicationTitrationDecisionPanelController(collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
																			   model:PersistableHypertensionMedicationTitrationModel,
																			   viewNavigator:ViewNavigator)
		{
			super(collaborationLobbyNetConnectionServiceProxy, viewNavigator);
			_model = model;
		}

		override public function get modelBase():TitrationDecisionModelBase
		{
			return _model;
		}

		override public function send():void
		{
			_model.record.healthChartsModel.save();
		}

		override public function showFaq():void
		{
			if (_synchronizationService.synchronize("showFaq"))
			{
				return;
			}

			var faqModel:BloodPressureMedicationTitrationFAQModel = new BloodPressureMedicationTitrationFAQModel();
			var faqController:BloodPressureMedicationTitrationFAQController = new BloodPressureMedicationTitrationFAQController(faqModel,
					_collaborationLobbyNetConnectionServiceProxy);
			var faqModelAndController:BloodPressureMedicationTitrationFAQModelAndController = new BloodPressureMedicationTitrationFAQModelAndController(faqModel,
					faqController);
			_viewNavigator.pushView(BloodPressureMedicationTitrationFAQView, faqModelAndController);
		}

		public function toggleMapViewVisibility():void
		{
			if (_synchronizationService.synchronize("toggleMapViewVisibility"))
			{
				return;
			}

			model.isMapViewVisible = !model.isMapViewVisible;
		}

		public function handleHypertensionMedicationDoseSelected(hypertensionMedicationActionSynchronizationDetails:HypertensionMedicationActionSynchronizationDetails):void
		{
			if (_synchronizationService.synchronize("handleHypertensionMedicationDoseSelected",
					hypertensionMedicationActionSynchronizationDetails))
			{
				return;
			}

			model.handleHypertensionMedicationDoseSelected(hypertensionMedicationActionSynchronizationDetails);
		}

		public function handleHypertensionMedicationAlternateSelected(hypertensionMedicationActionSynchronizationDetails:HypertensionMedicationActionSynchronizationDetails):void
		{
			if (_synchronizationService.synchronize("handleHypertensionMedicationAlternateSelected",
					hypertensionMedicationActionSynchronizationDetails))
			{
				return;
			}

			model.handleHypertensionMedicationAlternateSelected(hypertensionMedicationActionSynchronizationDetails);
		}

		public function save():Boolean
		{
			_model.record.healthChartsModel.save();
			return false;
		}

		public function get model():HypertensionMedicationTitrationModel
		{
			return _model;
		}
	}
}
