package collaboRhythm.plugins.bloodPressure.model
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class HypertensionMedicationAlternatePair
	{
		private var _primaryHypertensionMedication:HypertensionMedication;
		private var _secondaryHypertensionMedication:HypertensionMedication;

		private var _activeHypertensionMedication:HypertensionMedication;
		private var _inactiveHypertensionMedication:HypertensionMedication;

		public function HypertensionMedicationAlternatePair(primaryHypertensionMedication:HypertensionMedication, secondaryHypertensionMedication:HypertensionMedication)
		{
			_primaryHypertensionMedication = primaryHypertensionMedication;
			_secondaryHypertensionMedication = secondaryHypertensionMedication;
		}

		public function determineCurrentDose(medicationScheduleItemsCollection:ArrayCollection):void
		{
			_primaryHypertensionMedication.determineCurrentDose(medicationScheduleItemsCollection);

			if (_secondaryHypertensionMedication)
			{
				_secondaryHypertensionMedication.determineCurrentDose(medicationScheduleItemsCollection);
				if (_secondaryHypertensionMedication.currentDose != 0)
				{
					activeHypertensionMedication = _secondaryHypertensionMedication;
					inactiveHypertensionMedication = _primaryHypertensionMedication;
				}
				else
				{
					activeHypertensionMedication = _primaryHypertensionMedication;
					inactiveHypertensionMedication = _secondaryHypertensionMedication;
				}
			}
			else
			{
				activeHypertensionMedication = _primaryHypertensionMedication;
				inactiveHypertensionMedication = _secondaryHypertensionMedication;
			}
		}

		public function handleAlternateSelected(altKey:Boolean, ctrlKey:Boolean):void
		{


			if (altKey && ctrlKey)
			{
				activeHypertensionMedication.currentDose = 0;
			}
			else
			{
				var selectionType:String;

				if (ctrlKey)
				{
					selectionType = HypertensionMedicationDoseSelection.COACH;
				}
				else if (altKey)
				{
					selectionType = HypertensionMedicationDoseSelection.SYSTEM;
				}
				else
				{
					selectionType = HypertensionMedicationDoseSelection.PATIENT;
				}
			}

			activeHypertensionMedication.removeAllHypertensionMedicationDoseSelections(selectionType);

			var currentActiveHypertensionMedication:HypertensionMedication = _activeHypertensionMedication;
			var currentInactiveHypertensionMedication:HypertensionMedication = _inactiveHypertensionMedication;

			activeHypertensionMedication = currentInactiveHypertensionMedication;
			inactiveHypertensionMedication = currentActiveHypertensionMedication;
		}

		public function get primaryHypertensionMedication():HypertensionMedication
		{
			return _primaryHypertensionMedication;
		}

		public function get secondaryHypertensionMedication():HypertensionMedication
		{
			return _secondaryHypertensionMedication;
		}

		public function get activeHypertensionMedication():HypertensionMedication
		{
			return _activeHypertensionMedication;
		}

		public function set activeHypertensionMedication(value:HypertensionMedication):void
		{
			_activeHypertensionMedication = value;
		}

		public function get inactiveHypertensionMedication():HypertensionMedication
		{
			return _inactiveHypertensionMedication;
		}

		public function set inactiveHypertensionMedication(value:HypertensionMedication):void
		{
			_inactiveHypertensionMedication = value;
		}
	}
}
