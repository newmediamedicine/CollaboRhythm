package collaboRhythm.plugins.bloodPressure.model.titration
{
	public class MatchParameters
	{
		private var _matchData:String;
		private var _matchFunction:Function;

		public function MatchParameters(matchData:String, matchFunction:Function)
		{
			_matchData = matchData;
			_matchFunction = matchFunction;
		}

		public function get matchData():String
		{
			return _matchData;
		}

		public function set matchData(value:String):void
		{
			_matchData = value;
		}

		public function get matchFunction():Function
		{
			return _matchFunction;
		}

		public function set matchFunction(value:Function):void
		{
			_matchFunction = value;
		}
	}
}
