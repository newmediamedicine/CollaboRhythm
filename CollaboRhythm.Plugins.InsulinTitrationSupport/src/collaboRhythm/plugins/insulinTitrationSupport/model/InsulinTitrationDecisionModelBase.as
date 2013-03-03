package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.insulinTitrationSupport.model.states.InsulinTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleChanger;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleDetails;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.ITitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.StopCondition;
	import collaboRhythm.shared.model.medications.MedicationTitrationHelper;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.DefaultVitalSignChartModifier;

	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;

	[Bindable]
	public class InsulinTitrationDecisionModelBase extends TitrationDecisionModelBase
	{
		private static const REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS:int = 3;
		private static const REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE:int = 4;
		private static const NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_GLUCOSE:int = 4;

		private static const STEP_1_STATE_DESCRIPTION_REQUIREMENTS_MET:String = "There <b>are</b> at least three acceptable blood glucose measurements for the protocol that conform the following rules: ";
		private static const STEP_1_STATE_DESCRIPTION_REQUIREMENTS_NOT_MET:String = "There are <b>not</b> at least three acceptable blood glucose measurements for the protocol that conform the following rules: ";
		private static const BLOOD_GLUCOSE_REQUIREMENTS:String = "<ol>" +
				"<li>Only the first measurement each day</li>" +
				"<li>Taken before eating (preprandial)</li>" +
				"<li>Since your last change in insulin dose{0}</li>" +
				"<li>Within the past " + NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_GLUCOSE + " days (one must be this morning) </li>" +
				"</ol>";
		private static const BLOOD_GLUCOSE_REQUIREMENTS_DETAILS_LAST_TITRATION:String = " (the first dose of {0} Units was on {1})";
		private static const BLOOD_GLUCOSE_REQUIREMENTS_DETAILS_NO_DOSE_INFORMATION:String = " (but titration information could not be determined)";

		private static const STEP_2_STATE_DESCRIPTION_MEDICATION_ADHERENCE_PERFECT:String = "Medication adherence for the past three days <b>is</b> perfect.";
		private static const STEP_2_STATE_DESCRIPTION_MEDICATION_ADHERENCE_NOT_PERFECT:String = "Medication adherence for the past three days is <b>not</b> perfect. ";


		private static const TITRATION_LEADING_PHRASE_TO_CLINICIAN_DISAGREE:String = "[Automated Message] New insulin titration: ";
		private static const TITRATION_LEADING_PHRASE_TO_CLINICIAN_AGREE:String = "[Automated Message] Agreed insulin titration: ";
		private static const TITRATION_LEADING_PHRASE_TO_PATIENT_DISAGREE:String = "[Automated Message] Advised insulin titration: ";
		private static const TITRATION_LEADING_PHRASE_TO_PATIENT_AGREE:String = "[Automated Message] Agreed insulin titration: ";
		/**
		 * Phrase used to start the titration decision message when a change is made to the dose.
		 * {0} previous dose
		 * {1} change (including + or - operator)
		 * {2} new dose
		 */
		private static const TITRATION_DECISION_PHRASE_WITH_CHANGE:String = "{0} Units {1} Units = {2} Units";
		/**
		 * Phrase used to start the titration decision message when no change is made to the dose.
		 * {0} previous dose
		 */
		private static const TITRATION_DECISION_PHRASE_NO_CHANGE:String = "no change, dose remains {0} Units";

		/**
		 * Message sent to clinician when insulin titration decision is made and the decision matches the protocol recommendation.
		 * {0} titration decision phrase
		 * {1} average blood glucose value
		 */
		private static const TITRATION_DECISION_MESSAGE_PROTOCOL_FOLLOWED:String = "{0} (consistent with 303 Protocol for average blood glucose of {1})";
		/**
		 * Message sent to clinician when insulin titration decision is made but the decision does not match the protocol recommendation.
		 * {0} titration decision phrase
		 * {1} protocol recommended change (including + or - operator) and Units, or "no change"
		 * {2} average blood glucose value
		 */
		private static const TITRATION_DECISION_MESSAGE_PROTOCOL_NOT_FOLLOWED:String = "{0} (note: 303 Protocol recommends {1} for average blood glucose of {2})";
		/**
		 * Message sent to clinician when insulin titration decision is made but one or more of the prerequisites of the protocol have not been met.
		 * {0} titration decision phrase
		 */
		private static const TITRATION_DECISION_MESSAGE_MISSING_PREREQUISITES:String = "{0} (note: prerequisites of the 303 Protocol not met)";

		private var _dosageChangeValue:Number;
		private var _persistedDosageChangeValue:Number;
		private var _algorithmSuggestsIncreaseDose:Boolean = true;
		private var _algorithmSuggestsNoChangeDose:Boolean;
		private var _algorithmSuggestsDecreaseDose:Boolean;
		private const _dosageIncreaseText:String = "+3";
		private const _dosageDecreaseText:String = "-3";
		private const _dosageIncreaseValue:Number = +3;
		private const _dosageDecreaseValue:Number = -3;


		private var _scheduleDetails:ScheduleDetails;
		private var _currentDoseValue:Number;
		private var _newDose:Number;
		private var _previousDoseValue:Number;

		private var _medicationTitrationHelper:MedicationTitrationHelper;
		private var _bloodGlucoseRequirementsDetails:String;
		private var _algorithmSuggestedDoseChange:Number;
		private var _algorithmSuggestedDoseChangeLabel:String;
		private var _instructionsHtml:String;
		private var _isNewDoseDifferentFromOtherPartyLatest:Boolean;


		private var _latestDecisionDose:Number;
		private var _patientLatestDecisionDose:Number;
		private var _clinicianLatestDecisionDose:Number;
		private var _otherPartyLatestDecisionDose:Number;
		private var _initializedDosageChangeValue:Boolean;

		public function InsulinTitrationDecisionModelBase()
		{
			super();
			_protocolVitalSignCategory = VitalSignsModel.BLOOD_GLUCOSE_CATEGORY;
			_requiredNumberVitalSigns = REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS;
			_numberOfDaysForEligibleVitalSigns = NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_GLUCOSE;
			requiredDaysOfPerfectMedicationAdherence = REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE;
			_medicationTitrationHelper = new MedicationTitrationHelper(record, currentDateSource);
			verticalAxisMinimum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_VERTICAL_AXIS_MINIMUM;
			verticalAxisMaximum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_VERTICAL_AXIS_MAXIMUM;
			goalZoneMinimum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_GOAL_ZONE_MINIMUM;
			goalZoneMaximum = DefaultVitalSignChartModifier.BLOOD_GLUCOSE_GOAL_ZONE_MAXIMUM;
			goalZoneColor = DefaultVitalSignChartModifier.GOAL_ZONE_COLOR;
			initializeStates();
		}

		public function initializeStates():void
		{
			var array:Array = componentContainer.resolveAll(ITitrationDecisionSupportStatesFileStore);
			if (array && array.length > 0)
			{
				var fileStore:InsulinTitrationDecisionSupportStatesFileStore = array[0] as
						InsulinTitrationDecisionSupportStatesFileStore;
				_states = fileStore.titrationDecisionSupportStates;
			}
		}

		override protected function getFirstAdministrationDateOfPreviousSchedule():Date
		{
			if (_scheduleDetails && _scheduleDetails.previousSchedule)
			{
				var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = _scheduleDetails.previousSchedule.getScheduleItemOccurrences();
				for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
				{
					if (scheduleItemOccurrence.adherenceItem && scheduleItemOccurrence.adherenceItem.adherence)
					{
						var adherenceResults:Vector.<DocumentBase> = scheduleItemOccurrence.adherenceItem.adherenceResults;
						var medicationAdministration:MedicationAdministration = adherenceResults.length > 0 ? adherenceResults[0] as MedicationAdministration : null;
						if (medicationAdministration)
						{
							bloodGlucoseRequirementsDetails = StringUtil.substitute(BLOOD_GLUCOSE_REQUIREMENTS_DETAILS_LAST_TITRATION, medicationAdministration.amountAdministered.value, medicationAdministration.dateAdministered.toLocaleString());
							return medicationAdministration.dateAdministered;
						}
					}
				}
			}

			// schedule not yet determined or otherwise unavailable; use now as a conservative alternative for this constraint
			bloodGlucoseRequirementsDetails = BLOOD_GLUCOSE_REQUIREMENTS_DETAILS_NO_DOSE_INFORMATION;
			return currentDateSource.now();
		}

		protected override function updateStep1State():void
		{
			step1StateDescription = (areProtocolMeasurementRequirementsMet ?
					STEP_1_STATE_DESCRIPTION_REQUIREMENTS_MET :
					STEP_1_STATE_DESCRIPTION_REQUIREMENTS_NOT_MET) +
					StringUtil.substitute(BLOOD_GLUCOSE_REQUIREMENTS, bloodGlucoseRequirementsDetails);

			step1State = areProtocolMeasurementRequirementsMet ? STEP_SATISFIED : STEP_STOP;
			updateStep2State();
		}

		protected override function updateStep2State():void
		{
			step2StateDescription = isAdherencePerfect ?
					STEP_2_STATE_DESCRIPTION_MEDICATION_ADHERENCE_PERFECT :
					STEP_2_STATE_DESCRIPTION_MEDICATION_ADHERENCE_NOT_PERFECT + nonAdherenceDescription;
			step2State = step1State == STEP_SATISFIED ? (isAdherencePerfect ? STEP_SATISFIED : STEP_STOP) : STEP_PREVIOUS_STOP;
			updateStep3State();
		}

		protected override function updateStep3State():void
		{
			step3State = step2State == STEP_SATISFIED ? STEP_SATISFIED : STEP_PREVIOUS_STOP;
			updateStep4State();
		}

		private function updateStep4State():void
		{
			step4State = step3State == STEP_SATISFIED ? STEP_SATISFIED : STEP_PREVIOUS_STOP;
			updateInstructions();
		}

		private function updateInstructions():void
		{
			instructionsSteps = getSteps();
		}

		public function get dosageChangeValue():Number
		{
			return _dosageChangeValue;
		}

		public function set dosageChangeValue(value:Number):void
		{
			_dosageChangeValue = value;
			isChangeSpecified = !isNaN(_dosageChangeValue);
			evaluateForSave();
			isNewDoseDifferentFromOtherPartyLatest = _newDose != _otherPartyLatestDecisionDose;
		}

		public function get algorithmSuggestsIncreaseDose():Boolean
		{
			return _algorithmSuggestsIncreaseDose;
		}

		public function set algorithmSuggestsIncreaseDose(value:Boolean):void
		{
			_algorithmSuggestsIncreaseDose = value;
		}

		public function get algorithmSuggestsNoChangeDose():Boolean
		{
			return _algorithmSuggestsNoChangeDose;
		}

		public function set algorithmSuggestsNoChangeDose(value:Boolean):void
		{
			_algorithmSuggestsNoChangeDose = value;
		}

		public function get algorithmSuggestsDecreaseDose():Boolean
		{
			return _algorithmSuggestsDecreaseDose;
		}

		public function set algorithmSuggestsDecreaseDose(value:Boolean):void
		{
			_algorithmSuggestsDecreaseDose = value;
		}

		public function get dosageIncreaseText():String
		{
			return _dosageIncreaseText;
		}

		public function get dosageDecreaseText():String
		{
			return _dosageDecreaseText;
		}

		public function get dosageIncreaseValue():Number
		{
			return _dosageIncreaseValue;
		}

		public function get dosageDecreaseValue():Number
		{
			return _dosageDecreaseValue;
		}

		override protected function updateAlgorithmSuggestions():void
		{
			algorithmSuggestsIncreaseDose = algorithmPrerequisitesSatisfied && algorithmValuesAvailable() && protocolMeasurementAverage > goalZoneMaximum;
			algorithmSuggestsNoChangeDose = algorithmPrerequisitesSatisfied && algorithmValuesAvailable() && protocolMeasurementAverage <= goalZoneMaximum && protocolMeasurementAverage >= goalZoneMinimum;
			algorithmSuggestsDecreaseDose = algorithmPrerequisitesSatisfied && algorithmValuesAvailable() && protocolMeasurementAverage < goalZoneMinimum;

			if (algorithmSuggestsIncreaseDose)
			{
				algorithmSuggestedDoseChange = dosageIncreaseValue;
				algorithmSuggestedDoseChangeLabel = dosageIncreaseText + " Units";
			}
			else if (algorithmSuggestsNoChangeDose)
			{
				algorithmSuggestedDoseChange = 0;
				algorithmSuggestedDoseChangeLabel = "no change";
			}
			else if (algorithmSuggestsDecreaseDose)
			{
				algorithmSuggestedDoseChange = dosageDecreaseValue;
				algorithmSuggestedDoseChangeLabel = dosageDecreaseText + " Units";
			}
			else
			{
				algorithmSuggestedDoseChange = NaN;
				algorithmSuggestedDoseChangeLabel = "";
			}
		}

		public function evaluateForSave():void
		{
			validateDecisionPreConditions();

			// validate
			if (isChangeSpecified)
			{
				_scheduleDetails = _medicationTitrationHelper.getNextMedicationScheduleDetails(InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES);
				_currentDoseValue = _medicationTitrationHelper.currentDoseValue;
				_previousDoseValue = _medicationTitrationHelper.previousDoseValue;
				_newDose = (isNaN(_previousDoseValue) ? 0 : _previousDoseValue) + dosageChangeValue;
			}

			confirmationMessage = !isPatient ||
					!_clinicianLatestDecisionResult ? (algorithmPrerequisitesSatisfied ? (_dosageChangeValue ==
					algorithmSuggestedDoseChange ? "This change agrees with the 303 Protocol." : "This change does not agree with the 303 Protocol.") : "Prerequisites of the 303 Protocol not met.") : (_newDose ==
					_clinicianLatestDecisionDose ? "This change agrees with your coach’s advice." : "This change does not agree with your coach’s advice.")
		}

		override protected function validateDecisionPreConditions():void
		{
			if (decisionScheduleItemOccurrence == null)
				throw new Error("Failed to save. Decision data on the health charts model was not a ScheduleItemOccurrence.");
		}

		override public function evaluateForInitialize():void
		{
			if (decisionScheduleItemOccurrence == null)
				return;

			_scheduleDetails = _medicationTitrationHelper.getNextMedicationScheduleDetails(InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES, evaluateTodayOnly);
			_currentDoseValue = _medicationTitrationHelper.currentDoseValue;
			_previousDoseValue = _medicationTitrationHelper.previousDoseValue;
			if (!_initializedDosageChangeValue)
			{
				_newDose = _medicationTitrationHelper.currentDoseValue;
				_dosageChangeValue = _medicationTitrationHelper.dosageChangeValue;
				_initializedDosageChangeValue = true;
			}
			persistedDosageChangeValue = _medicationTitrationHelper.dosageChangeValue;

			updateLatestDecisionDoses();

			isChangeSpecified = !isNaN(_dosageChangeValue);
			isNewDoseDifferentFromOtherPartyLatest = _newDose != _otherPartyLatestDecisionDose;

			updateIsAdherencePerfect();
			updateProtocolMeasurementAverage();
		}

		private function updateLatestDecisionDoses():void
		{
			var parentForTitrationDecisionResult:DocumentBase = getParentForTitrationDecisionResult(_scheduleDetails.currentSchedule as MedicationScheduleItem);
			if (parentForTitrationDecisionResult)
			{
				getLatestDecisionResults(parentForTitrationDecisionResult);
				latestDecisionDose = getDecisionDoseFromResult(_latestDecisionResult);
				patientLatestDecisionDose = getDecisionDoseFromResult(_patientLatestDecisionResult);
				clinicianLatestDecisionDose = getDecisionDoseFromResult(_clinicianLatestDecisionResult);
				otherPartyLatestDecisionDose = getDecisionDoseFromResult(_otherPartyLatestDecisionResult);
			}
		}

		public function save():Boolean
		{
			var saveSucceeded:Boolean = true;

			validateDecisionPreConditions();

			var healthActionSchedule:HealthActionSchedule = decisionScheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			var plan:HealthActionPlan = healthActionSchedule.scheduledHealthAction as HealthActionPlan;

			// validate
			if (isChangeSpecified)
			{
				evaluateForSave();

				if (_scheduleDetails.isCurrentScheduleDetermined)
				{
					var currentMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.currentSchedule as
							MedicationScheduleItem;
					if (isPatient)
						saveSucceeded = saveForPatient(currentMedicationScheduleItem, plan, saveSucceeded);
					else
						saveSucceeded = saveForClinician(currentMedicationScheduleItem, plan, saveSucceeded);

					saveTitrationResult(currentMedicationScheduleItem);
					evaluateForInitialize();
				}
				else
				{
					// TODO: warn the user why the dose cannot be changed; possibly provide a means to fix the problem
					_logger.warn("User is attempting to change the dose but the current schedule/dose could not be determined.");
					return false;
				}
			}

			return saveSucceeded;
		}

		private function saveTitrationResult(currentMedicationScheduleItem:MedicationScheduleItem):void
		{
			var parentForTitrationDecisionResult:DocumentBase = getParentForTitrationDecisionResult(currentMedicationScheduleItem);

			var titrationResult:HealthActionResult = new HealthActionResult();
			titrationResult.name = new CollaboRhythmCodedValue(null, null, null, TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME);
			titrationResult.reportedBy = accountId;
			titrationResult.dateReported = currentDateSource.now();
			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CollaboRhythmCodedValue(null, null, null, isPatient ? PATIENT_DECISION_ACTION_STEP_RESULT_NAME : CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			var occurrence:Occurrence = new Occurrence();
			occurrence.stopCondition = new StopCondition();
			occurrence.stopCondition.name = new CollaboRhythmCodedValue(null, null, null, newDoseIsInAgreement() ? AGREE_STOP_CONDITION_NAME : NEW_STOP_CONDITION_NAME);
			occurrence.stopCondition.value = new CollaboRhythmValueAndUnit(_newDose.toString(), createUnitsCodedValue());
			actionStepResult.occurrences.addItem(occurrence);
			titrationResult.actions = new ArrayCollection();
			titrationResult.actions.addItem(actionStepResult);

			record.addDocument(titrationResult, true);

			record.addRelationship(HealthActionResult.RELATION_TYPE_TITRATION_DECISION, parentForTitrationDecisionResult, titrationResult, true);
		}

		private function newDoseIsInAgreement():Boolean
		{
			return _otherPartyLatestDecisionDose == _newDose;
		}

		private function getParentForTitrationDecisionResult(currentMedicationScheduleItem:MedicationScheduleItem):DocumentBase
		{
			var administeredOccurrenceCount:int = (_scheduleDetails && _scheduleDetails.occurrence) ? _scheduleDetails.occurrence.recurrenceIndex : 0;
			if (administeredOccurrenceCount > 0)
			{
				return currentMedicationScheduleItem;
			}
			else if (_scheduleDetails.previousSchedule)
			{
				return _scheduleDetails.previousSchedule;
			}
			else if (_scheduleDetails.currentSchedule is MedicationScheduleItem)
			{
				// When we are changing the dose of the first scheduled occurrence of the medication, there is no
				// previous schedule to record titration decision results against, so use the MedicationOrder instead.
				return (_scheduleDetails.currentSchedule as MedicationScheduleItem).scheduledMedicationOrder;
			}
			return null;
		}

		protected function saveForClinician(currentMedicationScheduleItem:MedicationScheduleItem, plan:HealthActionPlan,
										  saveSucceeded:Boolean):Boolean
		{
			var message:String = getMessage(_newDose == _patientLatestDecisionDose ?
					TITRATION_LEADING_PHRASE_TO_PATIENT_AGREE : TITRATION_LEADING_PHRASE_TO_PATIENT_DISAGREE);
			sendMessage(message);
			return saveSucceeded;
		}

		protected function saveForPatient(currentMedicationScheduleItem:MedicationScheduleItem, plan:HealthActionPlan,
										saveSucceeded:Boolean):Boolean
		{
			saveNewScheduledDecision(plan);

			// if dose is specified and is different, update existing and/or create a new schedule
			if (_newDose != _currentDoseValue)
			{
				saveSucceeded = saveSucceeded && saveDosageChange(currentMedicationScheduleItem);
			}

			var message:String = getMessage(_newDose == _clinicianLatestDecisionDose ?
					TITRATION_LEADING_PHRASE_TO_CLINICIAN_AGREE : TITRATION_LEADING_PHRASE_TO_CLINICIAN_DISAGREE);
			sendMessage(message);
			return saveSucceeded;
		}

		private function getMessage(leadingPhrase:String):String
		{
			var titrationPhrase:String = leadingPhrase + (_newDose == _previousDoseValue ?
					StringUtil.substitute(TITRATION_DECISION_PHRASE_NO_CHANGE, _previousDoseValue) :
					StringUtil.substitute(TITRATION_DECISION_PHRASE_WITH_CHANGE, _previousDoseValue,
							dosageChangeValueLabel, _newDose));
			var message:String;
			if (algorithmPrerequisitesSatisfied)
			{
				if (_dosageChangeValue == algorithmSuggestedDoseChange)
				{
					message = StringUtil.substitute(TITRATION_DECISION_MESSAGE_PROTOCOL_FOLLOWED, titrationPhrase,
							bloodGlucoseAverageLabel);
				}
				else
				{
					message = StringUtil.substitute(TITRATION_DECISION_MESSAGE_PROTOCOL_NOT_FOLLOWED, titrationPhrase,
							algorithmSuggestedDoseChangeLabel, bloodGlucoseAverageLabel);
				}
			}
			else
			{
				message = StringUtil.substitute(TITRATION_DECISION_MESSAGE_MISSING_PREREQUISITES, titrationPhrase);
			}
			return message;
		}

		public function get bloodGlucoseAverageLabel():String
		{
			return protocolMeasurementAverage.toFixed(0);
		}

		private function saveDosageChange(currentMedicationScheduleItem:MedicationScheduleItem):Boolean
		{
			var saveSucceeded:Boolean = true;

			_medicationTitrationHelper.relateMedicationOrderToSchedule(currentMedicationScheduleItem);

			// determine cut off date for schedule change
			// update existing MedicationScheduleItem (old dose) to end the recurrence by cut off date
			var scheduleChanger:ScheduleChanger = new ScheduleChanger(record, accountId, currentDateSource);
			saveSucceeded = scheduleChanger.updateScheduleItem(currentMedicationScheduleItem,
					_scheduleDetails.occurrence, function (scheduleItem:ScheduleItemBase):void
					{
						(scheduleItem as MedicationScheduleItem).dose.value = _newDose.toString();
					}, saveSucceeded);
			return saveSucceeded;
		}

		private static function createUnitsCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue("http://indivo.org/codes/units#", "Units", "U", "Units");
		}

		public function get currentDoseValue():Number
		{
			return _currentDoseValue;
		}

		public function get previousDoseValue():Number
		{
			return _previousDoseValue;
		}

		public function get newDose():Number
		{
			return _newDose;
		}

		public function get dosageChangeValueLabel():String
		{
			if (isNaN(dosageChangeValue))
				return "";
			else
				return dosageChangeValue > 0 ? "+" + dosageChangeValue.toString() : dosageChangeValue.toString();
		}

		public function get bloodGlucoseRequirementsDetails():String
		{
			return _bloodGlucoseRequirementsDetails;
		}

		public function set bloodGlucoseRequirementsDetails(value:String):void
		{
			_bloodGlucoseRequirementsDetails = value;
		}

		public function get algorithmSuggestedDoseChange():Number
		{
			return _algorithmSuggestedDoseChange;
		}

		public function set algorithmSuggestedDoseChange(value:Number):void
		{
			_algorithmSuggestedDoseChange = value;
		}

		public function get algorithmSuggestedDoseChangeLabel():String
		{
			return _algorithmSuggestedDoseChangeLabel;
		}

		public function set algorithmSuggestedDoseChangeLabel(value:String):void
		{
			_algorithmSuggestedDoseChangeLabel = value;
		}

		public function get instructionsHtml():String
		{
			return _instructionsHtml;
		}

		public function set instructionsHtml(value:String):void
		{
			_instructionsHtml = value;
		}

		public function get isNewDoseDifferentFromOtherPartyLatest():Boolean
		{
			return _isNewDoseDifferentFromOtherPartyLatest;
		}

		public function set isNewDoseDifferentFromOtherPartyLatest(value:Boolean):void
		{
			_isNewDoseDifferentFromOtherPartyLatest = value;
		}

		public function get persistedDosageChangeValue():Number
		{
			return _persistedDosageChangeValue;
		}

		public function set persistedDosageChangeValue(value:Number):void
		{
			_persistedDosageChangeValue = value;
		}

		public function get latestDecisionDose():Number
		{
			return _latestDecisionDose;
		}

		public function get patientLatestDecisionDose():Number
		{
			return _patientLatestDecisionDose;
		}

		public function get clinicianLatestDecisionDose():Number
		{
			return _clinicianLatestDecisionDose;
		}

		public function get otherPartyLatestDecisionDose():Number
		{
			return _otherPartyLatestDecisionDose;
		}

		public function set latestDecisionDose(value:Number):void
		{
			_latestDecisionDose = value;
		}

		public function set patientLatestDecisionDose(value:Number):void
		{
			_patientLatestDecisionDose = value;
		}

		public function set clinicianLatestDecisionDose(value:Number):void
		{
			_clinicianLatestDecisionDose = value;
		}

		public function set otherPartyLatestDecisionDose(value:Number):void
		{
			_otherPartyLatestDecisionDose = value;
		}

		public function get evaluateTodayOnly():Boolean
		{
			return false;
		}
	}
}
