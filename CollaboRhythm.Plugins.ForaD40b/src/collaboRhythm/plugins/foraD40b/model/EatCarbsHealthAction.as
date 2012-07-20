package collaboRhythm.plugins.foraD40b.model
{
	public class EatCarbsHealthAction
	{
		private var _datePerformed:Date;
		private var _carbDescription:String

		public function EatCarbsHealthAction(datePerformed:Date, carbDescription:String)
		{
			_datePerformed = datePerformed;
			_carbDescription = carbDescription;
		}

		public function get datePerformed():Date
		{
			return _datePerformed;
		}

		public function set datePerformed(value:Date):void
		{
			_datePerformed = value;
		}

		public function get carbDescription():String
		{
			return _carbDescription;
		}

		public function set carbDescription(value:String):void
		{
			_carbDescription = value;
		}
	}
}
