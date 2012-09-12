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

		public function handleHealthActionResult(calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("handleHealthActionResult", calledLocally,
					_healthActionListViewModel.scheduleItemOccurrence.scheduleItem.meta.id))
			{
				return;
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

		public function handleHealthActionSelected(calledLocally:Boolean):void
		{
			if (_synchronizationService.synchronize("handleHealthActionSelected", calledLocally,
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
