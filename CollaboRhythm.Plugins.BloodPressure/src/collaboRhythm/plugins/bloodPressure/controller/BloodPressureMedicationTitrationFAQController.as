package collaboRhythm.plugins.bloodPressure.controller
{
	import collaboRhythm.plugins.bloodPressure.model.BloodPressureMedicationTitrationFAQModel;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	public class BloodPressureMedicationTitrationFAQController
	{
		private var _bloodPressureMedicationTitrationFAQModel:BloodPressureMedicationTitrationFAQModel;
		private var _synchronizationService:SynchronizationService;

		public function BloodPressureMedicationTitrationFAQController(bloodPressureMedicationTitrationFAQModel:BloodPressureMedicationTitrationFAQModel,
													  collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_bloodPressureMedicationTitrationFAQModel = bloodPressureMedicationTitrationFAQModel;

			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy);
		}

		public function setFaqRichEditableTextScrollPosition(verticalScrollPosition:Number):void
		{
			if (_synchronizationService.synchronize("setFaqRichEditableTextScrollPosition",
					verticalScrollPosition, false))
			{
				return;
			}

			_bloodPressureMedicationTitrationFAQModel.setFaqRichEditableTextScrollPosition(verticalScrollPosition);
		}

		public function removeSynchronizationServiceEventListener():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
			}
		}
	}
}
