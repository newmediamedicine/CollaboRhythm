package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleChanger;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleCreator;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetails;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.CodedValueFactory;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Measurement;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.StopCondition;
	import collaboRhythm.shared.model.medications.MedicationTitrationHelper;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;

	import com.theory9.data.types.OrderedMap;

	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	/**
	 * Enhances HypertensionMedicationTitrationModel by adding support for saving decisions to the patient's health record.
	 */
	public class PersistableHypertensionMedicationTitrationModel extends HypertensionMedicationTitrationModel
	{
		private static const DEFAULT_RECURRENCE_COUNT:int = 120;
		private static const ESSENTIAL_HYPERTENSION_INDICATION:String = "Essential Hypertension";
		private static const DEFAULT_MEDICATION_INSTRUCTIONS:String = "take with water";
		private static const DEFAULT_SCHEDULE_ADMINISTRATIONS_PER_DAY:int = 1;

		private var _decisionScheduleItemOccurrence:ScheduleItemOccurrence;
		private var _settings:Settings;
		private var _componentContainer:IComponentContainer;
		private var _selectionsAgreeWithSystem:Boolean = true;
		private var _headerMessage:String;
		private var _selectionsMessage:String;

		public function PersistableHypertensionMedicationTitrationModel(activeAccount:Account,
																		activeRecordAccount:Account,
																		settings:Settings,
																		componentContainer:IComponentContainer)
		{
			super(activeAccount, activeRecordAccount);
			_settings = settings;
			_componentContainer = componentContainer;
		}

		override public function evaluateForInitialize():void
		{
			reloadCurrentDoses();
			reloadSelections();
		}

		private function reloadCurrentDoses():void
		{
			updateSystemRecommendedDoseSelections();
		}

		private function getMedications():Vector.<HypertensionMedication>
		{
			var medications:Vector.<HypertensionMedication> = new <HypertensionMedication>[];
			for each (var pair:HypertensionMedicationAlternatePair in _hypertensionMedicationAlternatePairsVector)
			{
				for each (var medication:HypertensionMedication in pair.medications)
				{
					medications.push(medication);
				}
			}
			return medications;
		}

		public function reloadSelections():void
		{
			clearSelections();

			var plan:DocumentBase = getParentForTitrationDecisionResult(false);

			if (plan)
			{
				var decisionsFromAccounts:OrderedMap = new OrderedMap();

				for (var i:int = plan.relatesTo.length - 1; i >= 0; i--)
				{
					var relationship:Relationship = plan.relatesTo[i];
					var decisionResult:HealthActionResult = relationship ? relationship.relatesTo as
							HealthActionResult : null;
					if (decisionResult && decisionResult.name.text == TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME)
					{
						// only use latest titration decision from each account (each person's latest decision)
						if (decisionsFromAccounts.getValueByKey(decisionResult.reportedBy) != null)
						{
							continue;
						}
						decisionsFromAccounts.addKeyValue(decisionResult.reportedBy, decisionResult);
						restoreSelectionsFromDecisionResult(decisionResult);
					}
				}
			}
		}

		private function restoreSelectionsFromDecisionResult(decisionResult:HealthActionResult):void
		{
			if (decisionResult.actions && decisionResult.actions.length > 0)
			{
				for each (var actionResult:ActionResult in decisionResult.actions)
				{
					var actionStepResult:ActionStepResult = actionResult as ActionStepResult;

					if (actionStepResult)
					{
						var occurrence:Occurrence = actionStepResult.occurrences &&
								actionStepResult.occurrences.length > 0 ? actionStepResult.occurrences[0] as
								Occurrence : null;
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
								restoreMedicationDoseSelection(measurementNewDose, measurementDoseSelected, occurrence,
										decisionResult);
							}
						}
					}
				}
			}
		}

		private function restoreMedicationDoseSelection(measurementNewDose:Measurement,
														measurementDoseSelected:Measurement, occurrence:Occurrence,
														decisionResult:HealthActionResult):void
		{
			var newDose:int = parseInt(measurementNewDose.value.value);
			var doseSelected:int = parseInt(measurementDoseSelected.value.value);

			var medication:HypertensionMedication = getMedication(occurrence.additionalDetails);
			if (medication)
			{
				medication.restoreMedicationDoseSelection(doseSelected, newDose,
						getAccount(decisionResult.reportedBy),
						_activeRecordAccount.accountId, decisionResult.dateReported);
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
			isChangeSpecified = false;
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
				_logger.warn("Creating fake Account for accountId " + targetAccountId);
				var account:Account = new Account();
				account.accountId = targetAccountId;
				return account;
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

		public function save(shouldFinalize:Boolean, persist:Boolean = true):Boolean
		{
			var saveSucceeded:Boolean = true;

			validateDecisionPreConditions();

			var plan:HealthActionPlan = getTitrationDecisionPlan(true);

			if (isChangeSpecified)
			{
				evaluateForSave();

				if (isPatient)
					saveSucceeded = saveForPatient(shouldFinalize, plan, saveSucceeded);
				else
					saveSucceeded = saveForClinician(shouldFinalize, plan, saveSucceeded);

				sendMedicationTitrationAutomatedMessage(shouldFinalize);

				var selections:Vector.<HypertensionMedicationDoseSelection> = getSelectionsAndCompareWithSystem();
				saveTitrationResult(selections);

				if (persist)
				{
					record.saveAllChanges();
				}
				evaluateForInitialize();
			}

			return saveSucceeded;
		}

		protected function saveForClinician(shouldFinalize:Boolean,
											plan:HealthActionPlan,
											saveSucceeded:Boolean):Boolean
		{
			if (shouldFinalize)
			{
				saveSucceeded = persistMedicationChanges(saveSucceeded);
			}

			return saveSucceeded;
		}

		protected function saveForPatient(shouldFinalize:Boolean,
										  plan:HealthActionPlan,
										  saveSucceeded:Boolean):Boolean
		{
			saveNewScheduledDecision(plan);

			if (shouldFinalize)
			{
				saveSucceeded = persistMedicationChanges(saveSucceeded);
			}

			return saveSucceeded;
		}

		private function sendMedicationTitrationAutomatedMessage(shouldFinalize:Boolean):void
		{
			var proposeVsFinalizeString:String = shouldFinalize ? "finalized" : "proposed";
			var agreeWithSystemString:String = selectionsAgreeWithSystem ? "(This decisions agrees with the MAP)" : "(This decision does not agree with the MAP)";

			var message:String = "[Automated Message] The following decision has been " + proposeVsFinalizeString  + ": " + selectionsMessage + "\n" + agreeWithSystemString;
			sendMessage(message);
		}

		private function persistMedicationChanges(saveSucceeded:Boolean):Boolean
		{
			// if dose is specified and is different, update existing and/or create a new schedule
			var medications:Vector.<HypertensionMedication> = getMedications();
			for each (var medication:HypertensionMedication in medications)
			{
				var selection:HypertensionMedicationDoseSelection = medication.getSelectionForAccount(_activeAccount);

				if (selection != null)
				{
					var medicationScheduleItem:MedicationScheduleItem = medication.medicationScheduleItem;

					if (selection.newDose > 0)
					{
						if (medicationScheduleItem == null)
						{
							saveSucceeded = createNewSchedule(selection);
						}
						else
						{
							saveSucceeded = updateSchedule(medicationScheduleItem, selection, saveSucceeded);
						}
					}
					else
					{
						if (medicationScheduleItem)
						{
							endSchedule(medicationScheduleItem, saveSucceeded);
						}
					}
				}
			}
			return saveSucceeded;
		}

		private function endSchedule(medicationScheduleItem:MedicationScheduleItem, saveSucceeded:Boolean):Boolean
		{
			var medicationTitrationHelper:MedicationTitrationHelper = new MedicationTitrationHelper(record,
					currentDateSource);
			var scheduleDetails:ScheduleDetails = medicationTitrationHelper.getNextMedicationScheduleDetails(new <String>[medicationScheduleItem.name.value]);

			var scheduleChanger:ScheduleChanger = new ScheduleChanger(record, accountId, currentDateSource);
			saveSucceeded = scheduleChanger.endSchedule(medicationScheduleItem,
					scheduleDetails.occurrence, saveSucceeded);
			return saveSucceeded;
		}

		private function updateSchedule(medicationScheduleItem:MedicationScheduleItem,
										selection:HypertensionMedicationDoseSelection,
										saveSucceeded:Boolean):Boolean
		{
			var medicationTitrationHelper:MedicationTitrationHelper = new MedicationTitrationHelper(record,
					currentDateSource);
			var scheduleDetails:ScheduleDetails = medicationTitrationHelper.getNextMedicationScheduleDetails(new <String>[medicationScheduleItem.name.value]);

			if (medicationScheduleItem.scheduledMedicationOrder == null)
			{
				medicationTitrationHelper.relateMedicationOrderToSchedule(medicationScheduleItem);

				if (medicationScheduleItem.scheduledMedicationOrder == null)
				{
					// create and relate MedicationOrder if there is no order (but there is a schedule)
					createMedicationOrder(selection);
					medicationTitrationHelper.relateMedicationOrderToSchedule(medicationScheduleItem);
				}
			}

			if (medicationScheduleItem.scheduledMedicationOrder == null)
			{
				_logger.error("Failed to save schedule change for " + selection.getSummary() +
						". There is an existing schedule but no MedicationOrder. Failed to resolve the problem.");
				saveSucceeded = false;
			}
			else
			{
				var scheduleDose:Number = selection.getScheduleDose(medicationScheduleItem.scheduledMedicationOrder);

				// determine cut off date for schedule change
				// update existing MedicationScheduleItem (old dose) to end the recurrence by cut off date
				var scheduleChanger:ScheduleChanger = new ScheduleChanger(record, accountId, currentDateSource);
				saveSucceeded = scheduleChanger.updateScheduleItem(medicationScheduleItem,
						scheduleDetails.occurrence, function (scheduleItem:ScheduleItemBase):void
						{
							(scheduleItem as MedicationScheduleItem).dose.value = scheduleDose.toString();
						}, saveSucceeded);
			}
			return saveSucceeded;
		}

		private function createNewSchedule(selection:HypertensionMedicationDoseSelection):Boolean
		{
			var medicationOrder:MedicationOrder;

			// TODO: look for an existing matching (unscheduled) medication in the patient's record that we can use for scheduling instead of creating a new instance
			//						medicationOrder = findMatchingMedicationOrder(medication);

			medicationOrder = createMedicationOrder(selection);
			createMedicationScheduleItems(medicationOrder, selection);
			return true;
		}

		private function createMedicationOrder(selection:HypertensionMedicationDoseSelection):MedicationOrder
		{
			var codedValueFactory:CodedValueFactory = new CodedValueFactory();

			var medicationOrder:MedicationOrder = new MedicationOrder();
			medicationOrder.name = new CollaboRhythmCodedValue(MedicationOrder.RXCUI_CODED_VALUE_TYPE, selection.rxNorm, null,
					selection.medicationName.rawName);
			// TODO: should there be a different order type for this type of situation?
			medicationOrder.orderType = MedicationOrder.PRESCRIBED_ORDER_TYPE;
			medicationOrder.orderedBy = _activeAccount.accountId;
			medicationOrder.dateOrdered = _currentDateSource.now();
			//TODO: Indication should not be required by the server. This can be removed once this is fixed
			//Alternatively, the UI could allow an indication to be specified
			medicationOrder.indication = ESSENTIAL_HYPERTENSION_INDICATION;
			var doseUnit:CollaboRhythmCodedValue = codedValueFactory.createTabletCodedValue();
			medicationOrder.amountOrdered = new CollaboRhythmValueAndUnit(DEFAULT_RECURRENCE_COUNT.toString(), doseUnit);
			medicationOrder.instructions = DEFAULT_MEDICATION_INSTRUCTIONS;

			medicationOrder.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationOrder);

			createMedicationFill(medicationOrder, selection);

			return medicationOrder;
		}

		private function createMedicationFill(medicationOrder:MedicationOrder,
											  selection:HypertensionMedicationDoseSelection):void
		{
			var medicationFill:MedicationFill = new MedicationFill();
			medicationFill.name = medicationOrder.name;
			medicationFill.filledBy = _activeAccount.accountId;
			medicationFill.dateFilled = _currentDateSource.now();
			medicationFill.amountFilled = medicationOrder.amountOrdered;
			medicationFill.ndc = new CollaboRhythmCodedValue(null, null, null, selection.defaultNdcCode);

			medicationFill.pendingAction = DocumentBase.ACTION_CREATE;
			_activeRecordAccount.primaryRecord.addDocument(medicationFill);

			medicationOrder.medicationFill = medicationFill;
			_activeRecordAccount.primaryRecord.addRelationship(MedicationOrder.RELATION_TYPE_MEDICATION_FILL,
					medicationOrder, medicationFill, true);
		}

		private function createMedicationScheduleItems(medicationOrder:MedicationOrder, selection:HypertensionMedicationDoseSelection):void
		{
			var scheduleCreator:ScheduleCreator = new ScheduleCreator(_activeRecordAccount.primaryRecord, _activeAccount.accountId, _currentDateSource);

			for (var i:int = 0; i < DEFAULT_SCHEDULE_ADMINISTRATIONS_PER_DAY; i++)
			{
				var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
				medicationScheduleItem.meta.id = UIDUtil.createUID();
				medicationScheduleItem.name = medicationOrder.name.clone();
				scheduleCreator.initializeDefaultSchedule(medicationScheduleItem);

				var codedValueFactory:CodedValueFactory = new CodedValueFactory();
				medicationScheduleItem.dose = new CollaboRhythmValueAndUnit(selection.getScheduleDose(medicationOrder).toString(), codedValueFactory.createTabletCodedValue());
				medicationScheduleItem.instructions = DEFAULT_MEDICATION_INSTRUCTIONS;

				medicationScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;
				_activeRecordAccount.primaryRecord.addDocument(medicationScheduleItem);

				medicationScheduleItem.scheduledMedicationOrder = medicationOrder;
				_activeRecordAccount.primaryRecord.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
						medicationOrder, medicationScheduleItem, true);
			}
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
				var selections:Vector.<HypertensionMedicationDoseSelection> = getSelectionsAndCompareWithSystem();
				var agreeWithSystemString:String = selectionsAgreeWithSystem ? "agrees" : "does not agree";

				headerMessage = "Your decision below " + agreeWithSystemString + " with the MAP";

				if (selections.length > 0)
				{
					var parts:Array = getSelectionsSummary(selections);
					selectionsMessage = parts.join("\n");
				}
				else
				{
					selectionsMessage = "Keep all medications at current doses";
				}

				confirmationMessage = headerMessage + "\n\n" + selectionsMessage;
//				var changeVerb:String = isPatient ? "make" : "suggest";
//				var maintainVerb:String = isPatient ? "keep" : "suggest keeping";
//				var medicationsOwner:String = isPatient ? "your" : "the patient's";
//				if (selections.length > 0)
//				{
//					var parts:Array = getSelectionsSummary(selections);
//					confirmationMessage = "You have chosen to " + changeVerb + " the following " +
//							StringUtils.pluralize("change", parts.length) + " to " + medicationsOwner +
//							" hypertension medications.\n\n" +
//							parts.join("\n");
//				}
//				else
//				{
//					confirmationMessage = "You have chosen to " + maintainVerb + " all of " + medicationsOwner +
//							" hypertension medications at current levels.";
//				}
//
//				// TODO: Finalize should commit the current user's changes, not necessarily the patient's
//				confirmationMessage += "\n\nPropose will save your decision annotations for you and others to view." +
//						"\nFinalize will commit " + medicationsOwner + " changes to the medications and clear all annotations.";

			}
			else
			{
				confirmationMessage = null;
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

		private function getSelectionsAndCompareWithSystem():Vector.<HypertensionMedicationDoseSelection>
		{
			selectionsAgreeWithSystem = true;

			var selections:Vector.<HypertensionMedicationDoseSelection> = new <HypertensionMedicationDoseSelection>[];
			for each (var pair:HypertensionMedicationAlternatePair in _hypertensionMedicationAlternatePairsVector)
			{
				for each (var medication:HypertensionMedication in pair.medications)
				{
					var systemSelection:HypertensionMedicationDoseSelection;
					var userSelection:HypertensionMedicationDoseSelection;

					for each (var selection:HypertensionMedicationDoseSelection in medication.doseSelections)
					{
						if (selection.selectionType == HypertensionMedicationDoseSelection.SYSTEM)
						{
							systemSelection = selection;
						}
						else if (selection.selectionByAccount && selection.selectionByAccount.accountId == accountId)
						{
							userSelection = selection;
							selections.push(selection);
						}
					}

					if (systemSelection)
					{
						if (userSelection)
						{
							if (systemSelection.newDose != userSelection.newDose)
							{
								selectionsAgreeWithSystem = false;
							}
						}
						else
						{
							selectionsAgreeWithSystem = false;
						}
					}
					else
					{
						if (userSelection)
						{
							selectionsAgreeWithSystem = false;
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

		private function saveTitrationResult(selections:Vector.<HypertensionMedicationDoseSelection>):void
		{
			var parentForTitrationDecisionResult:DocumentBase = getParentForTitrationDecisionResult();

			var titrationResult:HealthActionResult = new HealthActionResult();
			titrationResult.name = new CollaboRhythmCodedValue(null, null, null, TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME);
			titrationResult.reportedBy = accountId;
			titrationResult.dateReported = currentDateSource.now();
			if (selections.length > 0)
			{
				titrationResult.actions = new ArrayCollection();
			}

			for each (var selection:HypertensionMedicationDoseSelection in selections)
			{
				selection.persisted = true;

				var actionStepResult:ActionStepResult = new ActionStepResult();
				actionStepResult.name = new CollaboRhythmCodedValue(null, null, null,
						isPatient ? PATIENT_DECISION_ACTION_STEP_RESULT_NAME : CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME);
				actionStepResult.occurrences = new ArrayCollection();
				var occurrence:Occurrence = new Occurrence();
				occurrence.additionalDetails = selection.medication.medicationName;
				occurrence.stopCondition = new StopCondition();
				occurrence.stopCondition.name = new CollaboRhythmCodedValue(null, null, null, "agreement");
				occurrence.stopCondition.value = new CollaboRhythmValueAndUnit(null, null,
						selection.isInAgreement() ? AGREE_STOP_CONDITION_NAME : NEW_STOP_CONDITION_NAME);
				occurrence.measurements = new ArrayCollection();
				var measurementNewDose:Measurement = new Measurement();
				measurementNewDose.name = new CollaboRhythmCodedValue(null, null, null, "newDose");
				measurementNewDose.value = new CollaboRhythmValueAndUnit(selection.newDose.toString(),
						createDoseStrengthCodeCodedValue());
				occurrence.measurements.addItem(measurementNewDose);
				var measurementDoseSelected:Measurement = new Measurement();
				measurementDoseSelected.name = new CollaboRhythmCodedValue(null, null, null, "doseSelected");
				measurementDoseSelected.value = new CollaboRhythmValueAndUnit(selection.doseSelected.toString(),
						createDoseStrengthCodeCodedValue());
				occurrence.measurements.addItem(measurementDoseSelected);
				actionStepResult.occurrences.addItem(occurrence);
				titrationResult.actions.addItem(actionStepResult);
			}

			record.addDocument(titrationResult, true);

			record.addRelationship(HealthActionResult.RELATION_TYPE_TITRATION_DECISION, parentForTitrationDecisionResult, titrationResult, true);
		}

		private static const HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME:String = "Hypertension Medication Titration Decision";

		/**
		 * Finds the document that should be used as the parent for titration decision result(s), or creates one if it does not exist.
		 * @return a document that can be used as the parent for titration decision result(s)
		 */
		private function getParentForTitrationDecisionResult(createIfNeeded:Boolean = true):DocumentBase
		{
			return getTitrationDecisionPlan(createIfNeeded);
		}

		/**
		 * Finds the HealthActionPlan for hypertension medication titration decision, or creates one if it does not exist.
		 * @return a HealthActionPlan corresponding to the titration decision
		 */
		private function getTitrationDecisionPlan(createIfNeeded:Boolean):HealthActionPlan
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
				titrationDecisionPlan.name = new CollaboRhythmCodedValue(null, null, null,
						HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME);
				titrationDecisionPlan.planType = "Prescribed";
				titrationDecisionPlan.plannedBy = accountId;
				titrationDecisionPlan.datePlanned = _currentDateSource.now();
				titrationDecisionPlan.indication = ESSENTIAL_HYPERTENSION_INDICATION;
				titrationDecisionPlan.instructions = "Use CollaboRhythm to follow the algorithm for changing your dose of hypertension medications.";
				titrationDecisionPlan.system = new CollaboRhythmCodedValue(null, null, null,
						"CollaboRhythm Hypertension Titration Support");

				record.addDocument(titrationDecisionPlan, true);
			}

			return titrationDecisionPlan;
		}

		private static function createDoseStrengthCodeCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue("http://indivo.org/codes/units#", "DoseStrengthCode", "DSU", "DoseStrengthCode");
		}


		override protected function getAccountForSelectionAction(ctrlKey:Boolean):Account
		{
			return ctrlKey ? (isPatient ? getCoachAccount() : _activeRecordAccount) : _activeAccount;
		}

		private function getCoachAccount():Account
		{
			if (_settings.primaryClinicianTeamMember)
			{
				var account:Account = new Account();
				account.accountId = _settings.primaryClinicianTeamMember;
				return account;
			}
			return null;
		}

		override protected function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function get selectionsAgreeWithSystem():Boolean
		{
			return _selectionsAgreeWithSystem;
		}

		public function set selectionsAgreeWithSystem(value:Boolean):void
		{
			_selectionsAgreeWithSystem = value;
		}

		public function get selectionsMessage():String
		{
			return _selectionsMessage;
		}

		public function set selectionsMessage(value:String):void
		{
			_selectionsMessage = value;
		}

		public function get headerMessage():String
		{
			return _headerMessage;
		}

		public function set headerMessage(value:String):void
		{
			_headerMessage = value;
		}
	}
}
