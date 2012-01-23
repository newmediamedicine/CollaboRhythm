package collaboRhythm.plugins.schedule.shared.model
{
	public class HealthAction
	{
		private var _healthActionType:String;
		private var _healthActionName:String;
		private var _sourceName:String;

		public function HealthAction(healthActionType:String, healthActionName:String = null, sourceName:String = null)
		{
			_healthActionType = healthActionType;
			_healthActionName = healthActionName;
			_sourceName = sourceName;
		}

		public function get healthActionType():String
		{
			return _healthActionType;
		}

		public function get healthActionName():String
		{
			return _healthActionName;
		}

		public function get sourceName():String
		{
			return _sourceName;
		}
	}
}
