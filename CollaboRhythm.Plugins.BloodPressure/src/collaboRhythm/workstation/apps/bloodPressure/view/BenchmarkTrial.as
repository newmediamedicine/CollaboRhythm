package collaboRhythm.workstation.apps.bloodPressure.view
{
	public class BenchmarkTrial
	{
		private var _name:String;
		private var _startTime:Date;
		private var _endTime:Date;
		private var _startFrameCount:int;
		private var _endFrameCount:int;
		
		public function BenchmarkTrial()
		{
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get startTime():Date
		{
			return _startTime;
		}

		public function set startTime(value:Date):void
		{
			_startTime = value;
		}

		public function get endTime():Date
		{
			return _endTime;
		}

		public function set endTime(value:Date):void
		{
			_endTime = value;
		}

		public function get startFrameCount():int
		{
			return _startFrameCount;
		}

		public function set startFrameCount(value:int):void
		{
			_startFrameCount = value;
		}

		public function get endFrameCount():int
		{
			return _endFrameCount;
		}

		public function set endFrameCount(value:int):void
		{
			_endFrameCount = value;
		}

		public function start(count:int):void
		{
			startTime = new Date();
			startFrameCount = count;
		}
		
		public function stop(count:int):void
		{
			endTime = new Date();
			endFrameCount = count;
		}
		
		public function get fps():Number
		{
			return 1000 * Number(endFrameCount - startFrameCount) / (endTime.time - startTime.time);
		}
	}
}