package collaboRhythm.shared.model.demographics
{
	[Bindable]
	public class Telephone
	{
		private var _type:String;
		private var _number:String;
		private var _preferred:Boolean;

		public function Telephone()
		{
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get number():String
		{
			return _number;
		}

		public function set number(value:String):void
		{
			_number = value;
		}

		public function get preferred():Boolean
		{
			return _preferred;
		}

		public function set preferred(value:Boolean):void
		{
			_preferred = value;
		}
	}
}
