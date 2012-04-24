/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model.services
{

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	import mx.events.PropertyChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Bindable]
	public class DemoCurrentDateSource extends EventDispatcher implements ICurrentDateSource
	{
		protected var _logger:ILogger;
		private var _targetDate:Date;
		private var _offset:Number;
		private var _fastForwardRepeatDelay:Number = 1000 * 3;
		private var _fastForwardIncrement:Number = 1000 * 60 * 60 * 3;
		private var _fastForwardTimer:Timer = new Timer(0);
		private var _fastForwardEnabled:Boolean = false;

		public function get targetDate():Date
		{
			return _targetDate;
		}

		public function set targetDate(value:Date):void
		{
			var changeEvent:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this, "currentDate", this.targetDate, value);
			_targetDate = value;
			
			if (_targetDate != null)
			{
				var currentDate:Date = new Date();
	
//				currentDate.hours = 0;
//				currentDate.minutes = 0;
//				currentDate.seconds = 0;
//				currentDate.milliseconds = 0;

                // By setting currentDate.hours to 0, the timezone information is lost, it must be corrected
                // but it must be corrected using the targetDate timezone because it may be different due to daylight savings
//				_offset = _targetDate.time - currentDate.time + (_targetDate.timezoneOffset * 60 * 1000);

				_offset = _targetDate.time - currentDate.time;
			}
			else
				_offset = 0;
			
			this.dispatchEvent(changeEvent);
			this.dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function DemoCurrentDateSource()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_fastForwardTimer.addEventListener(TimerEvent.TIMER, fastForwardTimer_timerHandler, false, 0, true);
			if (fastForwardEnabled)
			{
				restartFastForwardTimer();
			}
		}

		private function restartFastForwardTimer():void
		{
			_logger.info("Fast forward mode enabled. Time will jump forward " + fastForwardIncrement / 1000 +
					" seconds every " + fastForwardRepeatDelay / 1000 + " seconds.");
			_fastForwardTimer.delay = fastForwardRepeatDelay;
			_fastForwardTimer.start();
		}

		private function fastForwardTimer_timerHandler(event:TimerEvent):void
		{
			var newTargetDate:Date = new Date();
			if (targetDate)
				newTargetDate.setTime(_targetDate.time + fastForwardIncrement);
			else
				newTargetDate.setTime(newTargetDate.time + fastForwardIncrement);

			targetDate = newTargetDate;

			_fastForwardTimer.start();
		}
		
		public function now():Date
		{
			var now:Date = new Date();
			if (!isNaN(_offset) && _offset != 0)
			{
				now.time += _offset;
			}

			return now;
		}
		
		public function get currentDate():Date
		{
			return targetDate;
		}

		public function get fastForwardIncrement():Number
		{
			return _fastForwardIncrement;
		}

		public function set fastForwardIncrement(value:Number):void
		{
			_fastForwardIncrement = value;
		}

		public function get fastForwardRepeatDelay():Number
		{
			return _fastForwardRepeatDelay;
		}

		public function set fastForwardRepeatDelay(value:Number):void
		{
			_fastForwardRepeatDelay = value;
		}

		public function get fastForwardEnabled():Boolean
		{
			return _fastForwardEnabled;
		}

		public function set fastForwardEnabled(value:Boolean):void
		{
			if (_fastForwardEnabled != value)
			{
				_fastForwardEnabled = value;
				if (fastForwardEnabled)
				{
					restartFastForwardTimer();
				}
				else
				{
					_logger.info("Fast forward mode disabled.");
					_fastForwardTimer.stop();
				}
			}
		}
	}
}