package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationTitrationSupportHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.events.MouseEvent;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class HypertensionMedicationTitrationSupportHealthActionInputController extends HealthActionInputControllerBase implements IHealthActionInputController
	{
		private var _dataInputModel:HypertensionMedicationTitrationSupportHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function HypertensionMedicationTitrationSupportHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
																		   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																		   viewNavigator:ViewNavigator,
																		   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_dataInputModel = new HypertensionMedicationTitrationSupportHealthActionInputModel(scheduleItemOccurrence, scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;

			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy);
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			prepareChartsForDecision();
			showCharts();
		}

		public function handleHealthActionSelected():void
		{
			if (prepareChartsForDecision())
				showCharts();
		}

		public function prepareChartsForDecision():Boolean
		{
			return _dataInputModel.prepareChartsForDecision();
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

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return false;
		}

		public function updateDateMeasuredStart(date:Date):void
		{
		}

		public function handleHealthActionCommandButtonClick(event:MouseEvent):void
		{
		}
	}
}
