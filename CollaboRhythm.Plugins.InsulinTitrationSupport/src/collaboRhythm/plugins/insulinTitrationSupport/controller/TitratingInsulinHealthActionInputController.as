package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.DecisionScheduleItemOccurrenceFinder;
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

	public class TitratingInsulinHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = InsulinTitrationSupportHealthActionInputView;

		private var _dataInputModel:InsulinTitrationSupportHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;

		public function TitratingInsulinHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																		   viewNavigator:ViewNavigator,
																		   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence = getDecisionScheduleItemOccurrence();
			_dataInputModel = new InsulinTitrationSupportHealthActionInputModel(scheduleItemOccurrence, decisionScheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);
		}

		private function getDecisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			var finder:DecisionScheduleItemOccurrenceFinder = new DecisionScheduleItemOccurrenceFinder(_healthActionModelDetailsProvider);
			return finder.getDecisionScheduleItemOccurrence();
		}

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return true;
		}

		public function handleHealthActionResult():void
		{
			// TODO: allow the default to happen (report medication taken)
		}

		public function handleHealthActionSelected():void
		{
			// TODO: only navigate to the charts if there is an annotation icon (there is an decision action from today)
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
