package collaboRhythm.plugins.bloodPressure.controller.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationActionSynchronizationDetails;
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedicationTitrationModel;

	public interface ITitrationMapController
	{
		function handleHypertensionMedicationDoseSelected(hypertensionMedicationActionSynchronizationDetails:HypertensionMedicationActionSynchronizationDetails):void;

		function handleHypertensionMedicationAlternateSelected(hypertensionMedicationActionSynchronizationDetails:HypertensionMedicationActionSynchronizationDetails):void;

		function save():Boolean;

		function get model():HypertensionMedicationTitrationModel;
	}
}
