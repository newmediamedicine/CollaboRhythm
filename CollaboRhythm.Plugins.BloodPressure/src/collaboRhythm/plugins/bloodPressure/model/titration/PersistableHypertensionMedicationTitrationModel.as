package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Measurement;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.StopCondition;

	import mx.collections.ArrayCollection;

	public class PersistableHypertensionMedicationTitrationModel extends HypertensionMedicationTitrationModel
	{
		private var _decisionScheduleItemOccurrence:ScheduleItemOccurrence;

		public function PersistableHypertensionMedicationTitrationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			super(activeAccount, activeRecordAccount);
		}

		override public function evaluateForInitialize():void
		{
			clearSelections();

			var plan:DocumentBase = getParentForTitrationDecisionResult(false);
			
			if (plan)
			{
				for each (var relationship:Relationship in plan.relatesTo)
				{
					var decisionResult:HealthActionResult = relationship ? relationship.relatesTo as HealthActionResult : null;
					if (decisionResult && decisionResult.name.text == TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME)
					{
						var actionStepResult:ActionStepResult = decisionResult.actions && decisionResult.actions.length > 0 ? decisionResult.actions[0] as ActionStepResult: null;
						if (actionStepResult)
						{
							var occurrence:Occurrence = actionStepResult.occurrences && actionStepResult.occurrences.length > 0 ? actionStepResult.occurrences[0] as Occurrence : null;
							if (occurrence)
							{
								var measurementNewDose:Measurement;
								var measurementDoseSelected:Measurement;

								for each (var measurement:Measurement in occurrence.measurements)
								{
									if (measurement.name.text == "newDose")
									{
										measurementNewDose = measurement;
									}
									else if (measurement.name.text == "doseSelected")
									{
										measurementDoseSelected = measurement;
									}
								}

								if (measurementNewDose && measurementDoseSelected)
								{
									var newDose:int = parseInt(measurementNewDose.value.value);
									var doseSelected:int = parseInt(measurementDoseSelected.value.value);

									var medication:HypertensionMedication = getMedication(occurrence.additionalDetails);
									if (medication)
									{
										medication.restoreMedicationDoseSelection(doseSelected, newDose, getAccount(decisionResult.reportedBy), _activeRecordAccount.accountId, decisionResult.dateReported);
									}
								}
							}
						}
					}
				}
			}
		}

		private function clearSelections():void
		{
			for each (var pair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				for each (var medication:HypertensionMedication in pair.medications)
				{
					medication.clearSelections();
				}
			}
		}

		private function getAccount(targetAccountId:String):Account
		{
			if (targetAccountId == _activeAccount.accountId)
			{
				return _activeAccount;
			}
			else if (targetAccountId == _activeRecordAccount.accountId)
			{
				return _activeRecordAccount;
			}
			else
			{
				// TODO: make this more robust; find the correct account
				_logger.error("Failed to get account for accountId " + targetAccountId);
				return null;
			}
		}

		private function getMedication(medicationName:String):HypertensionMedication
		{
			for each (var pair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				for each (var medication:HypertensionMedication in pair.medications)
				{
					if (medication.medicationName == medicationName)
					{
						return medication;
					}
				}
			}
			return null;
		}

		public function save(persist:Boolean = true):Boolean
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
				var selections:Vector.<HypertensionMedicationDoseSelection> = getSelections();
				for each (var selection:HypertensionMedicationDoseSelection in selections)
				{
					saveTitrationResult(selection);
					selection.persisted = true;
				}

				record.saveAllChanges();
				evaluateForInitialize();
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
			var selections:Vector.<HypertensionMedicationDoseSelection> = getSelections();
			if (selections.length > 0)
			{
				var parts:Array = getSelectionsSummary(selections);
				confirmationMessage = "You have chosen to make the following change(s). Please confirm.\n" +
						parts.join("\n");
			}
			else
			{
				confirmationMessage = "No changes";
			}
		}

		private function getSelectionsSummary(selections:Vector.<HypertensionMedicationDoseSelection>):Array
		{
			var parts:Array = [];
			for each (var selection:HypertensionMedicationDoseSelection in selections)
			{
				parts.push(selection.getSummary(false));
			}
			return parts;
		}

		private function getSelections():Vector.<HypertensionMedicationDoseSelection>
		{
			var selections:Vector.<HypertensionMedicationDoseSelection> = new <HypertensionMedicationDoseSelection>[];
			for each (var pair:HypertensionMedicationAlternatePair in _hypertensionMedicationAlternatePairsVector)
			{
				for each (var medication:HypertensionMedication in pair.medications)
				{
					for each (var selection:HypertensionMedicationDoseSelection in medication.doseSelections)
					{
						if (!selection.persisted && selection.selectionByAccount.accountId == accountId &&
								selection.selectionType != HypertensionMedicationDoseSelection.SYSTEM)
						{
							selections.push(selection);
						}
					}
				}
			}
			return selections;
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

		private function saveTitrationResult(selection:HypertensionMedicationDoseSelection):void
		{
			var parentForTitrationDecisionResult:DocumentBase = getParentForTitrationDecisionResult();

			var titrationResult:HealthActionResult = new HealthActionResult();
			titrationResult.name = new CollaboRhythmCodedValue(null, null, null, TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME);
			titrationResult.reportedBy = accountId;
			titrationResult.dateReported = currentDateSource.now();
			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CollaboRhythmCodedValue(null, null, null, isPatient ? PATIENT_DECISION_ACTION_STEP_RESULT_NAME : CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			var occurrence:Occurrence = new Occurrence();
			occurrence.additionalDetails = selection.medication.medicationName;
			occurrence.stopCondition = new StopCondition();
			occurrence.stopCondition.name = new CollaboRhythmCodedValue(null, null, null, "agreement");
			occurrence.stopCondition.value = new CollaboRhythmValueAndUnit(null, null, selection.isInAgreement() ? AGREE_STOP_CONDITION_NAME : NEW_STOP_CONDITION_NAME);
			occurrence.measurements = new ArrayCollection();
			var measurementNewDose:Measurement = new Measurement();
			measurementNewDose.name = new CollaboRhythmCodedValue(null, null, null, "newDose");
			measurementNewDose.value = new CollaboRhythmValueAndUnit(selection.newDose.toString(), createDoseStrengthCodeCodedValue());
			occurrence.measurements.addItem(measurementNewDose);
			var measurementDoseSelected:Measurement = new Measurement();
			measurementDoseSelected.name = new CollaboRhythmCodedValue(null, null, null, "doseSelected");
			measurementDoseSelected.value = new CollaboRhythmValueAndUnit(selection.doseSelected.toString(), createDoseStrengthCodeCodedValue());
			occurrence.measurements.addItem(measurementDoseSelected);
			actionStepResult.occurrences.addItem(occurrence);
			titrationResult.actions = new ArrayCollection();
			titrationResult.actions.addItem(actionStepResult);

			record.addDocument(titrationResult, true);

			record.addRelationship(HealthActionResult.RELATION_TYPE_TITRATION_DECISION, parentForTitrationDecisionResult, titrationResult, true);
		}

		private static const HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME:String = "Hypertension Medication Titration Decision";

		/**
		 * Finds the HealthActionPlan for hypertension medication titration decision, or create one if it does not exist.
		 * @return a document that can be used as the parent for titration decision result(s)
		 */
		private function getParentForTitrationDecisionResult(createIfNeeded:Boolean = true):DocumentBase
		{
			var titrationDecisionPlan:HealthActionPlan;

			// go in reverse order to start with most recent
			for (var i:int = record.healthActionPlansModel.documents.length - 1; i >= 0; i--)
			{
				var plan:HealthActionPlan = record.healthActionPlansModel.documents[i];
				if (plan.name.text == HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME)
				{
					titrationDecisionPlan = plan;
					break;
				}
			}

			if (createIfNeeded && titrationDecisionPlan == null)
			{
				titrationDecisionPlan = new HealthActionPlan();
				titrationDecisionPlan.name = new CollaboRhythmCodedValue(null, null, null, HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME);
				titrationDecisionPlan.planType = "Prescribed";
				titrationDecisionPlan.plannedBy = accountId;
				titrationDecisionPlan.datePlanned = _currentDateSource.now();
				titrationDecisionPlan.indication = "Essential Hypertension";
				titrationDecisionPlan.instructions = "Use CollaboRhythm to follow the algorithm for changing your dose of hypertension medications.";
				titrationDecisionPlan.system = new CollaboRhythmCodedValue(null, null, null, "CollaboRhythm Hypertension Titration Support");

				record.addDocument(titrationDecisionPlan, true);
			}

			return titrationDecisionPlan;
		}

		private static function createDoseStrengthCodeCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue("http://indivo.org/codes/units#", "DoseStrengthCode", "DSU", "DoseStrengthCode");
		}
	}
}
