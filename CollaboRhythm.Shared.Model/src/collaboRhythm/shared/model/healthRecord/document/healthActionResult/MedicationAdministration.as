package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class MedicationAdministration
	{
		private var _name:CodedValue;
		private var _dose:CodedValue;
		private var _route:ValueAndUnit;

		public function MedicationAdministration()
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

		public function get dose():CodedValue
		{
			return _dose;
		}

		public function set dose(value:CodedValue):void
		{
			_dose = value;
		}

		public function get route():ValueAndUnit
		{
			return _route;
		}

		public function set route(value:ValueAndUnit):void
		{
			_route = value;
		}
	}
}
