package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;

	import com.adobe.nativeExtensions.Vibration;

	public class HealthActionListViewControllerBase implements IHealthActionListViewController
	{
		private var _healthActionListViewModel:IHealthActionListViewModel;

		public function HealthActionListViewControllerBase(healthActionListViewModel:IHealthActionListViewModel)
		{
			_healthActionListViewModel = healthActionListViewModel;
		}

		public function handleHealthActionResult():void
		{
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

		public function playVideo(instructionalVideo:String):void
		{
			// TODO: Currently using the vibration native extension with modifications to play a video
			// it is commented out here and in the manifest because it interferes with debugging
			var vibration:Vibration = new Vibration();
			vibration.vibrate(2000);
		}
	}
}
