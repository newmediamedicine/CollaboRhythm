package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.model.states.BloodPressureMedicationTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.ITitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.Step;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.TitrationDecisionSupportState;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.DefaultMedicationChartModifier;
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
		private static const VALSARTAN_160_MG_ORAL_TABLET:Array = ["349201", "Valsartan 160 MG Oral Tablet", "000780359"];
		private static const VALSARTAN_320_MG_ORAL_TABLET:Array = ["349200", "Valsartan 320 MG Oral Tablet", "000780360"];
		private static const AMLODIPINE_5_MG_ORAL_TABLET:Array = ["197361", "Amlodipine 5 MG Oral Tablet", "000691530"];
		private static const AMLODIPINE_10_MG_ORAL_TABLET:Array = ["308135", "Amlodipine 10 MG Oral Tablet", "000691540"];
		private static const HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET:Array = ["199903", "Hydrochlorothiazide 12.5 MG Oral Tablet", "002282820"];
		private static const HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET:Array = ["310798", "Hydrochlorothiazide 25 MG Oral Tablet", "006033856"];

		private static const NUMBER_OF_MILLISECONDS_IN_TWO_WEEKS:Number = 1000 * 60 * 60 * 24 * 2;

		protected static const REQUIRED_DAYS_OF_PERFECT_MEDICATION_ADHERENCE:int = 14;
		protected static const REQUIRED_BLOOD_PRESSURE_MEASUREMENTS:int = 3;
		protected static const NUMBER_OF_DAYS_FOR_ELIGIBLE_BLOOD_PRESSURE:int = 7;

		protected var _record:Record;

		protected var _medicationScheduleItemsCollection:ArrayCollection;
		protected var _systolicVitalSignsCollection:ArrayCollection;

		protected var _hypertensionMedicationAlternatePairsVector:Vector.<HypertensionMedicationAlternatePair> = new Vector.<HypertensionMedicationAlternatePair>();

		protected var _highestHypertensionMedicationAlternatePairIndex:int;
		protected var _mostRecentDoseChange:Date;
		protected var _mostRecentSystolicVitalSign:VitalSign;

		protected var _currentDateSource:ICurrentDateSource;
		protected var _activeRecordAccount:Account;
		protected var _activeAccount:Account;

		private var _currentSelectionsArrayCollection:ArrayCollection = new ArrayCollection();
		private var _currentActiveAccountSelectionsArrayCollection:ArrayCollection = new ArrayCollection();

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

		override protected function updateAlgorithmSuggestions():void
		{
			// TODO: only consider hypertension medications for algorithm; using all medications (not just hypertension medications) may be problematic
			_medicationScheduleItemsCollection = _record.medicationScheduleItemsModel.medicationScheduleItemCollection;
			_systolicVitalSignsCollection = _record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.SYSTOLIC_CATEGORY) as
					ArrayCollection;

			determineHighestMedicationAlternatePair();

			determineMostRecentDoseChange();

			determineMostRecentSystolicVitalSign();

			if (isDurationSinceChangeGoalMet())
			{
				if (algorithmValuesAvailable())
				{
					//TODO: This needs to be tested and needs to be implemented for average of last 3 blood pressures
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
								HypertensionMedicationDoseSelection.DECREASE,
								HypertensionMedicationDoseSelection.SYSTEM, null);
					}
				}
			}
		}

		private function isDurationSinceChangeGoalMet():Boolean
		{
			return (_mostRecentDoseChange == null ||
					(_currentDateSource.now().time - _mostRecentDoseChange.time) > NUMBER_OF_MILLISECONDS_IN_TWO_WEEKS);
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
			_medicationScheduleItemsCollection = _record.medicationScheduleItemsModel.medicationScheduleItemCollection;

			for each (var hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				hypertensionMedicationAlternatePair.determineCurrentDose(_medicationScheduleItemsCollection);
			}
		}

		private function determineMostRecentDoseChange():void
		{
			// TODO: detect schedule end times (effective end, with recurrence evaluated) as well as start times
			for each (var medicationScheduleItem:MedicationScheduleItem in _medicationScheduleItemsCollection)
			{
				if (_mostRecentDoseChange)
				{
					if (_mostRecentDoseChange.time < medicationScheduleItem.dateStart.time)
					{
						_mostRecentDoseChange = medicationScheduleItem.dateStart;
					}
				}
				else
				{
					_mostRecentDoseChange = medicationScheduleItem.dateStart;
				}
			}
		}

		private function determineMostRecentSystolicVitalSign():void
		{
			_mostRecentSystolicVitalSign = _systolicVitalSignsCollection.length >
					0 ? _systolicVitalSignsCollection.getItemAt(_systolicVitalSignsCollection.length -
					1) as VitalSign : null;
		}

		/**
		 * Handle a change to the dose selected.
		 *
		 * @param hypertensionMedication The medication to change
		 * @param doseSelected Code indicating selected level, where 0 means none, 1 means half of max, and 2 means max
		 * @param altKey
		 * @param ctrlKey
		 * @see DoseStrengthCode
		 */
		public function handleHypertensionMedicationDoseSelected(hypertensionMedication:HypertensionMedication,
																 doseSelected:int, altKey:Boolean, ctrlKey:Boolean):void
		{
			hypertensionMedication.handleDoseSelected(doseSelected, altKey, ctrlKey,
					getAccountForSelectionAction(ctrlKey),
					_activeAccount.accountId == _activeRecordAccount.accountId);
			updateSummaryCollections();
			if (!ctrlKey && !altKey)
			{
				isChangeSpecified = true;
			}
		}

		public function handleHypertensionMedicationAlternateSelected(hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair,
																	  altKey:Boolean, ctrlKey:Boolean):void
		{
			hypertensionMedicationAlternatePair.handleAlternateSelected(altKey, ctrlKey,
					getAccountForSelectionAction(ctrlKey),
					_activeAccount.accountId == _activeRecordAccount.accountId);
			updateSummaryCollections();
			if (!ctrlKey && !altKey)
			{
				isChangeSpecified = true;
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

		protected function getAccountForSelectionAction(ctrlKey:Boolean):Account
		{
			// TODO: when in patient mode, control click should be for simulating the clinician
			return ctrlKey ? _activeRecordAccount : _activeAccount;
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
	}
}
