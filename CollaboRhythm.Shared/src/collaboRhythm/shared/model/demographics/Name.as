package collaboRhythm.shared.model.demographics
{
	[Bindable]
	public class Name
	{
		private var _familyName:String;
		private var _givenName:String;
		private var _middleName:String;
		private var _prefix:String;
		private var _suffix:String;

		public function Name()
		{
		}

		public function get familyName():String
		{
			return _familyName;
		}

		public function set familyName(value:String):void
		{
			_familyName = value;
		}

		public function get givenName():String
		{
			return _givenName;
		}

		public function set givenName(value:String):void
		{
			_givenName = value;
		}

		public function get middleName():String
		{
			return _middleName;
		}

		public function set middleName(value:String):void
		{
			_middleName = value;
		}

		public function get prefix():String
		{
			return _prefix;
		}

		public function set prefix(value:String):void
		{
			_prefix = value;
		}

		public function get suffix():String
		{
			return _suffix;
		}

		public function set suffix(value:String):void
		{
			_suffix = value;
		}
	}
}
