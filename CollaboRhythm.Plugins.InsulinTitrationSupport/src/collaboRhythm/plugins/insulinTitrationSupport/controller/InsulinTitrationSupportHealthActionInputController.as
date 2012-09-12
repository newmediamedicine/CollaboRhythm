package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportHealthActionInputModel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationSupportHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class InsulinTitrationSupportHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = InsulinTitrationSupportHealthActionInputView;

		private var _dataInputModel:InsulinTitrationSupportHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function InsulinTitrationSupportHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																		   viewNavigator:ViewNavigator,
																		   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_dataInputModel = new InsulinTitrationSupportHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);
		}

		public function handleHealthActionResult():void
		{
			prepareChartsForDecision();
			showCharts();
		}

		public function handleHealthActionSelected():void
		{
			prepareChartsForDecision();
			showCharts();
		}

		public function prepareChartsForDecision():void
		{
			_dataInputModel.prepareChartsForDecision();
		}

		public function showCharts():void
		{
			_dataInputModel.showCharts();
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
		}

		public function get healthActionInputViewClass():Class
		{
			return null;
		}
	}
}
