package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class StopCondition
	{
		private var _name:CollaboRhythmCodedValue;
		private var _value:CollaboRhythmValueAndUnit;
		private var _operator:CollaboRhythmCodedValue;
		private var _detail:CollaboRhythmCodedValue;

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

		public function get operator():CollaboRhythmCodedValue
		{
			return _operator;
		}

		public function set operator(value:CollaboRhythmCodedValue):void
		{
			_operator = value;
		}

		public function get detail():CollaboRhythmCodedValue
		{
			return _detail;
		}

		public function set detail(value:CollaboRhythmCodedValue):void
		{
			_detail = value;
		}
	}
}
