package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.insulinTitrationSupport.model.states.InsulinTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.IInsulinTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.InsulinTitrationDecisionSupportState;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.Step;
	import collaboRhythm.shared.messages.model.IIndividualMessageHealthRecordService;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.StopCondition;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import com.dougmccune.controls.LimitedLinearAxis;

	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;
	import mx.charts.LinearAxis;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;

	[Bindable]
	public class InsulinTitrationDecisionModelBase
	{
		public static const STEP_SATISFIED:String = "satisfied";
		public static const STEP_STOP:String = "stop";
		public static const STEP_PREVIOUS_STOP:String = "previous stop";
		private static const REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS:int = 3;
		private static const REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE:int = 4;
		private static const NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_GLUCOSE:int = 4;

		private static const MILLISECONDS_IN_DAY:Number = 1000 * 60 * 60 * 24;

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

		private static const CHOSE_A_NEW_DOSE_ACTION_STEP_RESULT_TEXT:String = "Chose a new dose";

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

		/**
		 * Potentially useful during testing/debugging as a way to terminate the schedule for a medication, such as
		 * when you want to switch from one kind of insulin to another.
		 */
		private static const DISABLE_CREATION_OF_NEW_SCHEDULE:Boolean = false;

		private static const TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME:String = "Titration Decision";
		public static const PATIENT_DECISION_ACTION_STEP_RESULT_NAME:String = "Patient Decision";
		public static const CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME:String = "Clinician Decision";
		private static const AGREE_STOP_CONDITION_NAME:String = "Agree";
		private static const NEW_STOP_CONDITION_NAME:String = "New";

		private static const AGREE:String = "Agree";
		private static const NEW:String = "New";
		private static const NONE:String = "None";

		private var _areBloodGlucoseRequirementsMet:Boolean = true;
		private var _dosageChangeValue:Number;
		private var _persistedDosageChangeValue:Number;
		private var _isAdherencePerfect:Boolean = true;
		private var _algorithmSuggestsIncreaseDose:Boolean = true;
		private var _algorithmSuggestsNoChangeDose:Boolean;
		private var _algorithmSuggestsDecreaseDose:Boolean;
		private const _dosageIncreaseText:String = "+3";
		private const _dosageDecreaseText:String = "-3";
		private const _dosageIncreaseValue:Number = +3;
		private const _dosageDecreaseValue:Number = -3;
		private var _isChangeSpecified:Boolean;

		private var _step1State:String;
		private var _step2State:String;
		private var _step3State:String;
		private var _step4State:String;

		private var _step1StateDescription:String = "";
		private var _step2StateDescription:String = "";
		private var _step3StateDescription:String = "";
		private var _step4StateDescription:String = "";

		private var _bloodGlucoseAverage:Number;
		private var _verticalAxisMinimum:Number;
		private var _verticalAxisMaximum:Number;
		private var _goalZoneMinimum:Number;
		private var _goalZoneMaximum:Number;
		private var _goalZoneColor:uint;
		private var _isInitialized:Boolean;
		protected var _logger:ILogger;
		private var _eligibleBloodGlucoseMeasurements:Vector.<VitalSign>;

		private var _scheduleDetails:ScheduleDetails;
		private var _currentDoseValue:Number;
		private var _newDose:Number;
		private var _previousDoseValue:Number;
		private var _nonAdherenceDescription:String;

		private var _medicationTitrationHelper:MedicationTitrationHelper;
		private var _bloodGlucoseRequirementsDetails:String;
		private var _isBloodGlucoseMaximumExceeded:Boolean;
		private var _isBloodGlucoseMinimumExceeded:Boolean;
		private var _bloodGlucoseAverageRangeLimited:Number;
		private var _chartVerticalAxis:LinearAxis;
		private var _connectedChartVerticalAxisMaximum:Number;
		private var _connectedChartVerticalAxisMinimum:Number;
		private var _algorithmSuggestedDoseChange:Number;
		private var _algorithmSuggestedDoseChangeLabel:String;
		private var _instructionsHtml:String;
		private var _algorithmPrerequisitesSatisfied:Boolean;
		private var _isNewDoseDifferentFromOtherPartyLatest:Boolean;

		private var _latestDecisionResult:HealthActionResult;
		private var _patientLatestDecisionResult:HealthActionResult;
		private var _clinicianLatestDecisionResult:HealthActionResult;
		private var _otherPartyLatestDecisionResult:HealthActionResult;

		private var _latestDecisionDose:Number;
		private var _patientLatestDecisionDose:Number;
		private var _clinicianLatestDecisionDose:Number;
		private var _otherPartyLatestDecisionDose:Number;
		private var _states:ArrayCollection;
		private var _initializedDosageChangeValue:Boolean;

		private var _confirmationMessage:String;

		public function InsulinTitrationDecisionModelBase()
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_medicationTitrationHelper = new MedicationTitrationHelper(record, currentDateSource);
			initializeStates();
		}

		public function initializeStates():void
		{
			var array:Array = componentContainer.resolveAll(IInsulinTitrationDecisionSupportStatesFileStore);
			if (array && array.length > 0)
			{
				var fileStore:InsulinTitrationDecisionSupportStatesFileStore = array[0] as
						InsulinTitrationDecisionSupportStatesFileStore;
				_states = fileStore.insulinTitrationDecisionSupportStates;
			}
		}

		public function get record():Record
		{
			return null;
		}

		protected function get decisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			return null;
		}

		protected function get componentContainer():IComponentContainer
		{
			return null;
		}

		protected function get accountId():String
		{
			return null;
		}

		protected function get currentDateSource():ICurrentDateSource
		{
			return null;
		}

		private function updateBloodGlucoseAverage():void
		{
			pickEligibleBloodGlucoseMeasurements();
			bloodGlucoseAverage = getBloodGlucoseAverage();
			updateStep1State();
		}

		/**
		 * Picks the eligible blood glucose measurements for the 303 algorithm.
		 * For a blood glucose measurement to eligible for determining the average for the algorithm:
		 * 	1) must be the first measurement taken in the day
		 * 	2) must be taken before eating breakfast (preprandial)
		 * 	3) must be after the last titration and also in the last four days
		 */
		private function pickEligibleBloodGlucoseMeasurements():void
		{
			_eligibleBloodGlucoseMeasurements = new Vector.<VitalSign>();
			var bloodGlucoseArrayCollection:ArrayCollection = record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.BLOOD_GLUCOSE_CATEGORY);
			var previousBloodGlucose:VitalSign;
			var now:Date = currentDateSource.now();
			var timeConstraintValue:Number = SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf() - MILLISECONDS_IN_DAY * NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_GLUCOSE;
			var firstAdministrationDateOfPreviousSchedule:Number = getFirstAdministrationDateOfPreviousSchedule().valueOf();
			var eligibleWindowCutoff:Date = new Date(Math.max(timeConstraintValue, firstAdministrationDateOfPreviousSchedule));
			if (bloodGlucoseArrayCollection && bloodGlucoseArrayCollection.length > 0)
			{
				for each (var bloodGlucose:VitalSign in bloodGlucoseArrayCollection)
				{
					if (bloodGlucose.dateMeasuredStart.valueOf() > eligibleWindowCutoff.valueOf() && bloodGlucose.dateMeasuredStart.valueOf() < now.valueOf())
					{
						for each (var relationship:Relationship in bloodGlucose.isRelatedFrom)
						{
							// TODO: implement more robustly; for now we are assuming that any blood glucose that is an adherence result is the eligible preprandial measurement
							if (relationship.type == AdherenceItem.RELATION_TYPE_ADHERENCE_RESULT)
							{
								// TODO: find a better way to determine if the two measurements are in the same day
								if (previousBloodGlucose == null
										|| previousBloodGlucose.dateMeasuredStart.toDateString() != bloodGlucose.dateMeasuredStart.toDateString())
								{
									_eligibleBloodGlucoseMeasurements.push(bloodGlucose);
									previousBloodGlucose = bloodGlucose;
								}
							}
						}
					}
				}

				// remove the oldest so we only have the 3 most recent
				while (_eligibleBloodGlucoseMeasurements.length > REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS)
				{
					_eligibleBloodGlucoseMeasurements.shift();
				}
			}
		}

		private function getFirstAdministrationDateOfPreviousSchedule():Date
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

		public function get areBloodGlucoseRequirementsMet():Boolean
		{
			return _areBloodGlucoseRequirementsMet;
		}

		public function get isAverageAvailable():Boolean
		{
			return !isNaN(_bloodGlucoseAverage);
		}

		public function set areBloodGlucoseRequirementsMet(value:Boolean):void
		{
			_areBloodGlucoseRequirementsMet = value;
			updateStep1State();
		}

		private function updateStep1State():void
		{
			step1StateDescription = (areBloodGlucoseRequirementsMet ?
					STEP_1_STATE_DESCRIPTION_REQUIREMENTS_MET :
					STEP_1_STATE_DESCRIPTION_REQUIREMENTS_NOT_MET) +
					StringUtil.substitute(BLOOD_GLUCOSE_REQUIREMENTS, bloodGlucoseRequirementsDetails);

			step1State = areBloodGlucoseRequirementsMet ? STEP_SATISFIED : STEP_STOP;
			updateStep2State();
		}

		private function updateStep2State():void
		{
			step2StateDescription = isAdherencePerfect ?
					STEP_2_STATE_DESCRIPTION_MEDICATION_ADHERENCE_PERFECT :
					STEP_2_STATE_DESCRIPTION_MEDICATION_ADHERENCE_NOT_PERFECT + nonAdherenceDescription;
			step2State = step1State == STEP_SATISFIED ? (isAdherencePerfect ? STEP_SATISFIED : STEP_STOP) : STEP_PREVIOUS_STOP;
			updateStep3State();
		}

		private function updateStep3State():void
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
			var steps:ArrayCollection = getSteps();
			var stepsHtml:String = "";

			for each (var step:Step in steps)
			{
				var subStepsHtml:String = "";
				if (step.subSteps && step.subSteps.length > 0)
				{
					subStepsHtml = "<ul>";
					for each (var subStep:String in step.subSteps)
					{
						subStepsHtml += "<li>" +
								subStep +
								// put a line break in the last <li> in order to get the vertical spacing we want; putting the br elsewhere seems to result in two line breaks
								(subStep == step.subSteps[step.subSteps.length - 1] ? "<br/>" : "") +
								"</li>";
					}
					subStepsHtml += "</ul>";
				}
				else
				{
					subStepsHtml = "<br/>";
				}

				var stepHtml:String = "<Font color='" +
						(step.stepColor == "grey" ? "0x888888" : "0x000000") +
						"'><li>" +
						step.stepText +
						subStepsHtml +
						"</li></Font>";
				stepsHtml += stepHtml;
			}

			instructionsHtml = "<ol>" +
					stepsHtml +
					"</ol>"
		}

		public function get isChangeSpecified():Boolean
		{
			return _isChangeSpecified;
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

		public function get isAdherencePerfect():Boolean
		{
			return _isAdherencePerfect;
		}

		public function set isAdherencePerfect(value:Boolean):void
		{
			if (_isAdherencePerfect != value)
			{
				_isAdherencePerfect = value;
				updateStep2State();
			}
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

		public function set isChangeSpecified(value:Boolean):void
		{
			_isChangeSpecified = value;
			updateStep3State();
		}

		public function get step1State():String
		{
			return _step1State;
		}

		public function set step1State(value:String):void
		{
			_step1State = value;
		}

		public function get step2State():String
		{
			return _step2State;
		}

		public function set step2State(value:String):void
		{
			_step2State = value;
			algorithmPrerequisitesSatisfied = step2State == STEP_SATISFIED;
		}

		public function get step3State():String
		{
			return _step3State;
		}

		public function set step3State(value:String):void
		{
			_step3State = value;
		}

		public function get bloodGlucoseAverage():Number
		{
			return _bloodGlucoseAverage;
		}

		public function set bloodGlucoseAverage(value:Number):void
		{
			_bloodGlucoseAverage = value;
			updateOutsideRange();
			updateAreBloodGlucoseRequirementsMet();
			updateAlgorithmSuggestions();
		}

		private function updateOutsideRange():void
		{
			bloodGlucoseAverageRangeLimited = Math.min(verticalAxisMaximum, Math.max(verticalAxisMinimum, bloodGlucoseAverage));
			isBloodGlucoseMaximumExceeded = bloodGlucoseAverage > verticalAxisMaximum;
			isBloodGlucoseMinimumExceeded = bloodGlucoseAverage < verticalAxisMinimum;
		}

		public function updateAreBloodGlucoseRequirementsMet():void
		{
			areBloodGlucoseRequirementsMet = !isNaN(bloodGlucoseAverage) && _eligibleBloodGlucoseMeasurements != null &&
					_eligibleBloodGlucoseMeasurements.length >= REQUIRED_BLOOD_GLUCOSE_MEASUREMENTS &&
					isLastBloodGlucoseMeasurementFromToday();
		}

		private function isLastBloodGlucoseMeasurementFromToday():Boolean
		{
			var now:Date = currentDateSource.now();
			var startOfToday:Date = new Date(SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf() -
					MILLISECONDS_IN_DAY);

			if (_eligibleBloodGlucoseMeasurements && _eligibleBloodGlucoseMeasurements.length > 0)
			{
				var bloodGlucose:VitalSign = _eligibleBloodGlucoseMeasurements[_eligibleBloodGlucoseMeasurements.length -
						1];
				return bloodGlucose && bloodGlucose.dateMeasuredStart != null &&
						bloodGlucose.dateMeasuredStart.valueOf() >= startOfToday.valueOf();
			}
			return false;
		}

		private function updateAlgorithmSuggestions():void
		{
			algorithmSuggestsIncreaseDose = algorithmPrerequisitesSatisfied && algorithmValuesAvailable() && bloodGlucoseAverage > goalZoneMaximum;
			algorithmSuggestsNoChangeDose = algorithmPrerequisitesSatisfied && algorithmValuesAvailable() && bloodGlucoseAverage <= goalZoneMaximum && bloodGlucoseAverage >= goalZoneMinimum;
			algorithmSuggestsDecreaseDose = algorithmPrerequisitesSatisfied && algorithmValuesAvailable() && bloodGlucoseAverage < goalZoneMinimum;

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

		private function algorithmValuesAvailable():Boolean
		{
			return areBloodGlucoseRequirementsMet && !isNaN(goalZoneMinimum) && !isNaN(goalZoneMaximum);
		}

		public function get verticalAxisMinimum():Number
		{
			return _verticalAxisMinimum;
		}

		public function set verticalAxisMinimum(value:Number):void
		{
			_verticalAxisMinimum = value;
		}

		public function get verticalAxisMaximum():Number
		{
			return _verticalAxisMaximum;
		}

		public function set verticalAxisMaximum(value:Number):void
		{
			_verticalAxisMaximum = value;
		}

		public function get goalZoneMinimum():Number
		{
			return _goalZoneMinimum;
		}

		public function set goalZoneMinimum(value:Number):void
		{
			_goalZoneMinimum = value;
			updateAlgorithmSuggestions();
		}

		public function get goalZoneMaximum():Number
		{
			return _goalZoneMaximum;
		}

		public function set goalZoneMaximum(value:Number):void
		{
			_goalZoneMaximum = value;
			updateAlgorithmSuggestions();
		}

		public function get goalZoneColor():uint
		{
			return _goalZoneColor;
		}

		public function set goalZoneColor(value:uint):void
		{
			_goalZoneColor = value;
		}

		private function getBloodGlucoseAverage():Number
		{
			var bloodGlucoseSum:Number = 0;
			var bloodGlucoseCount:int = 0;

			for each (var bloodGlucose:VitalSign in _eligibleBloodGlucoseMeasurements)
			{
				bloodGlucoseSum += bloodGlucose.resultAsNumber;
				bloodGlucoseCount++;
			}

			var average:Number = NaN;
			if (bloodGlucoseCount > 0)
				average = bloodGlucoseSum / bloodGlucoseCount;
			return average;
		}

		internal function updateForRecordChange():void
		{
			this.isInitialized = false;
			BindingUtils.bindSetter(vitalSignsModel_isInitialized_setterHandler, record.vitalSignsModel,
					"isInitialized");
			BindingUtils.bindSetter(adherenceItemsModel_isInitialized_setterHandler, record.adherenceItemsModel,
					"isInitialized");
		}

		private function vitalSignsModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			if (isInitialized)
			{
				var vitalSignsBloodGlucose:ArrayCollection = record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.BLOOD_GLUCOSE_CATEGORY);
				if (vitalSignsBloodGlucose)
				{
					vitalSignsBloodGlucose.addEventListener(CollectionEvent.COLLECTION_CHANGE,
														vitalSignsDocuments_collectionChangeEvent);
				}
			}
			this.isInitialized = determineIsInitialized();
		}

		private function adherenceItemsModel_isInitialized_setterHandler(isInitialized:Boolean):void
		{
			if (isInitialized)
			{
				record.adherenceItemsModel.documents.addEventListener(CollectionEvent.COLLECTION_CHANGE,
													adherenceItemsModelDocuments_collectionChangeEvent, false);
			}
			this.isInitialized = determineIsInitialized();
		}

		private function determineIsInitialized():Boolean
		{
			return (record && record.vitalSignsModel.isInitialized && record.adherenceItemsModel.isInitialized);
		}

		private function vitalSignsDocuments_collectionChangeEvent(event:CollectionEvent):void
		{
			if (record.vitalSignsModel.isInitialized && (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.REMOVE))
			{
				updateBloodGlucoseAverage();
			}
		}

		private function adherenceItemsModelDocuments_collectionChangeEvent(event:CollectionEvent):void
		{
			if (record.adherenceItemsModel.isInitialized && (event.kind == CollectionEventKind.ADD || event.kind == CollectionEventKind.REMOVE))
			{
				updateIsAdherencePerfect();
			}
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			if (_isInitialized != value)
			{
				_isInitialized = value;
				updateIsAdherencePerfect();
				evaluateForInitialize();
			}
		}

		public function evaluateForSave():void
		{
			if (decisionScheduleItemOccurrence == null)
				throw new Error("Failed to save. Decision data on the health charts model was not a ScheduleItemOccurrence.");

			// validate
			if (isChangeSpecified)
			{
				_scheduleDetails = _medicationTitrationHelper.getNextMedicationScheduleDetails(InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES);
				_currentDoseValue = _medicationTitrationHelper.currentDoseValue;
				_previousDoseValue = _medicationTitrationHelper.previousDoseValue;
				_newDose = (isNaN(_previousDoseValue) ? 0 : _previousDoseValue) + dosageChangeValue;
			}

			_confirmationMessage = !isPatient ||
					!_clinicianLatestDecisionResult ? (algorithmPrerequisitesSatisfied ? (_dosageChangeValue ==
					algorithmSuggestedDoseChange ? "This change agrees with the 303 Protocol." : "This change does not agree with the 303 Protocol.") : "Prerequisites of the 303 Protocol not met.") : (_newDose ==
					_clinicianLatestDecisionDose ? "This change agrees with your coach’s advice." : "This change does not agree with your coach’s advice.")
		}

		public function evaluateForInitialize():void
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
			updateBloodGlucoseAverage();
		}

		private function updateLatestDecisionDoses():void
		{
			var parentForTitrationDecisionResult:DocumentBase = getParentForTitrationDecisionResult(_scheduleDetails.currentSchedule);
			if (parentForTitrationDecisionResult)
			{
				getLatestDecisionResults(parentForTitrationDecisionResult);
				_latestDecisionDose = getDecisionDoseFromResult(_latestDecisionResult);
				_patientLatestDecisionDose = getDecisionDoseFromResult(_patientLatestDecisionResult);
				_clinicianLatestDecisionDose = getDecisionDoseFromResult(_clinicianLatestDecisionResult);
				_otherPartyLatestDecisionDose = getDecisionDoseFromResult(_otherPartyLatestDecisionResult);
			}
		}

		private function getDecisionDoseFromResult(titrationResult:HealthActionResult):Number
		{
			if (titrationResult && titrationResult.actions && titrationResult.actions.length > 0)
			{
				var actionStepResult:ActionStepResult = titrationResult.actions[0] as ActionStepResult;

				if (actionStepResult && actionStepResult.occurrences && actionStepResult.occurrences.length > 0)
				{
					var occurrence:Occurrence = actionStepResult.occurrences[0] as Occurrence;
					if (occurrence.stopCondition && occurrence.stopCondition.value)
					{
						return Number(occurrence.stopCondition.value.value);
					}
				}
			}

			// No decision from other party or failed to determine the decision
			return NaN;
		}

		public function isDecisionResultAgreement(titrationResult:HealthActionResult):Boolean
		{
			if (titrationResult && titrationResult.actions && titrationResult.actions.length > 0)
			{
				var actionStepResult:ActionStepResult = titrationResult.actions[0] as ActionStepResult;

				if (actionStepResult && actionStepResult.occurrences && actionStepResult.occurrences.length > 0)
				{
					var occurrence:Occurrence = actionStepResult.occurrences[0] as Occurrence;
					if (occurrence.stopCondition && occurrence.stopCondition.name)
					{
						return occurrence.stopCondition.name.text == AGREE_STOP_CONDITION_NAME;
					}
				}
			}

			// No decision from other party or failed to determine the decision
			return false;
		}

		public function isDecisionResultByPatient(titrationResult:HealthActionResult):Boolean
		{
			if (titrationResult && titrationResult.actions && titrationResult.actions.length > 0)
			{
				var actionStepResult:ActionStepResult = titrationResult.actions[0] as ActionStepResult;

				if (actionStepResult && actionStepResult.name)
				{
					return actionStepResult.name.text == PATIENT_DECISION_ACTION_STEP_RESULT_NAME;
				}
			}

			return false;
		}

		private function getLatestDecisionResults(parentForTitrationDecisionResult:DocumentBase):void
		{
			_latestDecisionResult = null;
			_patientLatestDecisionResult = null;
			_clinicianLatestDecisionResult = null;

			// Loop through all relationships on the parent to find the potential latest titration result from the other party
			for each (var relationship:Relationship in parentForTitrationDecisionResult.relatesTo)
			{
				if (relationship.type == HealthActionResult.RELATION_TYPE_TITRATION_DECISION)
				{
					var titrationResult:HealthActionResult = relationship.relatesTo as HealthActionResult;
					if (titrationResult && titrationResult.name &&
							titrationResult.name.text == TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME &&
							titrationResult.actions && titrationResult.actions.length > 0)
					{
						var actionStepResult:ActionStepResult = titrationResult.actions[0] as ActionStepResult;
						_latestDecisionResult = getLatestMatchingResult(actionStepResult,
								_latestDecisionResult, titrationResult,
								function(a:ActionStepResult):Boolean { return true;});
						_patientLatestDecisionResult = getLatestMatchingResult(actionStepResult,
								_patientLatestDecisionResult, titrationResult,
								function(a:ActionStepResult):Boolean { return a && a.name && a.name.text == PATIENT_DECISION_ACTION_STEP_RESULT_NAME;});
						_clinicianLatestDecisionResult = getLatestMatchingResult(actionStepResult,
								_clinicianLatestDecisionResult, titrationResult,
								function(a:ActionStepResult):Boolean { return a && a.name && a.name.text == CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME;});
					}
				}
			}

			_otherPartyLatestDecisionResult = isPatient ? _clinicianLatestDecisionResult : _patientLatestDecisionResult;
		}

		private function getLatestMatchingResult(actionStepResult:ActionStepResult,
												 latestMatchingResult:HealthActionResult,
												 titrationResult:HealthActionResult,
												 matchingFunction:Function):HealthActionResult
		{
			if (matchingFunction(actionStepResult) &&
					(latestMatchingResult == null ||
							(titrationResult.dateReported && latestMatchingResult.dateReported &&
									titrationResult.dateReported.valueOf() >
											latestMatchingResult.dateReported.valueOf())))
			{
				latestMatchingResult = titrationResult;
			}
			return latestMatchingResult;
		}

		public function save():Boolean
		{
			var saveSucceeded:Boolean = true;

			if (decisionScheduleItemOccurrence == null)
				throw new Error("Failed to save. Decision data on the health charts model was not a ScheduleItemOccurrence.");

			var healthActionSchedule:HealthActionSchedule = decisionScheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			var plan:HealthActionPlan = healthActionSchedule.scheduledHealthAction as HealthActionPlan;

			// validate
			if (isChangeSpecified)
			{
				evaluateForSave();

				if (_scheduleDetails.currentSchedule == null || _scheduleDetails.occurrence == null)
				{
					// TODO: warn the user why the dose cannot be changed; possibly provide a means to fix the problem
					_logger.warn("User is attempting to change the dose but the current schedule/dose could not be determined.");
					return false;
				}
				else
				{
					var currentMedicationScheduleItem:MedicationScheduleItem = _scheduleDetails.currentSchedule;
					if (isPatient)
						saveSucceeded = saveForPatient(currentMedicationScheduleItem, plan, saveSucceeded);
					else
						saveSucceeded = saveForClinician(currentMedicationScheduleItem, plan, saveSucceeded);

					saveTitrationResult(currentMedicationScheduleItem);
					evaluateForInitialize();
				}
			}

			return saveSucceeded;
		}

		private function saveTitrationResult(currentMedicationScheduleItem:MedicationScheduleItem):void
		{
			var parentForTitrationDecisionResult:DocumentBase = getParentForTitrationDecisionResult(currentMedicationScheduleItem);

			var titrationResult:HealthActionResult = new HealthActionResult();
			titrationResult.name = new CodedValue(null, null, null, TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME);
			titrationResult.reportedBy = accountId;
			titrationResult.dateReported = currentDateSource.now();
			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CodedValue(null, null, null, isPatient ? PATIENT_DECISION_ACTION_STEP_RESULT_NAME : CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME);
			actionStepResult.occurrences = new ArrayCollection();
			var occurrence:Occurrence = new Occurrence();
			occurrence.stopCondition = new StopCondition();
			occurrence.stopCondition.name = new CodedValue(null, null, null, newDoseIsInAgreement() ? AGREE_STOP_CONDITION_NAME : NEW_STOP_CONDITION_NAME);
			occurrence.stopCondition.value = new ValueAndUnit(_newDose.toString(), createUnitsCodedValue());
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
			var administeredOccurrenceCount:int = _scheduleDetails.occurrence.recurrenceIndex;
			if (administeredOccurrenceCount > 0)
			{
				return currentMedicationScheduleItem;
			}
			else if (_scheduleDetails.previousSchedule)
			{
				return _scheduleDetails.previousSchedule;
			}
			else
			{
				// When we are changing the dose of the first scheduled occurrence of the medication, there is no
				// previous schedule to record titration decision results against, so use the MedicationOrder instead.
				return _scheduleDetails.currentSchedule.scheduledMedicationOrder;
			}
		}

		private function saveForClinician(currentMedicationScheduleItem:MedicationScheduleItem, plan:HealthActionPlan,
										  saveSucceeded:Boolean):Boolean
		{
			var message:String = getMessage(_newDose == _patientLatestDecisionDose ?
					TITRATION_LEADING_PHRASE_TO_PATIENT_AGREE : TITRATION_LEADING_PHRASE_TO_PATIENT_DISAGREE);
			sendMessage(message);
			return saveSucceeded;
		}

		public function get isPatient():Boolean
		{
			return record.ownerAccountId == accountId;
		}

		private function saveForPatient(currentMedicationScheduleItem:MedicationScheduleItem, plan:HealthActionPlan,
										saveSucceeded:Boolean):Boolean
		{
			// If revisiting/changing the decision, don't make a new AdherenceItem (just change the schedule/dose)
			if (!decisionAdherenceItemAlreadyPersisted())
			{
				saveScheduledDecisionResult(plan);
			}

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

		private function sendMessage(message:String):void
		{
			var servicesArray:Array = componentContainer.resolveAll(IIndividualMessageHealthRecordService);
			if (servicesArray && servicesArray.length > 0)
			{
				var messageService:IIndividualMessageHealthRecordService = servicesArray[0];
				messageService.createAndSendMessage(message);
			}
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
			return bloodGlucoseAverage.toFixed(0);
		}

		public function get algorithmPrerequisitesSatisfied():Boolean
		{
			return _algorithmPrerequisitesSatisfied;
		}

		private function saveScheduledDecisionResult(plan:HealthActionPlan):void
		{
			// create new HealthActionOccurrence, related to HealthActionSchedule
			// create new HealthActionResult, related to HealthActionOccurrence
			var results:Vector.<DocumentBase> = new Vector.<DocumentBase>();
			var decisionHealthActionResult:HealthActionResult = new HealthActionResult();

			decisionHealthActionResult.name = plan.name.clone();
			decisionHealthActionResult.planType = plan.planType;
			decisionHealthActionResult.dateReported = currentDateSource.now();
			decisionHealthActionResult.reportedBy = accountId;
			var actionStepResult:ActionStepResult = new ActionStepResult();
			actionStepResult.name = new CodedValue(null, null, null, CHOSE_A_NEW_DOSE_ACTION_STEP_RESULT_TEXT);
			decisionHealthActionResult.actions = new ArrayCollection();
			decisionHealthActionResult.actions.addItem(actionStepResult);
			results.push(decisionHealthActionResult);

			if (decisionScheduleItemOccurrence)
			{
				// TODO: switch to the new data types
				//						decisionScheduleItemOccurrence.createHealthActionOccurrence(results, record,
				//								accountId);
				decisionScheduleItemOccurrence.createAdherenceItem(results, record, accountId, true);
			}
			else
			{
				for each (var result:DocumentBase in results)
				{
					result.pendingAction = DocumentBase.ACTION_CREATE;
					record.addDocument(result);
				}
			}
		}

		private function saveDosageChange(currentMedicationScheduleItem:MedicationScheduleItem):Boolean
		{
			var saveSucceeded:Boolean = true;

			// determine cut off date for schedule change
			// update existing MedicationScheduleItem (old dose) to end the recurrence by cut off date

			var administeredOccurrenceCount:int = _scheduleDetails.occurrence.recurrenceIndex;
			if (administeredOccurrenceCount > 0)
			{
				if (currentMedicationScheduleItem.recurrenceRule)
				{
					var remainingOccurrenceCount:int = currentMedicationScheduleItem.recurrenceRule.count -
							administeredOccurrenceCount;
					if (remainingOccurrenceCount > 0)
					{
						currentMedicationScheduleItem.recurrenceRule.count = administeredOccurrenceCount;
						currentMedicationScheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;

						if (!DISABLE_CREATION_OF_NEW_SCHEDULE)
						{
							createNewMedicationScheduleItem(currentMedicationScheduleItem, remainingOccurrenceCount);
						}
					}
					else
					{
						// schedule has ended; no future occurrences to reschedule or change the dose for
						// TODO: warn the user why the dose cannot be changed; possibly provide a means to extend the schedule beyond the original recurrence range
						_logger.warn("User is attempting to change the dose for " +
								currentMedicationScheduleItem.name.text + " with dateStart of " +
								currentMedicationScheduleItem.dateStart.toLocaleString() +
								" but the schedule has ended; no future occurrences to reschedule or change the dose for.");
						saveSucceeded = false;
					}
				}
			}
			else
			{
				currentMedicationScheduleItem.pendingAction = DocumentBase.ACTION_UPDATE;
				currentMedicationScheduleItem.dose.value = _newDose.toString();
			}
			return saveSucceeded;
		}

		private function createNewMedicationScheduleItem(currentMedicationScheduleItem:MedicationScheduleItem,
														 remainingOccurrenceCount:int):void
		{
			// create new MedicationScheduleItem with new dose starting at cut off day
			var newMedicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
			newMedicationScheduleItem.pendingAction = DocumentBase.ACTION_CREATE;
			newMedicationScheduleItem.dose = new ValueAndUnit(_newDose.toString(), createUnitsCodedValue());
			newMedicationScheduleItem.name = currentMedicationScheduleItem.name.clone();
			newMedicationScheduleItem.scheduledBy = accountId;
			newMedicationScheduleItem.dateScheduled = currentDateSource.now();
			newMedicationScheduleItem.dateStart = _scheduleDetails.occurrence.dateStart;
			newMedicationScheduleItem.dateEnd = _scheduleDetails.occurrence.dateEnd;
			newMedicationScheduleItem.recurrenceRule = new RecurrenceRule();
			if (currentMedicationScheduleItem.recurrenceRule.frequency)
				newMedicationScheduleItem.recurrenceRule.frequency = currentMedicationScheduleItem.recurrenceRule.frequency.clone();
			if (currentMedicationScheduleItem.recurrenceRule.interval)
				newMedicationScheduleItem.recurrenceRule.interval = currentMedicationScheduleItem.recurrenceRule.interval.clone();
			newMedicationScheduleItem.recurrenceRule.count = remainingOccurrenceCount;
			newMedicationScheduleItem.instructions = currentMedicationScheduleItem.instructions;

			record.addDocument(newMedicationScheduleItem);

			var relationship:Relationship = record.addRelationship(ScheduleItemBase.RELATION_TYPE_SCHEDULE_ITEM,
					currentMedicationScheduleItem.scheduledMedicationOrder, newMedicationScheduleItem,
					true);
			newMedicationScheduleItem.scheduledMedicationOrder = currentMedicationScheduleItem.scheduledMedicationOrder;

			// TODO: Use the correct id for the newMedicationScheduleItem; we are currently using the temporary id that we assigned ourselves; the actual id of the document will not bet known until we get a response from the server after creation
			currentMedicationScheduleItem.scheduledMedicationOrder.scheduleItems.put(newMedicationScheduleItem.meta.id,
					newMedicationScheduleItem);
		}

		private static function createUnitsCodedValue():CodedValue
		{
			return new CodedValue("http://indivo.org/codes/units#", "Units", "U", "Units");
		}

		public function isMeasurementEligible(vitalSign:VitalSign):Boolean
		{
			return _eligibleBloodGlucoseMeasurements && _eligibleBloodGlucoseMeasurements.indexOf(vitalSign) != -1;
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

		public function decisionAdherenceItemAlreadyPersisted():Boolean
		{
			return decisionScheduleItemOccurrence && decisionScheduleItemOccurrence.adherenceItem != null &&
					decisionScheduleItemOccurrence.adherenceItem.adherence;
		}

		public function updateIsAdherencePerfect():void
		{
			var nonAdherenceVector:Vector.<ScheduleItemOccurrence> = new Vector.<ScheduleItemOccurrence>();

			// loop through all MedicationScheduleItem instances in the time of interest and check that adherence is perfect
			var now:Date = currentDateSource.now();
			for each (var medicationScheduleItem:MedicationScheduleItem in
					record.medicationScheduleItemsModel.medicationScheduleItemCollection)
			{
				var scheduleItemOccurrences:Vector.<ScheduleItemOccurrence> = medicationScheduleItem.getScheduleItemOccurrences(
						new Date(SynchronizedHealthCharts.roundTimeToNextDay(now).valueOf() -
								REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE * ScheduleItemBase.MILLISECONDS_IN_DAY),
						now);
				for each (var scheduleItemOccurrence:ScheduleItemOccurrence in scheduleItemOccurrences)
				{
					// Does the scheduleItemOccurrence qualify as one that needs to be completed (or is it not yet over)?
					if (scheduleItemOccurrence.dateEnd.valueOf() < now.valueOf())
					{
						if (scheduleItemOccurrence.adherenceItem == null ||
								scheduleItemOccurrence.adherenceItem.adherence == false)
						{
							nonAdherenceVector.push(scheduleItemOccurrence);
						}
					}
				}
			}

			isAdherencePerfect = nonAdherenceVector.length == 0;
			updateNonAdherenceDescription(nonAdherenceVector);
		}

		private function updateNonAdherenceDescription(nonAdherenceVector:Vector.<ScheduleItemOccurrence>):void
		{
			if (isAdherencePerfect)
			{
				nonAdherenceDescription = "";
			}
			else
			{
				var missedDoses:String = "";
				for each (var missedOccurrence:ScheduleItemOccurrence in nonAdherenceVector)
				{
					var medicationScheduleItem:MedicationScheduleItem = missedOccurrence.scheduleItem as
							MedicationScheduleItem;
					if (medicationScheduleItem)
					{
						missedDoses += "<li>" + medicationScheduleItem.dose.value + " " +
								medicationScheduleItem.dose.unit.text + " of " + medicationScheduleItem.name.text +
								" on " + missedOccurrence.dateStart.toLocaleString() + "</li>";
					}
				}
				nonAdherenceDescription = "The following doses were missed: <ul>" + missedDoses + "</ul>";
			}
		}

		public function get step1StateDescription():String
		{
			return _step1StateDescription;
		}

		public function set step1StateDescription(value:String):void
		{
			_step1StateDescription = value;
		}

		public function get step2StateDescription():String
		{
			return _step2StateDescription;
		}

		public function set step2StateDescription(value:String):void
		{
			_step2StateDescription = value;
		}

		public function get step3StateDescription():String
		{
			return _step3StateDescription;
		}

		public function set step3StateDescription(value:String):void
		{
			_step3StateDescription = value;
		}

		public function get nonAdherenceDescription():String
		{
			return _nonAdherenceDescription;
		}

		public function set nonAdherenceDescription(value:String):void
		{
			_nonAdherenceDescription = value;
		}

		public function get bloodGlucoseRequirementsDetails():String
		{
			return _bloodGlucoseRequirementsDetails;
		}

		public function set bloodGlucoseRequirementsDetails(value:String):void
		{
			_bloodGlucoseRequirementsDetails = value;
		}

		public function get step4State():String
		{
			return _step4State;
		}

		public function set step4State(value:String):void
		{
			_step4State = value;
		}

		public function get step4StateDescription():String
		{
			return _step4StateDescription;
		}

		public function set step4StateDescription(value:String):void
		{
			_step4StateDescription = value;
		}

		public function get isBloodGlucoseMaximumExceeded():Boolean
		{
			return _isBloodGlucoseMaximumExceeded;
		}

		public function set isBloodGlucoseMaximumExceeded(value:Boolean):void
		{
			_isBloodGlucoseMaximumExceeded = value;
		}

		public function get isBloodGlucoseMinimumExceeded():Boolean
		{
			return _isBloodGlucoseMinimumExceeded;
		}

		public function set isBloodGlucoseMinimumExceeded(value:Boolean):void
		{
			_isBloodGlucoseMinimumExceeded = value;
		}

		public function get bloodGlucoseAverageRangeLimited():Number
		{
			return _bloodGlucoseAverageRangeLimited;
		}

		public function set bloodGlucoseAverageRangeLimited(value:Number):void
		{
			_bloodGlucoseAverageRangeLimited = value;
		}

		public function get chartVerticalAxis():LinearAxis
		{
			return _chartVerticalAxis;
		}

		public function set chartVerticalAxis(value:LinearAxis):void
		{
			if (_chartVerticalAxis)
				_chartVerticalAxis.removeEventListener(LimitedLinearAxis.AXIS_CHANGE_EVENT, chartVerticalAxis_axisChangeHandler);

			_chartVerticalAxis = value;
			if (_chartVerticalAxis)
			{
				updateConnectedChartVerticalAxisLimits();
				_chartVerticalAxis.addEventListener(LimitedLinearAxis.AXIS_CHANGE_EVENT, chartVerticalAxis_axisChangeHandler, false, 0, true);
			}
		}

		private function chartVerticalAxis_axisChangeHandler(event:Event):void
		{
			updateConnectedChartVerticalAxisLimits();
		}

		private function updateConnectedChartVerticalAxisLimits():void
		{
			connectedChartVerticalAxisMaximum = _chartVerticalAxis.maximum;
			connectedChartVerticalAxisMinimum = _chartVerticalAxis.minimum;
		}

		public function get connectedChartVerticalAxisMaximum():Number
		{
			return _connectedChartVerticalAxisMaximum;
		}

		public function set connectedChartVerticalAxisMaximum(value:Number):void
		{
			_connectedChartVerticalAxisMaximum = value;
		}

		public function get connectedChartVerticalAxisMinimum():Number
		{
			return _connectedChartVerticalAxisMinimum;
		}

		public function set connectedChartVerticalAxisMinimum(value:Number):void
		{
			_connectedChartVerticalAxisMinimum = value;
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

		public function set algorithmPrerequisitesSatisfied(value:Boolean):void
		{
			_algorithmPrerequisitesSatisfied = value;
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

		public function get latestDecisionResult():HealthActionResult
		{
			return _latestDecisionResult;
		}

		public function get evaluateTodayOnly():Boolean
		{
			return false;
		}

		public function getSteps():ArrayCollection
		{
			var patient:String = (_patientLatestDecisionResult ? (isDecisionResultAgreement(_patientLatestDecisionResult) ? AGREE : NEW) : NONE);
			var clinician:String = (_clinicianLatestDecisionResult ? (isDecisionResultAgreement(_clinicianLatestDecisionResult) ? AGREE : NEW) : NONE);
			var protocol:String = (algorithmPrerequisitesSatisfied ? "ConditionsMet" : (step2State == InsulinTitrationDecisionModelBase.STEP_STOP ? "InsufficientAdherence" : "InsufficientBloodGlucose"));

			if (patient == AGREE && clinician == AGREE)
			{
				if (_latestDecisionResult == _patientLatestDecisionResult)
				{
					clinician = NEW;
				}
				else
				{
					patient = NEW;
				}
			}
			else if (patient == AGREE && clinician == NONE)
			{
				clinician = NEW;
			}
			else if (patient == NONE && clinician == AGREE)
			{
				patient = NEW;
			}

			for each (var state:InsulinTitrationDecisionSupportState in _states)
			{
				if (state.selectors.contains("mode" + (isPatient ? "Patient" : "Clinician")) &&
						state.selectors.contains("decisionPatient" + patient) &&
						state.selectors.contains("decisionClinician" + clinician) &&
						state.selectors.contains("protocol" + protocol)
					)
				{
					return state.steps;
				}
			}
			// no match; return empty array collection
			return new ArrayCollection();
		}

		public function get confirmationMessage():String
		{
			return _confirmationMessage;
		}
	}
}
