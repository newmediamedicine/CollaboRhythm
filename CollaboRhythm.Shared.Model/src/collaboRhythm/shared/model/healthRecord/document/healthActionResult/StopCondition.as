package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class StopCondition
	{
		private var _name:CollaboRhythmCodedValue;
		private var _value:CollaboRhythmValueAndUnit;

		public function StopCondition()
		{
		}

		public function get name():CollaboRhythmCodedValue
		{
			return _name;
		}

		public function set name(value:CollaboRhythmCodedValue):void
		{
			_name = value;
		}

		public function get value():CollaboRhythmValueAndUnit
		{
			return _value;
		}

		public function set value(value:CollaboRhythmValueAndUnit):void
		{
			_value = value;
		}
	}
}
