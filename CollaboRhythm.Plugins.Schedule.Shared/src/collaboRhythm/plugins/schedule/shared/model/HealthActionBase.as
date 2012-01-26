package collaboRhythm.plugins.schedule.shared.model
{
	public class HealthActionBase
	{
		private var _type:String;
		private var _name:String;

		public function HealthActionBase(type:String, name:String = null)
		{
			_type = type;
			_name = name;
		}

		public function get type():String
		{
			return _type;
		}

		public function get name():String
		{
			return _name;
		}
	}
}
