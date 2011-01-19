package collaboRhythm.view.scroll
{
	import flash.geom.Point;

	/**
	 * A sample point corresponding to a mouse or touch move event. Multiple samples are stored in order to interpret a gesture over
	 * a period of time longer than the sample rate of individual move events.
	 *   
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public class MoveSample
	{
		private var _pos:Point;
		private var _dateStamp:Date;
		private var _previousSample:MoveSample;
		
		public function MoveSample(posX:Number, posY:Number, dateStamp:Date, previousSample:MoveSample)
		{
			_pos = new Point(posX, posY);
			_dateStamp = dateStamp;
			_previousSample = previousSample;
		}

		public function get previousSample():MoveSample
		{
			return _previousSample;
		}

		public function set previousSample(value:MoveSample):void
		{
			_previousSample = value;
		}

		public function get dateStamp():Date
		{
			return _dateStamp;
		}

		public function set dateStamp(value:Date):void
		{
			_dateStamp = value;
		}

		public function get pos():Point
		{
			return _pos;
		}

		public function set pos(value:Point):void
		{
			_pos = value;
		}

	}
}