package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.model.states.BloodPressureMedicationTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.ITitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.Step;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.TitrationDecisionSupportState;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.medications.MedicationTitrationAnalyzer;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.DefaultVitalSignChartModifier;

	import mx.collections.ArrayCollection;

	/**
	 * Model for hypertension medication titration decision support. The protocol used supports 4 "classes"
	 * (medically speaking) of medication which a patient can progressively add or remove. Each class of medication
	 * has a single medication that is used for that class (Lisinopril is used as the ACE Inhibitor class of medication,
	 * for example). Each medication has a half and full dose (Lisinopril can be at 20 MG or 40 MG). For the
	 * ACE Inhibitor, an alternate, mutually exclusive class of medication (ARB, for which the medication Valsartan is
	 * used) can be chosen.
	 */
	[Bindable]
	public class HypertensionMedicationTitrationModel extends TitrationDecisionModelBase
	{
		private static const LISINOPRIL_20_MG_ORAL_TABLET:Array = ["314077", "Lisinopril 20 MG Oral Tablet", "001723760"];
		private static const LISINOPRIL_40_MG_ORAL_TABLET:Array = ["197884", "Lisinopril 40 MG Oral Tablet", "003782076"];
		private static const VALSARTAN_160_MG_ORAL_TABLET:Array = ["153666", "irbesartan 150 MG Oral Tablet [Avapro]", "000872772"];
		private static const VALSARTAN_320_MG_ORAL_TABLET:Array = ["153667", "irbesartan 300 MG Oral Tablet [Avapro]", "000872773"];
		private static const AMLODIPINE_5_MG_ORAL_TABLET:Array = ["197361", "Amlodipine 5 MG Oral Tablet", "000691530"];
		private static const AMLODIPINE_10_MG_ORAL_TABLET:Array = ["308135", "Amlodipine 10 MG Oral Tablet", "000691540"];
		private static const HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET:Array = ["199903", "Hydrochlorothiazide 12.5 MG Oral Tablet", "002282820"];
		private static const HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET:Array = ["310798", "Hydrochlorothiazide 25 MG Oral Tablet", "006033856"];

		private static const NUMBER_OF_DAYS_BEFORE_TITRATION:int = 14;
		private static const NUMBER_OF_MILLISECONDS_BEFORE_TITRATION:Number = 1000 * 60 * 60 * 24 * NUMBER_OF_DAYS_BEFORE_TITRATION;

		protected static const REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE:int = 14;
		protected static const REQUIRED_BLOOD_PRESSURE_MEASUREMENTS:int = 3;
		protected static const NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_PRESSURE:int = 7;

		protected var _record:Record;

		protected var _medicationScheduleItemsCollection:ArrayCollection;

		protected var _hypertensionMedicationAlternatePairsVector:Vector.<HypertensionMedicationAlternatePair> = new Vector.<HypertensionMedicationAlternatePair>();

		protected var _highestHypertensionMedicationAlternatePairIndex:int;
		protected var _timeSinceLastChange:Number;

		protected var _currentDateSource:ICurrentDateSource;
		protected var _activeRecordAccount:Account;
		private var _activeAccount:Account;

		private var _currentSelectionsArrayCollection:ArrayCollection = new ArrayCollection();
		private var _currentActiveAccountSelectionsArrayCollection:ArrayCollection = new ArrayCollection();

		private var _isMapViewVisible:Boolean = false;

		public function HypertensionMedicationTitrationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			super();
			_protocolVitalSignCategory = VitalSignsModel.SYSTOLIC_CATEGORY;
			_requiredNumberVitalSigns = REQUIRED_BLOOD_PRESSURE_MEASUREMENTS;
			_numberOfDaysForEligibleVitalSigns = NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_PRESSURE;
			requiredDaysOfPerfectMedicationAdherence = REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE;
			protocolMeasurementsMustBeAfterTitration = false;
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_record = activeRecordAccount.primaryRecord;
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

			verticalAxisMinimum = DefaultVitalSignChartModifier.SYSTOLIC_VERTICAL_AXIS_MINIMUM;
			verticalAxisMaximum = DefaultVitalSignChartModifier.SYSTOLIC_VERTICAL_AXIS_MAXIMUM;
			goalZoneMinimum = DefaultVitalSignChartModifier.SYSTOLIC_GOAL_ZONE_MINIMUM;
			goalZoneMaximum = DefaultVitalSignChartModifier.SYSTOLIC_GOAL_ZONE_MAXIMUM;
			goalZoneColor = DefaultVitalSignChartModifier.GOAL_ZONE_COLOR;

			_hypertensionMedicationAlternatePairsVector.push(
					new HypertensionMedicationAlternatePair(
							new HypertensionMedication("Diuretic", HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET,
									HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET),
							null));

			_hypertensionMedicationAlternatePairsVector.push(
					new HypertensionMedicationAlternatePair(
							new HypertensionMedication("Calcium Channel Blocker",
									AMLODIPINE_5_MG_ORAL_TABLET, AMLODIPINE_10_MG_ORAL_TABLET),
							null));

			_hypertensionMedicationAlternatePairsVector.push(
					new HypertensionMedicationAlternatePair(
							new HypertensionMedication("ACE Inhibitor", LISINOPRIL_20_MG_ORAL_TABLET,
									LISINOPRIL_40_MG_ORAL_TABLET),
							new HypertensionMedication("ARB", VALSARTAN_160_MG_ORAL_TABLET,
									VALSARTAN_320_MG_ORAL_TABLET)));

			updateForRecordChange();
		}

		protected function getMedications():Vector.<HypertensionMedication>
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

		public function clearAlgorithmSuggestions():void
		{
			for each (var pair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				for each (var medication:HypertensionMedication in pair.medications)
				{
					medication.clearSystemSelections();
				}
			}
		}

		override protected function updateAlgorithmSuggestions():void
		{
			clearAlgorithmSuggestions();

			determineCurrentDoses();
			determineHighestMedicationAlternatePair();
			determineMostRecentDoseChange();

			if (algorithmPrerequisitesSatisfied)
			{
				if (protocolMeasurementAverage > goalZoneMaximum)
				{
					if (_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.currentDose <
							2)
					{
						_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.addOrRemoveHypertensionMedicationDoseSelection(_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.currentDose +
								1, HypertensionMedicationDoseSelection.INCREASE,
								HypertensionMedicationDoseSelection.SYSTEM, null);
					}
					else if (_highestHypertensionMedicationAlternatePairIndex > 0)
					{
						_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex -
								1].activeHypertensionMedication.addOrRemoveHypertensionMedicationDoseSelection(1,
										HypertensionMedicationDoseSelection.INCREASE,
										HypertensionMedicationDoseSelection.SYSTEM, null);
					}
				}
				else if (protocolMeasurementAverage < goalZoneMinimum)
				{
					// TODO: if there is some gap in the progression of meds (such as the 3rd med is scheduled, but 1st and 2nd are not) we should titrate down off of the remaining med(s)
					_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.addOrRemoveHypertensionMedicationDoseSelection(_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.currentDose,
							HypertensionMedicationDoseSelection.DECREASE, HypertensionMedicationDoseSelection.SYSTEM,
							null);
				}
			}
		}

		private function isDurationSinceChangeGoalMet():Boolean
		{
			return daysRemaining <= 0;
		}

		private function determineHighestMedicationAlternatePair():void
		{
			_highestHypertensionMedicationAlternatePairIndex = _hypertensionMedicationAlternatePairsVector.length - 1;

			for (var i:int = _hypertensionMedicationAlternatePairsVector.length - 1; i >= 0; i--)
			{
				var hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair = _hypertensionMedicationAlternatePairsVector[i];
				if (hypertensionMedicationAlternatePair.activeHypertensionMedication &&
						hypertensionMedicationAlternatePair.activeHypertensionMedication.currentDose !=
								DoseStrengthCode.NONE)
				{
					_highestHypertensionMedicationAlternatePairIndex = i;
				}
				if (hypertensionMedicationAlternatePair.activeHypertensionMedication &&
						hypertensionMedicationAlternatePair.activeHypertensionMedication.currentDose <
								DoseStrengthCode.HIGH)
				{
					break;
				}
			}
		}

		protected function determineCurrentDoses():void
		{
			// TODO: only consider hypertension medications for algorithm; using all medications (not just hypertension medications) may be problematic
			_medicationScheduleItemsCollection = _record.medicationScheduleItemsModel.medicationScheduleItemCollection;

			for each (var hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				hypertensionMedicationAlternatePair.determineCurrentDose(_medicationScheduleItemsCollection);
			}
		}

		private function determineMostRecentDoseChange():void
		{
			var analyzer:MedicationTitrationAnalyzer = new MedicationTitrationAnalyzer(_medicationScheduleItemsCollection, currentDateSource);
			_timeSinceLastChange = analyzer.calculateTimeSinceChange();
		}

		/**
		 * Handle a change to the dose selected.
		 *
		 * @param hypertensionMedicationActionSynchronizationDetails A class that represents all of the necessary details about the dose selection
		 */
		public function handleHypertensionMedicationDoseSelected(hypertensionMedicationActionSynchronizationDetails:HypertensionMedicationActionSynchronizationDetails):void
		{
			var hypertensionMedication:HypertensionMedication;
			for each (var possibleHypertensionMedication:HypertensionMedication in getMedications())
			{
				if (hypertensionMedicationActionSynchronizationDetails.hypertensionMedicationClass ==
						possibleHypertensionMedication.medicationClass)
				{
					hypertensionMedication = possibleHypertensionMedication;
				}
			}

			if (hypertensionMedication)
			{
				hypertensionMedication.handleDoseSelected(hypertensionMedicationActionSynchronizationDetails.doseSelected,
						hypertensionMedicationActionSynchronizationDetails.altKey,
						hypertensionMedicationActionSynchronizationDetails.ctrlKey,
						getAccountIdForSelectionAction(hypertensionMedicationActionSynchronizationDetails.ctrlKey,
								hypertensionMedicationActionSynchronizationDetails.selectionByAccountId),
						hypertensionMedicationActionSynchronizationDetails.selectionByAccountId ==
								_activeRecordAccount.accountId);
				updateSummaryCollections();
				if (!hypertensionMedicationActionSynchronizationDetails.ctrlKey &&
						!hypertensionMedicationActionSynchronizationDetails.altKey)
				{
					isChangeSpecified = true;
				}
			}
		}

		public function handleHypertensionMedicationAlternateSelected(hypertensionMedicationActionSynchronizationDetails:HypertensionMedicationActionSynchronizationDetails):void
		{
			var hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair;
			for each (var possibleHypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				if (hypertensionMedicationActionSynchronizationDetails.hypertensionMedicationClass ==
						possibleHypertensionMedicationAlternatePair.primaryHypertensionMedication.medicationClass)
				{
					hypertensionMedicationAlternatePair = possibleHypertensionMedicationAlternatePair;
				}
			}

			if (hypertensionMedicationAlternatePair)
			{
				hypertensionMedicationAlternatePair.handleAlternateSelected(hypertensionMedicationActionSynchronizationDetails.altKey,
						hypertensionMedicationActionSynchronizationDetails.ctrlKey,
						getAccountIdForSelectionAction(hypertensionMedicationActionSynchronizationDetails.ctrlKey,
								hypertensionMedicationActionSynchronizationDetails.selectionByAccountId),
						hypertensionMedicationActionSynchronizationDetails.selectionByAccountId ==
								_activeRecordAccount.accountId);
				updateSummaryCollections();
				if (!hypertensionMedicationActionSynchronizationDetails.ctrlKey &&
						!hypertensionMedicationActionSynchronizationDetails.altKey)
				{
					isChangeSpecified = true;
				}
			}
		}

		protected function updateSummaryCollections():void
		{
			_currentSelectionsArrayCollection.removeAll();
			_currentActiveAccountSelectionsArrayCollection.removeAll();

			var hypertensionMedications:Vector.<HypertensionMedication> = getMedications();
			for each (var medication:HypertensionMedication in hypertensionMedications)
			{
				var activeAccountSelection:HypertensionMedicationDoseSelection = medication.getSelectionForAccount(_activeAccount);
				var allSelections:Vector.<HypertensionMedicationDoseSelection> = medication.doseSelections;

				if (activeAccountSelection != null)
				{
					_currentActiveAccountSelectionsArrayCollection.addItem(activeAccountSelection);
				}

				if (allSelections.length != 0)
				{
					for each (var selection:HypertensionMedicationDoseSelection in allSelections)
					{
						_currentSelectionsArrayCollection.addItem(selection);
					}
				}
			}
		}

		protected function getAccountIdForSelectionAction(ctrlKey:Boolean, selectionByAccountId:String):String
		{
			// TODO: when in patient mode, control click should be for simulating the clinician
			return ctrlKey ? _activeRecordAccount.accountId : selectionByAccountId;
		}

		public function get hypertensionMedicationAlternatePairsVector():Vector.<HypertensionMedicationAlternatePair>
		{
			return _hypertensionMedicationAlternatePairsVector;
		}

		override public function get record():Record
		{
			return _record;
		}

		override protected function get accountId():String
		{
			return _activeAccount.accountId;
		}

		override protected function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		override protected function isFileStoreMatch(fileStore:ITitrationDecisionSupportStatesFileStore):Boolean
		{
			return fileStore is BloodPressureMedicationTitrationDecisionSupportStatesFileStore;
		}

		override public function getSteps():ArrayCollection
		{
			var currentConditions:ArrayCollection = new ArrayCollection();
			currentConditions.addItem("mode" + (isPatient ? "Patient" : "Clinician"));
			currentConditions.addItem("measurement" +
					(areProtocolMeasurementRequirementsMet ? "Sufficient" : "Insufficient"));
			currentConditions.addItem("measurementGoal" +
					(protocolMeasurementAverage < goalZoneMaximum ? "Met" : "NotMet"));
			currentConditions.addItem("durationSinceChangeGoal" + (isDurationSinceChangeGoalMet() ? "Met" : "NotMet"));
			currentConditions.addItem("medicationAdherenceGoal" + (isAdherencePerfect ? "Met" : "NotMet"));

			var steps:ArrayCollection = new ArrayCollection();
			for each (var state:TitrationDecisionSupportState in _states)
			{
				if (state.stepNumber == steps.length + 1 &&
						stateMatches(state, currentConditions))
				{
					for each (var step:Step in state.steps)
					{
						steps.addItem(step);
					}
				}
			}
			return steps;
		}

		private function stateMatches(state:TitrationDecisionSupportState, currentConditions:ArrayCollection):Boolean
		{
			// check that all selectors in the state match the current conditions
			for each (var selector:String in state.selectors)
			{
				if (!currentConditions.contains(selector))
				{
					return false;
				}
			}
			return true;
		}

		public function get currentSelectionsArrayCollection():ArrayCollection
		{
			return _currentSelectionsArrayCollection;
		}

		public function get currentActiveAccountSelectionsArrayCollection():ArrayCollection
		{
			return _currentActiveAccountSelectionsArrayCollection;
		}

		override public function evaluateForSteps():void
		{
			determineCurrentDoses();
			updateIsAdherencePerfect();
			updateProtocolMeasurementAverage();
		}

		public function get daysRemaining():int
		{
			if (!isNaN(_timeSinceLastChange))
			{
				var delta:Number = NUMBER_OF_MILLISECONDS_BEFORE_TITRATION - _timeSinceLastChange;
				if (delta < 0) delta = 0;
				var days:int = Math.floor(delta / (1000 * 60 * 60 * 24));
				return days;
			}
			return 0;
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function get isMapViewVisible():Boolean
		{
			return _isMapViewVisible;
		}

		public function set isMapViewVisible(value:Boolean):void
		{
			_isMapViewVisible = value;
		}
	}
}
