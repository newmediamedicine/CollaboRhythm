package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	public class HealthActionInputModelBase
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		protected var _urlVariables:URLVariables;
		protected var _currentDateSource:ICurrentDateSource;
		private var _healthActionModelDetailsProvider:IHealthActionModelDetailsProvider;
		protected var _logger:ILogger;

		public function HealthActionInputModelBase(scheduleItemOccurrence:ScheduleItemOccurrence = null,
												   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
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
