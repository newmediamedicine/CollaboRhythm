package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;

	[Bindable]
	public class MeasurementPlan
	{
		private var _name:CollaboRhythmCodedValue;
		private var _type:CollaboRhythmCodedValue;
		private var _aggregationFunction:CollaboRhythmCodedValue;

		public function MeasurementPlan()
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
