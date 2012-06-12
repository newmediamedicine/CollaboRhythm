package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class Target
	{
		private var _name:CodedValue;
		private var _minimumValue:ValueAndUnit;
		private var _maximumValue:ValueAndUnit;
		private var _severityLevel:CodedValue;

		public function Target()
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

		public function get minimumValue():ValueAndUnit
		{
			return _minimumValue;
		}

		public function set minimumValue(value:ValueAndUnit):void
		{
			_minimumValue = value;
		}

		public function get maximumValue():ValueAndUnit
		{
			return _maximumValue;
		}

		public function set maximumValue(value:ValueAndUnit):void
		{
			_maximumValue = value;
		}

		public function get severityLevel():CodedValue
		{
			return _severityLevel;
		}

		public function set severityLevel(value:CodedValue):void
		{
			_severityLevel = value;
		}
	}
}
