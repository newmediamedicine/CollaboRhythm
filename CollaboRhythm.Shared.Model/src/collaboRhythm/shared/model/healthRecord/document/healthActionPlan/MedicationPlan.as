package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class MedicationPlan
	{
		private var _name:CodedValue;
		private var _indication:String;
		private var _dose:ValueAndUnit;
		private var _route:CodedValue;
		private var _instructions:String;

		public function MedicationPlan()
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

		public function get indication():String
		{
			return _indication;
		}

		public function set indication(value:String):void
		{
			_indication = value;
		}

		public function get dose():ValueAndUnit
		{
			return _dose;
		}

		public function set dose(value:ValueAndUnit):void
		{
			_dose = value;
		}

		public function get route():CodedValue
		{
			return _route;
		}

		public function set route(value:CodedValue):void
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
