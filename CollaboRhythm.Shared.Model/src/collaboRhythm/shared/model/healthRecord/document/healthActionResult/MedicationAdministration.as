package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;

	[Bindable]
	public class MedicationAdministration
	{
		private var _name:CollaboRhythmCodedValue;
		private var _dose:CollaboRhythmCodedValue;
		private var _route:CollaboRhythmValueAndUnit;

		public function MedicationAdministration()
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

		public function get dose():CollaboRhythmCodedValue
		{
			return _dose;
		}

		public function set dose(value:CollaboRhythmCodedValue):void
		{
			_dose = value;
		}

		public function get route():CollaboRhythmValueAndUnit
		{
			return _route;
		}

		public function set route(value:CollaboRhythmValueAndUnit):void
		{
			_route = value;
		}
	}
}
