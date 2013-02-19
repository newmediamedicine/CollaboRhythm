package collaboRhythm.shared.model.medications
{
	import collaboRhythm.shared.insulinTitrationSupport.model.states.TitrationDecisionSupportState;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class TitrationDecisionModelBase
	{
		public static const STEP_SATISFIED:String = "satisfied";
		public static const STEP_STOP:String = "stop";
		public static const STEP_PREVIOUS_STOP:String = "previous stop";

		protected static const TITRATION_DECISION_HEALTH_ACTION_RESULT_NAME:String = "Titration Decision";
		public static const PATIENT_DECISION_ACTION_STEP_RESULT_NAME:String = "Patient Decision";
		public static const CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME:String = "Clinician Decision";

		protected static const AGREE_STOP_CONDITION_NAME:String = "Agree";
		protected static const NEW_STOP_CONDITION_NAME:String = "New";

		private static const AGREE:String = "Agree";
		private static const NEW:String = "New";
		private static const NONE:String = "None";

		private var _areBloodGlucoseRequirementsMet:Boolean = true;
		private var _isAdherencePerfect:Boolean = true;
		private var _isChangeSpecified:Boolean;

		private var _step1State:String;
		private var _step2State:String;
		private var _step3State:String;
		private var _step4State:String;

		private var _step1StateDescription:String = "";
		private var _step2StateDescription:String = "";
		private var _step3StateDescription:String = "";
		private var _step4StateDescription:String = "";

		private var _nonAdherenceDescription:String;
		private var _algorithmPrerequisitesSatisfied:Boolean;
		protected var _latestDecisionResult:HealthActionResult;
		protected var _patientLatestDecisionResult:HealthActionResult;
		protected var _clinicianLatestDecisionResult:HealthActionResult;
		protected var _otherPartyLatestDecisionResult:HealthActionResult;
		protected var _states:ArrayCollection;
		private var _instructionsSteps:ArrayCollection;

		private var _confirmationMessage:String;

		public function TitrationDecisionModelBase()
		{
		}

		protected function get decisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			return null;
		}

		public function get record():Record
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

		public function get areBloodGlucoseRequirementsMet():Boolean
		{
			return _areBloodGlucoseRequirementsMet;
		}

		public function set areBloodGlucoseRequirementsMet(value:Boolean):void
		{
			_areBloodGlucoseRequirementsMet = value;
			updateStep1State();
		}

		protected function updateStep1State():void
		{

		}

		public function get instructionsSteps():ArrayCollection
		{
			return _instructionsSteps;
		}

		public function set instructionsSteps(instructionsSteps:ArrayCollection):void
		{
			_instructionsSteps = instructionsSteps;
		}

		public function get isChangeSpecified():Boolean
		{
			return _isChangeSpecified;
		}

		public function set isChangeSpecified(value:Boolean):void
		{
			_isChangeSpecified = value;
			updateStep3State();
		}

		protected function updateStep3State():void
		{

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

		protected function updateStep2State():void
		{

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

		protected function getDecisionDoseFromResult(titrationResult:HealthActionResult):Number
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

		protected function getLatestDecisionResults(parentForTitrationDecisionResult:DocumentBase):void
		{
			latestDecisionResult = null;
			patientLatestDecisionResult = null;
			clinicianLatestDecisionResult = null;

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
						latestDecisionResult = getLatestMatchingResult(actionStepResult,
								_latestDecisionResult, titrationResult,
								function (a:ActionStepResult):Boolean
								{
									return true;
								});
						patientLatestDecisionResult = getLatestMatchingResult(actionStepResult,
								_patientLatestDecisionResult, titrationResult,
								function (a:ActionStepResult):Boolean
								{
									return a && a.name && a.name.text == PATIENT_DECISION_ACTION_STEP_RESULT_NAME;
								});
						clinicianLatestDecisionResult = getLatestMatchingResult(actionStepResult,
								_clinicianLatestDecisionResult, titrationResult,
								function (a:ActionStepResult):Boolean
								{
									return a && a.name && a.name.text == CLINICIAN_DECISION_ACTION_STEP_RESULT_NAME;
								});
					}
				}
			}

			otherPartyLatestDecisionResult = isPatient ? _clinicianLatestDecisionResult : _patientLatestDecisionResult;
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

		public function get isPatient():Boolean
		{
			return record.ownerAccountId == accountId;
		}

		public function get algorithmPrerequisitesSatisfied():Boolean
		{
			return _algorithmPrerequisitesSatisfied;
		}

		public function set algorithmPrerequisitesSatisfied(value:Boolean):void
		{
			_algorithmPrerequisitesSatisfied = value;
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

		public function get latestDecisionResult():HealthActionResult
		{
			return _latestDecisionResult;
		}

		public function set latestDecisionResult(value:HealthActionResult):void
		{
			_latestDecisionResult = value;
		}

		public function set patientLatestDecisionResult(value:HealthActionResult):void
		{
			_patientLatestDecisionResult = value;
		}

		public function set clinicianLatestDecisionResult(value:HealthActionResult):void
		{
			_clinicianLatestDecisionResult = value;
		}

		public function set otherPartyLatestDecisionResult(value:HealthActionResult):void
		{
			_otherPartyLatestDecisionResult = value;
		}

		public function getSteps():ArrayCollection
		{
			var patient:String = (_patientLatestDecisionResult ? (isDecisionResultAgreement(_patientLatestDecisionResult) ? AGREE : NEW) : NONE);
			var clinician:String = (_clinicianLatestDecisionResult ? (isDecisionResultAgreement(_clinicianLatestDecisionResult) ? AGREE : NEW) : NONE);
			var protocol:String = (algorithmPrerequisitesSatisfied ? "ConditionsMet" : (step2State ==
					STEP_STOP ? "InsufficientAdherence" : "InsufficientBloodGlucose"));

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

			for each (var state:TitrationDecisionSupportState in _states)
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

		/**
		 * Check any pre-onditions and throw an exception if any condition is not met
		 */
		protected function validateDecisionPreConditions():void
		{

		}

		public function get confirmationMessage():String
		{
			return _confirmationMessage;
		}

		public function set confirmationMessage(value:String):void
		{
			_confirmationMessage = value;
		}
	}
}
