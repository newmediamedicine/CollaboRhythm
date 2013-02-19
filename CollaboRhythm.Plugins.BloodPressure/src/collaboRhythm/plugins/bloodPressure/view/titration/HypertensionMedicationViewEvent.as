package collaboRhythm.plugins.bloodPressure.view.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedication;

	import flash.events.Event;

	public class HypertensionMedicationViewEvent extends Event
	{
		public static const DOSE_SELECTED:String = "HypertensionMedicationDoseSelected";

		private var _hypertensionMedication:HypertensionMedication;
		private var _doseSelected:int;
		private var _altKey:Boolean;
		private var _ctrlKey:Boolean;

		public function HypertensionMedicationViewEvent(type:String, hypertensionMedication:HypertensionMedication,
														doseSelected:int, altKey:Boolean, ctrlKey:Boolean)
		{
			super(type, true);

			_hypertensionMedication = hypertensionMedication;
			_doseSelected = doseSelected;
			_altKey = altKey;
			_ctrlKey = ctrlKey;
		}

		public function get hypertensionMedication():HypertensionMedication
		{
			return _hypertensionMedication;
		}

		public function set hypertensionMedication(value:HypertensionMedication):void
		{
			_hypertensionMedication = value;
		}

		public function get doseSelected():int
		{
			return _doseSelected;
		}

		public function set doseSelected(value:int):void
		{
			_doseSelected = value;
		}

		public function get altKey():Boolean
		{
			return _altKey;
		}

		public function set altKey(value:Boolean):void
		{
			_altKey = value;
		}

		public function get ctrlKey():Boolean
		{
			return _ctrlKey;
		}

		public function set ctrlKey(value:Boolean):void
		{
			_ctrlKey = value;
		}

	}
}
