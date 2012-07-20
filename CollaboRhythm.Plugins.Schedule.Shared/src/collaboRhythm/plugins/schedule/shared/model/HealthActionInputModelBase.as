package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;

	public class HealthActionInputModelBase implements IHealthActionInputModel
	{
        private var _scheduleItemOccurrence:ScheduleItemOccurrence;
        protected var _urlVariables:URLVariables;
		protected var _currentDateSource:ICurrentDateSource;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;

        public function HealthActionInputModelBase(scheduleItemOccurrence:ScheduleItemOccurrence = null,
												   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
        {
            _scheduleItemOccurrence = scheduleItemOccurrence;
			_healthActionModelDetailsProvider = healthActionModelDetailsProvider;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

		public function get scheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _scheduleItemOccurrence;
		}


		public function set scheduleItemOccurrence(value:ScheduleItemOccurrence):void
		{
			_scheduleItemOccurrence = value;
		}

		public function set urlVariables(value:URLVariables):void
		{
			// abstract, subclasses should override
			_urlVariables = value;
		}

		public function get healthActionModelDetailsProvider():IHealthActionModelDetailsProvider
		{
			return _healthActionModelDetailsProvider;
		}
	}
}
