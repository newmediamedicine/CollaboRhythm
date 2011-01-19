package collaboRhythm.workstation.model.services
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