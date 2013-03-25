package collaboRhythm.plugins.medications.controller
{
	import collaboRhythm.plugins.medications.model.MedicationHealthActionInputModel;
	import collaboRhythm.plugins.medications.view.MedicationHealthActionInputView;
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelAndController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import com.adobe.nativeExtensions.Vibration;

	import flash.events.MouseEvent;

	import flash.net.URLVariables;

	import spark.components.ViewNavigator;

	public class MedicationHealthActionInputController extends HealthActionInputControllerBase implements IHealthActionInputController
	{
		private const HEALTH_ACTION_INPUT_VIEW_CLASS:Class = MedicationHealthActionInputView;

		private var _dataInputModel:MedicationHealthActionInputModel;
		private var _viewNavigator:ViewNavigator;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;

		public function MedicationHealthActionInputController(scheduleItemOccurrence:ScheduleItemOccurrence,
															  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															  scheduleCollectionsProvider:IScheduleCollectionsProvider,
															  viewNavigator:ViewNavigator)
		{
			_dataInputModel = new MedicationHealthActionInputModel(scheduleItemOccurrence,
					healthActionModelDetailsProvider, scheduleCollectionsProvider);
			_viewNavigator = viewNavigator;

			_collaborationLobbyNetConnectionServiceProxy = healthActionModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy;
		}

		public function handleHealthActionResult(initiatedLocally:Boolean):void
		{
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

		public function createAndSaveMedicationAdministration():void
		{
			addCollaborationViewSynchronizationEventListener();
			if (_synchronizationService.synchronize("createAndSaveMedicationAdministration"))
			{
				return;
			}

			_dataInputModel.createMedicationAdministration(_synchronizationService.initiatedLocally);

			if (_synchronizationService.initiatedLocally)
			{
				_dataInputModel.saveAllChanges();
				_viewNavigator.popView();
				removeCollaborationViewSynchronizationEventListener();
			}
		}

		public function updateDateMeasuredStart(date:Date):void
		{
			addCollaborationViewSynchronizationEventListener();
			if (_synchronizationService.synchronize("updateDateMeasuredStart", date))
			{
				return;
			}

			_dataInputModel.dateMeasuredStart = date;
		}

		public function playVideo(instructionalVideoPath:String):void
				{
					// TODO: Currently using the vibration native extension with modifications to play a video
					var vibration:Vibration = new (Vibration);
					vibration.vibrate(instructionalVideoPath, "video/*");
				}

		public function handleHealthActionCommandButtonClick(event:MouseEvent):void
		{
		}
	}
}
