package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class StopCondition
	{
		private var _name:CodedValue;
		private var _value:ValueAndUnit;
		private var _operator:CodedValue;
		private var _detail:CodedValue;

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

		public function get operator():CodedValue
		{
			return _operator;
		}

		public function set operator(value:CodedValue):void
		{
			_operator = value;
		}

		public function get detail():CodedValue
		{
			return _detail;
		}

		public function set detail(value:CodedValue):void
		{
			_detail = value;
		}
	}
}
