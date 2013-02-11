package collaboRhythm.plugins.bloodPressure.view
{
	import collaboRhythm.plugins.bloodPressure.model.HypertensionMedication;

	import flash.events.Event;

	public class HypertensionMedicationViewEvent extends Event
	{
		public static const HYPERTENSION_MEDICATION_DOSE_CHOICE_CLICKED:String = "HypertensionMedicationDoseChoiceClicked";

		private var _hypertensionMedication:HypertensionMedication;
		private var _doseChoice:int;

		public function HypertensionMedicationViewEvent(type:String,
													hypertensionMedication:HypertensionMedication,
													doseChoice:int)
		{
			super(type, true);

			_hypertensionMedication = hypertensionMedication;
			_doseChoice = doseChoice;
		}

		public function get hypertensionMedication():HypertensionMedication
		{
			return _hypertensionMedication;
		}

		public function set hypertensionMedication(value:HypertensionMedication):void
		{
			_hypertensionMedication = value;
		}

		public function get doseChoice():int
		{
			return _doseChoice;
		}

		public function set doseChoice(value:int):void
		{
			_doseChoice = value;
		}
	}
}
