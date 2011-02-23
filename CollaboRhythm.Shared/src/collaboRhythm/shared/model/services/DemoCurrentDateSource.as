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
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class DemoCurrentDateSource implements ICurrentDateSource
	{
		private var _targetDate:Date;
		private var _offset:Number;

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
	
				currentDate.hours = 0;
				currentDate.minutes = 0;
				currentDate.seconds = 0;
				currentDate.milliseconds = 0;
				
				_offset = _targetDate.time - currentDate.time;
			}
			else
				_offset = 0;
			
			this.dispatchEvent(changeEvent);
		}
		
		public function DemoCurrentDateSource()
		{
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
	}
}