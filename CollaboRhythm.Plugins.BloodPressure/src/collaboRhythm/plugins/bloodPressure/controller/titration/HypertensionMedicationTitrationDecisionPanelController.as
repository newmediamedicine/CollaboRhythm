package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.controller.BloodPressureMedicationTitrationFAQController;
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModel;
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModelAndController;
	import collaboRhythm.plugins.bloodPressure.model.titration.PersistableHypertensionMedicationTitrationModel;
	import collaboRhythm.plugins.bloodPressure.view.BloodPressureMedicationTitrationFAQView;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import spark.components.ViewNavigator;

	public class HypertensionMedicationTitrationDecisionPanelController
	{
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _model:PersistableHypertensionMedicationTitrationModel;
		private var _viewNavigator:ViewNavigator;
		private var _synchronizationService:SynchronizationService;

		public function HypertensionMedicationTitrationDecisionPanelController(collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
																model:PersistableHypertensionMedicationTitrationModel,
																viewNavigator:ViewNavigator)
		{
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_model = model;
			_viewNavigator = viewNavigator;
			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy);
		}

		public function send():void
		{
			_model.record.healthChartsModel.save();
		}

		public function showFaq():void
		{
			if (_synchronizationService.synchronize("showFaq"))
			{
				return;
			}

			var insulinTitrationFAQModel:BloodPressureMedicationTitrationFAQModel = new BloodPressureMedicationTitrationFAQModel();
			var insulinTitrationFAQController:BloodPressureMedicationTitrationFAQController = new BloodPressureMedicationTitrationFAQController(insulinTitrationFAQModel,
					_collaborationLobbyNetConnectionServiceProxy);
			var insulinTitrationFAQModelAndController:BloodPressureMedicationTitrationFAQModelAndController = new BloodPressureMedicationTitrationFAQModelAndController(insulinTitrationFAQModel,
					insulinTitrationFAQController);
			_viewNavigator.pushView(BloodPressureMedicationTitrationFAQView, insulinTitrationFAQModelAndController);
		}

		public function setInstructionsScrollPosition(instructionsScrollPosition:Number):void
		{
			if (_synchronizationService.synchronize("setInstructionsScrollPosition",
					instructionsScrollPosition, false))
			{
				return;
			}

			_model.instructionsScrollPosition = instructionsScrollPosition;
		}

		public function destroy():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
				_synchronizationService = null;
			}
		}
	}
}
