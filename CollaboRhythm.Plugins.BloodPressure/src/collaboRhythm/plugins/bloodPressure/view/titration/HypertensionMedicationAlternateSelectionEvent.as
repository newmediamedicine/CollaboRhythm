package collaboRhythm.plugins.bloodPressure.view.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationAlternatePair;

	import flash.events.Event;

	public class HypertensionMedicationAlternateSelectionEvent extends Event
	{
		public static const ALTERNATE_SELECTED:String = "HypertensionMedicationAlternateSelected";

		private var _hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair;
		private var _altKey:Boolean;
		private var _ctrlKey:Boolean;

		public function HypertensionMedicationAlternateSelectionEvent(type:String,
																	 hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair,
																	 altKey:Boolean, ctrlKey:Boolean)
		{
			super(type, true);

			_hypertensionMedicationAlternatePair = hypertensionMedicationAlternatePair;
			_altKey = altKey;
			_ctrlKey = ctrlKey;
		}

		public function get hypertensionMedicationAlternatePair():HypertensionMedicationAlternatePair
		{
			return _hypertensionMedicationAlternatePair;
		}

		public function set hypertensionMedicationAlternatePair(value:HypertensionMedicationAlternatePair):void
		{
			_hypertensionMedicationAlternatePair = value;
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
