package collaboRhythm.shared.model.demographics
{
	[Bindable]
	public class Address
	{
		private var _country:String;
		private var _city:String;
		private var _postalCode:String;
		private var _region:String;
		private var _street:String;

		public function Address()
		{
		}

		public function get country():String
		{
			return _country;
		}

		public function set country(value:String):void
		{
			_country = value;
		}

		public function get city():String
		{
			return _city;
		}

		public function set city(value:String):void
		{
			_city = value;
		}

		public function get postalCode():String
		{
			return _postalCode;
		}

		public function set postalCode(value:String):void
		{
			_postalCode = value;
		}

		public function get region():String
		{
			return _region;
		}

		public function set region(value:String):void
		{
			_region = value;
		}

		public function get street():String
		{
			return _street;
		}

		public function set street(value:String):void
		{
			_street = value;
		}
	}
}
