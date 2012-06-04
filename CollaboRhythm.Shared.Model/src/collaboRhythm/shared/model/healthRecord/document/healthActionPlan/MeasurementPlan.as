package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	[Bindable]
	public class MeasurementPlan
	{
		private var _name:CodedValue;
		private var _type:CodedValue;
		private var _aggregationFunction:CodedValue;

		public function MeasurementPlan()
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

		public function get type():CodedValue
		{
			return _type;
		}

		public function set type(value:CodedValue):void
		{
			_type = value;
		}

		public function get aggregationFunction():CodedValue
		{
			return _aggregationFunction;
		}

		public function set aggregationFunction(value:CodedValue):void
		{
			_aggregationFunction = value;
		}
	}
}
