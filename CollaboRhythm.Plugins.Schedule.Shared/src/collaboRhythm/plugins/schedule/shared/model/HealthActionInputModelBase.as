package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;

	public class HealthActionInputModelBase
    {
        private var _scheduleItemOccurrence:ScheduleItemOccurrence;
        private var _urlVariables:URLVariables;
		protected var _currentDateSource:ICurrentDateSource;
		protected var _scheduleModel:IScheduleModel;

        public function HealthActionInputModelBase(scheduleItemOccurrence:ScheduleItemOccurrence = null,
										   urlVariables:URLVariables = null,
										   scheduleModel:IScheduleModel = null)
        {
            _scheduleItemOccurrence = scheduleItemOccurrence;
            this.urlVariables = urlVariables;
			_scheduleModel = scheduleModel;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function get urlVariables():URLVariables
        {
            return _urlVariables;
        }

        public function set urlVariables(value:URLVariables):void
        {
            // abstract, subclasses should override
            _urlVariables = value;
        }
	}
}
