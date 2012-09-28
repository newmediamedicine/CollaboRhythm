package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationDecisionPanelModel;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModel;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModelAndController;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationFAQView;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	import spark.components.ViewNavigator;

	public class InsulinTitrationDecisionPanelController
	{
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _model:InsulinTitrationDecisionPanelModel;
		private var _viewNavigator:ViewNavigator;
		private var _synchronizationService:SynchronizationService;

		public function InsulinTitrationDecisionPanelController(collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
																insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel,
																viewNavigator:ViewNavigator)
		{
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_model = insulinTitrationDecisionPanelModel;
			_viewNavigator = viewNavigator;
			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy);
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

		public function showFrequentlyAskedQuestionsView():void
		{
			if (_synchronizationService.synchronize("showFrequentlyAskedQuestionsView"))
			{
				return;
			}

			var insulinTitrationFAQModel:InsulinTitrationFAQModel = new InsulinTitrationFAQModel();
			var insulinTitrationFAQController:InsulinTitrationFAQController = new InsulinTitrationFAQController(insulinTitrationFAQModel,
					_collaborationLobbyNetConnectionServiceProxy);
			var insulinTitrationFAQModelAndController:InsulinTitrationFAQModelAndController = new InsulinTitrationFAQModelAndController(insulinTitrationFAQModel,
					insulinTitrationFAQController);
			_viewNavigator.pushView(InsulinTitrationFAQView, insulinTitrationFAQModelAndController);
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
