package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class PersistableHypertensionMedicationTitrationModel extends HypertensionMedicationTitrationModel
	{
		private var _decisionScheduleItemOccurrence:ScheduleItemOccurrence;

		public function PersistableHypertensionMedicationTitrationModel(activeRecordAccount:Account)
		{
			super(activeRecordAccount);
		}

		public function save():Boolean
		{
			var saveSucceeded:Boolean = true;

			validateDecisionPreConditions();

//			var healthActionSchedule:HealthActionSchedule = decisionScheduleItemOccurrence.scheduleItem as HealthActionSchedule;
//			var plan:HealthActionPlan = healthActionSchedule.scheduledHealthAction as HealthActionPlan;

			// validate
			if (isChangeSpecified)
			{
				evaluateForSave();
				/*

				if (_scheduleDetails.currentSchedule == null || _scheduleDetails.occurrence == null)
				{
					// TODO: warn the user why the dose cannot be changed; possibly provide a means to fix the problem
					_logger.warn("User is attempting to change the dose but the current schedule/dose could not be determined.");
					return false;
				}
				else
				{
					var currentMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.currentSchedule as MedicationScheduleItem;
					if (isPatient)
						saveSucceeded = saveForPatient(currentMedicationScheduleItem, plan, saveSucceeded);
					else
						saveSucceeded = saveForClinician(currentMedicationScheduleItem, plan, saveSucceeded);

					saveTitrationResult(currentMedicationScheduleItem);
					evaluateForInitialize();
				}
*/
			}

			return saveSucceeded;
		}

		override public function set isChangeSpecified(value:Boolean):void
		{
			super.isChangeSpecified = value;
			updateConfirmationMessage();
		}

		public function evaluateForSave():void
		{
			validateDecisionPreConditions();
			updateConfirmationMessage();
			/*
						_confirmationMessage = !isPatient ||
								!_clinicianLatestDecisionResult ? (algorithmPrerequisitesSatisfied ? (_dosageChangeValue ==
								algorithmSuggestedDoseChange ? "This change agrees with the 303 Protocol." : "This change does not agree with the 303 Protocol.") : "Prerequisites of the 303 Protocol not met.") : (_newDose ==
								_clinicianLatestDecisionDose ? "This change agrees with your coach’s advice." : "This change does not agree with your coach’s advice.")
			*/
		}

		private function updateConfirmationMessage():void
		{
			if (isChangeSpecified)
			{
				var parts:Array = [];
				for each (var pair:HypertensionMedicationAlternatePair in _hypertensionMedicationAlternatePairsVector)
				{
					for each (var medication:HypertensionMedication in pair.medications)
					{
						for each (var selection:HypertensionMedicationDoseSelection in medication.doseSelections)
						{
							if (!selection.persisted)
							{
								parts.push(selection.getSummary(pair, medication));
							}
						}
					}
				}
				confirmationMessage = "You have chosen to make the following change(s). Please confirm.\n" +
						parts.join("\n");
			}
			else
			{
				confirmationMessage = "No changes";
			}
		}

		override protected function validateDecisionPreConditions():void
		{
/*
			if (decisionScheduleItemOccurrence == null)
				throw new Error("Failed to save. Decision data not available.");
*/
		}

		override protected function get decisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _decisionScheduleItemOccurrence;
		}
	}
}
