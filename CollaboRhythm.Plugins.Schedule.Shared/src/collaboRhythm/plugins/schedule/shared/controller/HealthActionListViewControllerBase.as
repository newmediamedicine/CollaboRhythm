package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.CollaborationViewSynchronizationEvent;

	import com.adobe.nativeExtensions.Vibration;

	import flash.utils.getQualifiedClassName;

	public class HealthActionListViewControllerBase implements IHealthActionListViewController
	{
		private var _healthActionListViewModel:IHealthActionListViewModel;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;

		public function HealthActionListViewControllerBase(healthActionListViewModel:IHealthActionListViewModel)
		{
			_healthActionListViewModel = healthActionListViewModel;

			_collaborationLobbyNetConnectionServiceProxy = _healthActionListViewModel.healthActionInputModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_collaborationLobbyNetConnectionServiceProxy.addEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			if (event.synchronizeData &&
					event.synchronizeData as String ==
							_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.getScheduleActionId())
			{
				this[event.synchronizeFunction](CollaborationLobbyNetConnectionServiceProxy.REMOTE);
			}
		}

		public function handleHealthActionResult(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"handleHealthActionResult",
						_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.getScheduleActionId());
			}

			if (_healthActionListViewModel.scheduleItemOccurrence &&
					_healthActionListViewModel.scheduleItemOccurrence.adherenceItem)
			{
				_healthActionListViewModel.voidHealthActionResult();
			}
			else
			{
				if (_healthActionListViewModel.healthActionInputController)
				{
					_healthActionListViewModel.healthActionInputController.handleHealthActionResult();
				}
				else
				{
					_healthActionListViewModel.createHealthActionResult();
				}
			}
		}

		public function handleHealthActionSelected(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxy.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxy.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"handleHealthActionSelected",
						_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.getScheduleActionId());
			}

			if (_healthActionListViewModel.healthActionInputController)
			{
				_healthActionListViewModel.healthActionInputController.handleHealthActionSelected();
			}
		}

		public function playVideo(instructionalVideoPath:String):void
		{
			// TODO: Currently using the vibration native extension with modifications to play a video
			var vibration:Vibration = new Vibration();
			vibration.vibrate(instructionalVideoPath, "video/*");
		}

		public function removeEventListener():void
		{
			_collaborationLobbyNetConnectionServiceProxy.removeEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);
		}
	}
}
