package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.UIDUtil;

	public class ScheduleCreator
	{
		public static const DEFAULT_RECURRENCE_COUNT:int = 120;
		public static const DEFAULT_START_TIME:int = 8;
		public static const DEFAULT_ADHERENCE_WINDOW:int = 4;

		protected var _logger:ILogger;
		private var _record:Record;
		private var _accountId:String;
		private var _currentDateSource:ICurrentDateSource;

		public function ScheduleCreator(record:Record, accountId:String, currentDateSource:ICurrentDateSource)
		{
			_record = record;
			_accountId = accountId;
			_currentDateSource = currentDateSource;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}


		public function initializeDefaultSchedule(scheduleItem:ScheduleItemBase):void
		{
			scheduleItem.scheduledBy = accountId;
			scheduleItem.dateScheduled = _currentDateSource.now();
			scheduleItem.dateStart = new Date(_currentDateSource.now().fullYear,
					_currentDateSource.now().month, _currentDateSource.now().date, DEFAULT_START_TIME, 0, 0);
			scheduleItem.dateEnd = new Date(_currentDateSource.now().fullYear,
					_currentDateSource.now().month,
					_currentDateSource.now().date, DEFAULT_START_TIME + DEFAULT_ADHERENCE_WINDOW, 0, 0);
			var recurrenceRule:RecurrenceRule = new RecurrenceRule();
			recurrenceRule.frequency = new CodedValue(null, null, null, ScheduleItemBase.DAILY);
			recurrenceRule.count = DEFAULT_RECURRENCE_COUNT;
			scheduleItem.recurrenceRule = recurrenceRule;
		}
	}
}
