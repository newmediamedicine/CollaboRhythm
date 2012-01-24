package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class HealthActionListViewModelBase implements IHealthActionListViewModel
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _healthActionInputModelDetailsProvider:IHealthActionModelDetailsProvider;
        private var _healthActionInputController:IHealthActionInputController;

		public function HealthActionListViewModelBase(scheduleItemOccurrence:ScheduleItemOccurrence,
													  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_healthActionInputModelDetailsProvider = healthActionModelDetailsProvider;
		}

		public function voidHealthActionResult():void
		{
			_scheduleItemOccurrence.voidAdherenceItem(_healthActionInputModelDetailsProvider.record);
		}

		public function createHealthActionResult():void
		{
		}

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function set scheduleItemOccurrence(value:ScheduleItemOccurrence):void
        {
            _scheduleItemOccurrence = value;
        }

		public function get healthActionInputModelDetailsProvider():IHealthActionModelDetailsProvider
		{
			return _healthActionInputModelDetailsProvider;
		}

		public function set healthActionInputModelDetailsProvider(value:IHealthActionModelDetailsProvider):void
		{
			_healthActionInputModelDetailsProvider = value;
		}

		public function get healthActionInputController():IHealthActionInputController
		{
			return _healthActionInputController;
		}

		public function set healthActionInputController(value:IHealthActionInputController):void
		{
			_healthActionInputController = value;
		}
	}
}
