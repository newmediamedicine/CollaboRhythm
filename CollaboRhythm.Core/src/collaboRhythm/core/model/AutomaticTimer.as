package collaboRhythm.core.model
{
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.logging.Log;

	[Event(name="timer", type="flash.events.TimerEvent")]
	public class AutomaticTimer extends EventDispatcher
	{
		protected static const MILLISECONDS_PER_MINUTE:int = 1000 * 60;
		private static const ONE_MINUTE:int = 1000 * 60;

		protected var _logger:ILogger;
		protected var _currentDateSource:ICurrentDateSource;
		private var _autoSyncTimer:Timer;
		private var _nextAutoSyncTime:Date;
		private var _timerName:String;
		private var _timerHourOfDay:Number;
		private var _timerDelay:Number;

		public function AutomaticTimer(timerName:String, timerHourOfDay:Number, timerDelay:Number)
		{
			_timerName = timerName;
			_timerHourOfDay = timerHourOfDay;
			_timerDelay = timerDelay;

			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

			_autoSyncTimer = new Timer(0);
			_autoSyncTimer.addEventListener(TimerEvent.TIMER, timerHandler);
		}

		private function timerHandler(event:TimerEvent):void
		{
			var now:Date = _currentDateSource.now();
			if (now.getTime() < _nextAutoSyncTime.getTime())
			{
				_logger.warn(_timerName + " timer went off before the expected time.");
			}

			_logger.info("Performing " + _timerName + " from timer event. Local time: " + now.toString() +
					". Expected " + _timerName + " time: " + _nextAutoSyncTime.toString() +
					". Previous timer delay (minutes): " + _autoSyncTimer.delay / ONE_MINUTE);
			dispatchEvent(new TimerEvent(TimerEvent.TIMER));
			start();
		}

		public function start():void
		{
			_autoSyncTimer.stop();

			var delay:Number;
			if (!isNaN(_timerHourOfDay))
			{
				_nextAutoSyncTime = _currentDateSource.now();
				// move the time ahead to midnight tonight
				_nextAutoSyncTime.setHours(_timerHourOfDay, 0, 0, 0);
				var now:Date = _currentDateSource.now();
				// one minute cushion to ensure that the timer does not go off before midnight; slightly after is better than before
				var cushionDelay:Number = ONE_MINUTE;
				delay = _nextAutoSyncTime.getTime() - now.getTime() + cushionDelay;
			}
			else
			{
				delay = _timerDelay;
				_nextAutoSyncTime = new Date(_currentDateSource.now().valueOf() + delay);
			}

			_logger.info(_timerName + " timer set to go off at or after " + _nextAutoSyncTime +
					" in " + delay / ONE_MINUTE + " minutes");
			_autoSyncTimer.delay = delay;
			_autoSyncTimer.start();
		}

		public function checkAutoSyncTimer():void
		{
			var now:Date = _currentDateSource.now();
			if (_nextAutoSyncTime && now.getTime() > _nextAutoSyncTime.getTime())
			{
				_logger.info("Performing " + _timerName + " from activate event. Local time: " + now.toString() +
						". Expected " + _timerName + " time: " + _nextAutoSyncTime.toString() +
						". Previous timer delay (minutes): " + _autoSyncTimer.delay / ONE_MINUTE);
				dispatchEvent(new TimerEvent(TimerEvent.TIMER));
				start();
			}
		}

		public function stop():void
		{
			_autoSyncTimer.stop();
		}

		public function get timerHourOfDay():Number
		{
			return _timerHourOfDay;
		}

		public function set timerHourOfDay(value:Number):void
		{
			_timerHourOfDay = value;
		}
	}
}
