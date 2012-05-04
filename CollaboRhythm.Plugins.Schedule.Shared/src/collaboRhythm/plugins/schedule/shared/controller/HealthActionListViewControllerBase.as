package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewController;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewModel;

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
	}
}
