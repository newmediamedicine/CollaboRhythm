package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class StopCondition
	{
		private var _name:CodedValue;
		private var _value:ValueAndUnit;

		public function StopCondition()
		{
		}

		public function get name():CodedValue
		{
			return _name;
		}

		public function set name(value:CodedValue):void
		{
			_name = value;
		}

		public function get value():ValueAndUnit
		{
			return _value;
		}

		public function set value(value:ValueAndUnit):void
		{
			_value = value;
		}
	}
}
