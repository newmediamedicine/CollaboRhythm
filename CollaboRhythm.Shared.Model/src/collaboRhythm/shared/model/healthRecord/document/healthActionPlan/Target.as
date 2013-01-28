package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class Target
	{
		private var _name:CollaboRhythmCodedValue;
		private var _minimumValue:CollaboRhythmValueAndUnit;
		private var _maximumValue:CollaboRhythmValueAndUnit;
		private var _severityLevel:CollaboRhythmCodedValue;

		public function Target()
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

		public function get minimumValue():CollaboRhythmValueAndUnit
		{
			return _minimumValue;
		}

		public function set minimumValue(value:CollaboRhythmValueAndUnit):void
		{
			_minimumValue = value;
		}

		public function get maximumValue():CollaboRhythmValueAndUnit
		{
			return _maximumValue;
		}

		public function set maximumValue(value:CollaboRhythmValueAndUnit):void
		{
			_maximumValue = value;
		}

		public function get severityLevel():CollaboRhythmCodedValue
		{
			return _severityLevel;
		}

		public function set severityLevel(value:CollaboRhythmCodedValue):void
		{
			_severityLevel = value;
		}
	}
}
