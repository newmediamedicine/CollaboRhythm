package collaboRhythm.plugins.medications.controller
{
	import collaboRhythm.plugins.medications.model.MedicationHealthActionInputModel;
	import collaboRhythm.plugins.medications.view.MedicationHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class MedicationHealthActionInputController implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = MedicationHealthActionInputView;

		private var _dataInputModel:MedicationHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function MedicationHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															  viewNavigator:ViewNavigator)
		{
			_dataInputModel = new MedicationHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider);
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = healthActionModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy;
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
			addCollaborationViewSynchronizationEventListener();
			_dataInputModel.handleHealthActionResult(initiatedLocally);
		}

		public function handleHealthActionSelected():void
		{
			addCollaborationViewSynchronizationEventListener();
			var healthActionInputModelAndController:HealthActionInputModelAndController = new HealthActionInputModelAndController(_dataInputModel,
					this);
			_viewNavigator.pushView(MedicationHealthActionInputView, healthActionInputModelAndController);
		}

		public function handleUrlVariables(urlVariables:URLVariables):void
		{
			addCollaborationViewSynchronizationEventListener();
		}

		public function get healthActionInputViewClass():Class
		{
			return HEALTH_ACTION_INPUT_VIEW_CLASS;
		}

		public function useDefaultHandleHealthActionResult():Boolean
		{
			return false;
		}

		public function addCollaborationViewSynchronizationEventListener():void
		{
			if (!_synchronizationService)
			{
				_synchronizationService = new SynchronizationService(this,
						_collaborationLobbyNetConnectionServiceProxy);
			}
		}

		public function removeCollaborationViewSynchronizationEventListener():void
		{
			if (_synchronizationService)
			{
				if (_synchronizationService.synchronize("removeCollaborationViewSynchronizationEventListener"))
				{
					return;
				}

				_synchronizationService.removeEventListener(this);
			}
		}

		public function createAndSaveMedicationAdministration(selectedDate:Date):void
		{
			if (_synchronizationService.synchronize("createAndSaveMedicationAdministration", selectedDate))
			{
				return;
			}

			_dataInputModel.createMedicationAdministration(_synchronizationService.initiatedLocally, selectedDate);

			if (_synchronizationService.initiatedLocally)
			{
				_dataInputModel.saveAllChanges();
				_viewNavigator.popView();
				removeCollaborationViewSynchronizationEventListener();
			}
		}

		public function updateDateMeasuredStart(date:Date):void
		{
		}
	}
}
