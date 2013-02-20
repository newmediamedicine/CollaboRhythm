package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.model.titration.HypertensionMedication;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class HypertensionMedicationTitrationModel extends TitrationDecisionModelBase
	{
//		private static const LISINOPRIL_20_MG_ORAL_TABLET_RXNORM:String = "314077";
//		private static const LISINOPRIL_40_MG_ORAL_TABLET_RXNORM:String = "197884";
//		private static const VALSARTAN_160_MG_ORAL_TABLET_RXNORM:String = "349201";
//		private static const VALSARTAN_320_MG_ORAL_TABLET_RXNORM:String = "349200";
//		private static const AMLODIPINE_5_MG_ORAL_TABLET_RXNORM:String = "197361";
//		private static const AMLODIPINE_10_MG_ORAL_TABLET_RXNORM:String = "308135";
//		private static const HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET_RXNORM:String = "199903";
//		private static const HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET_RXNORM:String = "310798";

		private static const LISINOPRIL_20_MG_ORAL_TABLET_RXNORM:String = "Lisinopril 20 MG Oral Tablet";
		private static const LISINOPRIL_40_MG_ORAL_TABLET_RXNORM:String = "Lisinopril 40 MG Oral Tablet";
		private static const VALSARTAN_160_MG_ORAL_TABLET_RXNORM:String = "Valsartan 160 MG Oral Tablet";
		private static const VALSARTAN_320_MG_ORAL_TABLET_RXNORM:String = "Valsartan 320 MG Oral Tablet";
		private static const AMLODIPINE_5_MG_ORAL_TABLET_RXNORM:String = "Amlodipine 5 MG Oral Tablet";
		private static const AMLODIPINE_10_MG_ORAL_TABLET_RXNORM:String = "Amlodipine 10 MG Oral Tablet";
		private static const HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET_RXNORM:String = "Hydrochlorothiazide 12.5 MG Oral Tablet";
		private static const HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET_RXNORM:String = "Hydrochlorothiazide 25 MG Oral Tablet";

		private static const NUMBER_OF_MILLISECONDS_IN_TWO_WEEKS:Number = 1000 * 60 * 60 * 24 * 2;

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

		public function HypertensionMedicationTitrationModel(activeAccount:Account, activeRecordAccount:Account)
		{
			super();
			requiredDaysOfPerfectMedicationAdherence = 14;
			_activeAccount = activeAccount;
			_activeRecordAccount = activeRecordAccount;
			_record = activeRecordAccount.primaryRecord;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

			_hypertensionMedicationAlternatePairsVector.push(
					new HypertensionMedicationAlternatePair(
							new HypertensionMedication("Diuretic", HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET_RXNORM,
									HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET_RXNORM),
							null));

			_hypertensionMedicationAlternatePairsVector.push(
					new HypertensionMedicationAlternatePair(
							new HypertensionMedication("Calcium Channel Blocker",
									AMLODIPINE_5_MG_ORAL_TABLET_RXNORM, AMLODIPINE_10_MG_ORAL_TABLET_RXNORM),
							null));

			_hypertensionMedicationAlternatePairsVector.push(
					new HypertensionMedicationAlternatePair(
							new HypertensionMedication("ACE Inhibitor", LISINOPRIL_20_MG_ORAL_TABLET_RXNORM,
									LISINOPRIL_40_MG_ORAL_TABLET_RXNORM),
							new HypertensionMedication("ARB", VALSARTAN_160_MG_ORAL_TABLET_RXNORM,
									VALSARTAN_320_MG_ORAL_TABLET_RXNORM)));

			BindingUtils.bindSetter(recordIsLoading_changeHandler, _record, "isLoading");
			updateForRecordChange();
		}

		private function recordIsLoading_changeHandler(isLoading:Boolean):void
		{
			if (!isLoading)
			{
				_medicationScheduleItemsCollection = _record.medicationScheduleItemsModel.medicationScheduleItemCollection;
				_systolicVitalSignsCollection = _record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.SYSTOLIC_CATEGORY) as
						ArrayCollection;

				determineHighestHypertensionMedicationAlternatePair();

				determineMostRecentDoseChange();

				determineMostRecentSystolicVitalSign();

				if (_mostRecentDoseChange && (_currentDateSource.now().time - _mostRecentDoseChange.time) > NUMBER_OF_MILLISECONDS_IN_TWO_WEEKS)
				{
					if (_mostRecentSystolicVitalSign)
					{
						//TODO: This needs to be tested and needs to be implemented for average of last 3 blood pressures
						if (_mostRecentSystolicVitalSign.resultAsNumber > 130)
						{
							if (_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.currentDose <
									2)
							{
								_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.addOrRemoveHypertensionMedicationDoseSelection(_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.currentDose +
										1, HypertensionMedicationDoseSelection.INCREASE,
										HypertensionMedicationDoseSelection.SYSTEM, null);
							}
							else if (_highestHypertensionMedicationAlternatePairIndex < 2)
							{
								_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex +
										1].activeHypertensionMedication.addOrRemoveHypertensionMedicationDoseSelection(1,
										HypertensionMedicationDoseSelection.INCREASE,
										HypertensionMedicationDoseSelection.SYSTEM, null);
							}
						}
						else
						{
							_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.addOrRemoveHypertensionMedicationDoseSelection(_hypertensionMedicationAlternatePairsVector[_highestHypertensionMedicationAlternatePairIndex].activeHypertensionMedication.currentDose, HypertensionMedicationDoseSelection.DECREASE, HypertensionMedicationDoseSelection.SYSTEM, null);
						}
					}
				}
			}
		}

		private function determineHighestHypertensionMedicationAlternatePair():void
		{
			_highestHypertensionMedicationAlternatePairIndex = 0;

			for each (var hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair in
					_hypertensionMedicationAlternatePairsVector)
			{
				hypertensionMedicationAlternatePair.determineCurrentDose(_medicationScheduleItemsCollection);

				if (hypertensionMedicationAlternatePair.activeHypertensionMedication.currentDose != 0)
				{
					_highestHypertensionMedicationAlternatePairIndex = _hypertensionMedicationAlternatePairsVector.indexOf(hypertensionMedicationAlternatePair);
				}
			}
		}

		private function determineMostRecentDoseChange():void
		{
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
			_mostRecentSystolicVitalSign = _systolicVitalSignsCollection.length > 0 ? _systolicVitalSignsCollection.getItemAt(_systolicVitalSignsCollection.length -
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
					ctrlKey ? _activeRecordAccount : _activeAccount,
					_activeAccount.accountId == _activeRecordAccount.accountId);
			isChangeSpecified = true;
		}

		public function handleHypertensionMedicationAlternateSelected(hypertensionMedicationAlternatePair:HypertensionMedicationAlternatePair,
																	  altKey:Boolean, ctrlKey:Boolean):void
		{
			hypertensionMedicationAlternatePair.handleAlternateSelected(altKey, ctrlKey);
			isChangeSpecified = true;
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
	}
}
