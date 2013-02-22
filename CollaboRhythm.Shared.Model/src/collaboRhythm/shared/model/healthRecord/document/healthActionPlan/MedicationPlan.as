package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class MedicationPlan
	{
		private var _name:CollaboRhythmCodedValue;
		private var _indication:String;
		private var _dose:CollaboRhythmValueAndUnit;
		private var _route:CollaboRhythmCodedValue;
		private var _instructions:String;

		public function MedicationPlan()
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

		public function get indication():String
		{
			return _indication;
		}

		public function set indication(value:String):void
		{
			_indication = value;
		}

		public function get dose():CollaboRhythmValueAndUnit
		{
			return _dose;
		}

		public function set dose(value:CollaboRhythmValueAndUnit):void
		{
			_dose = value;
		}

		public function get route():CollaboRhythmCodedValue
		{
			return _route;
		}

		public function set route(value:CollaboRhythmCodedValue):void
		{
			_route = value;
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
