package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.TitratingInsulinHealthActionListViewAdapter;
	import collaboRhythm.shared.model.medications.DecisionScheduleItemOccurrenceFinder;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportHealthActionInputModel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.InsulinTitrationSupportHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	import flash.net.URLVariables;

	import spark.components.Button;

	import spark.components.ViewNavigator;

	public class TitratingInsulinHealthActionInputController extends HealthActionInputControllerBase implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = InsulinTitrationSupportHealthActionInputView;

		public static const INSULIN_TITRATION_BUTTON_ID:String = "insulinTitrationButton";

		private var _dataInputModel:InsulinTitrationSupportHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;
		private var _decoratedHealthActionInputController:IHealthActionInputController;

		public function TitratingInsulinHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																	healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																	viewNavigator:ViewNavigator,
																	collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
																	decoratedHealthActionInputController:IHealthActionInputController)
		{
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;
			_decoratedHealthActionInputController = decoratedHealthActionInputController;
			var decisionScheduleItemOccurrence:ScheduleItemOccurrence = getDecisionScheduleItemOccurrence();
			_dataInputModel = new InsulinTitrationSupportHealthActionInputModel(scheduleItemOccurrence, decisionScheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy,
					_dataInputModel.scheduleItemOccurrence.scheduleItem.meta.id);
		}

		private function getDecisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			var finder:DecisionScheduleItemOccurrenceFinder = new DecisionScheduleItemOccurrenceFinder(_healthActionModelDetailsProvider,
					TitratingInsulinHealthActionListViewAdapter.INSULIN_TITRATION_DECISION_HEALTH_ACTION_SCHEDULE_NAME);
			return finder.getDecisionScheduleItemOccurrence();
		}

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return false;
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			_decoratedHealthActionInputController.handleHealthActionResult(initiatedLocally);
		}

		public function handleHealthActionSelected():void
		{
			_decoratedHealthActionInputController.handleHealthActionSelected();
		}

		public function handleHealthActionCommandButtonClick(event:MouseEvent):void
		{
			var button:Button = event.target as Button;
			if (button && button.id == INSULIN_TITRATION_BUTTON_ID)
			{
				// TODO: only navigate to the charts if there is an annotation icon (there is an decision action from today)
				handleInsulinTitration();
			}
		}

		public function handleInsulinTitration():void
		{
			if (_synchronizationService.synchronize("handleInsulinTitration"))
			{
				return;
			}

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

		public function updateDateMeasuredStart(date:Date):void
		{
		}
	}
}
