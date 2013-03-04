package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationDecisionPanelModel;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModel;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModelAndController;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationFAQView;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.medications.controller.TitrationDecisionPanelControllerBase;

	import spark.components.ViewNavigator;

	public class InsulinTitrationDecisionPanelController extends TitrationDecisionPanelControllerBase
	{
		private var _model:InsulinTitrationDecisionPanelModel;

		public function InsulinTitrationDecisionPanelController(collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
																insulinTitrationDecisionPanelModel:InsulinTitrationDecisionPanelModel,
																viewNavigator:ViewNavigator)
		{
			super(collaborationLobbyNetConnectionServiceProxy, viewNavigator);
			_model = insulinTitrationDecisionPanelModel;
		}

		override public function get modelBase():TitrationDecisionModelBase
		{
			return _model;
		}

		public function setDosageChangeValue(value:Number):void
		{
			if (_synchronizationService.synchronize("setDosageChangeValue", value))
			{
				return;
			}

			_model.dosageChangeValue = value;
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

			var insulinTitrationFAQModel:InsulinTitrationFAQModel = new InsulinTitrationFAQModel();
			var insulinTitrationFAQController:InsulinTitrationFAQController = new InsulinTitrationFAQController(insulinTitrationFAQModel,
					_collaborationLobbyNetConnectionServiceProxy);
			var insulinTitrationFAQModelAndController:InsulinTitrationFAQModelAndController = new InsulinTitrationFAQModelAndController(insulinTitrationFAQModel,
					insulinTitrationFAQController);
			_viewNavigator.pushView(InsulinTitrationFAQView, insulinTitrationFAQModelAndController);
		}

	}
}
