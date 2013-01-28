package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class Measurement
	{
		private var _name:CollaboRhythmCodedValue;
		private var _type:CollaboRhythmCodedValue;
		private var _value:CollaboRhythmValueAndUnit;
		private var _aggregationFunction:CollaboRhythmCodedValue;

		public function Measurement()
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

		public function get type():CollaboRhythmCodedValue
		{
			return _type;
		}

		public function set type(value:CollaboRhythmCodedValue):void
		{
			_type = value;
		}

		public function get value():CollaboRhythmValueAndUnit
		{
			return _value;
		}

		public function set value(value:CollaboRhythmValueAndUnit):void
		{
			_value = value;
		}

		public function get aggregationFunction():CollaboRhythmCodedValue
		{
			return _aggregationFunction;
		}

		public function set aggregationFunction(value:CollaboRhythmCodedValue):void
		{
			_aggregationFunction = value;
		}
	}
}
