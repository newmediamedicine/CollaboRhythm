package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedication;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationAlternatePair;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationTitrationModel;

	public interface ITitrationMapController
	{
		function handleHypertensionMedicationDoseSelected(hypertensionMedication:HypertensionMedication,
														  doseSelected:int, altKey:Boolean, ctrlKey:Boolean):void;

		function handleHypertensionMedicationAlternateSelected(hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair,
															   altKey:Boolean, ctrlKey:Boolean):void;

		function save():Boolean;

		function get model():HypertensionMedicationTitrationModel;
	}
}
