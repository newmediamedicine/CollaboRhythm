package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationDecisionPanelModel;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	public class InsulinTitrationDecisionPanelController
	{
		private var _model:InsulinTitrationDecisionPanelModel;
		private var _synchronizationService:SynchronizationService;

		public function InsulinTitrationDecisionPanelController(collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
																insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel)
		{
			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy as
							CollaborationLobbyNetConnectionServiceProxy);
			_model = insulinTitrationDecisionPanelModel;
		}

		public function setDosageChangeValue(value:Number):void
		{
			if (_synchronizationService.synchronize("setDosageChangeValue", value))
			{
				return;
			}

			_model.dosageChangeValue = value;
		}

		public function send():void
		{
			_model.record.healthChartsModel.save();
		}

		public function destroy():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
			}
		}
	}
}
