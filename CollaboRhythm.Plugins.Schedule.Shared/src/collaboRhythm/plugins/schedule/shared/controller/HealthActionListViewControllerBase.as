package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;

	import com.adobe.nativeExtensions.Vibration;

	public class HealthActionListViewControllerBase implements IHealthActionListViewController
	{
		private var _healthActionListViewModel:IHealthActionListViewModel;
		private var _collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;

		public function HealthActionListViewControllerBase(healthActionListViewModel:IHealthActionListViewModel)
		{
			_healthActionListViewModel = healthActionListViewModel;

			_collaborationLobbyNetConnectionServiceProxy = _healthActionListViewModel.healthActionInputModelDetailsProvider.collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_synchronizationService = new SynchronizationService(this, _collaborationLobbyNetConnectionServiceProxy,
					_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.meta.id);
		}

		public function handleHealthActionResult():void
		{
			if (_synchronizationService.synchronize("handleHealthActionResult",
					_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.meta.id))
			{
				return;
			}

			if (_healthActionListViewModel.scheduleItemOccurrence &&
					_healthActionListViewModel.scheduleItemOccurrence.adherenceItem)
			{
				_healthActionListViewModel.voidHealthActionResult(_synchronizationService.initiatedLocally);
			}
			else
			{
				if (_healthActionListViewModel.healthActionInputController && !_healthActionListViewModel.healthActionInputController.useDefaultHandleHealthActionResult())
				{
					_healthActionListViewModel.healthActionInputController.handleHealthActionResult(_synchronizationService.initiatedLocally);
				}
				else
				{
					_healthActionListViewModel.createHealthActionResult(_synchronizationService.initiatedLocally);
				}
			}
		}

		public function handleHealthActionSelected():void
		{
			if (_synchronizationService.synchronize("handleHealthActionSelected",
					_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.meta.id))
			{
				return;
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
			_synchronizationService.removeEventListener(this);
		}
	}
}
