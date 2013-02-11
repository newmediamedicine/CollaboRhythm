package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class DevicePlan
	{
		private var _name:CollaboRhythmCodedValue;
		private var _type:CollaboRhythmCodedValue;
		private var _value:CollaboRhythmValueAndUnit;
		private var _site:CollaboRhythmCodedValue;
		private var _instructions:String;

		public function DevicePlan()
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

		public function get site():CollaboRhythmCodedValue
		{
			return _site;
		}

		public function set site(value:CollaboRhythmCodedValue):void
		{
			_site = value;
		}

		public function get instructions():String
		{
			return _instructions;
		}

		public function set instructions(value:String):void
		{
			_instructions = value;
		}
	}
}
