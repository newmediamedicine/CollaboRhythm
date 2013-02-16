package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;

	[Bindable]
	public class HypertensionMedicationTitrationModel
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
		private static const VALSARTAN_320_MG_ORAL_TABLET_RXNORM:String = "Valsartan 160 MG Oral Tablet";
		private static const AMLODIPINE_5_MG_ORAL_TABLET_RXNORM:String = "Amlodipine 5 MG Oral Tablet";
		private static const AMLODIPINE_10_MG_ORAL_TABLET_RXNORM:String = "Amlodipine 10 MG Oral Tablet";
		private static const HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET_RXNORM:String = "Hydrochlorothiazide 12.5 MG Oral Tablet";
		private static const HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET_RXNORM:String = "Hydrochlorothiazide 25 MG Oral Tablet";

		private	const NUMBER_OF_MILLISECONDS_IN_TWO_WEEKS:Number = 1000 * 60 * 60 * 24 * 2;

		private var _record:Record;

		private var _medicationScheduleItemsCollection:ArrayCollection;
		private var _systolicVitalSignsCollection:ArrayCollection;

		private var _primaryMedications:Vector.<HypertensionMedication> = new Vector.<HypertensionMedication>();
		private var _secondaryMedications:Vector.<HypertensionMedication> = new Vector.<HypertensionMedication>();

		private var _highestHypertensionMedication:HypertensionMedication;
		private var _mostRecentDoseChange:Date;
		private var _mostRecentSystolicVitalSign:VitalSign;

		private var _currentDateSource:ICurrentDateSource;

		public function HypertensionMedicationTitrationModel(activeRecordAccount:Account)
		{
			_record = activeRecordAccount.primaryRecord;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;

			_primaryMedications.push(new HypertensionMedication("Diuretic",
					HYDROCHLOROTHIAZIDE_12_5_MG_ORAL_TABLET_RXNORM, HYDROCHLOROTHIAZIDE_25_MG_ORAL_TABLET_RXNORM));
			_primaryMedications.push(new HypertensionMedication("Calcium Channel Blocker",
					AMLODIPINE_5_MG_ORAL_TABLET_RXNORM, AMLODIPINE_10_MG_ORAL_TABLET_RXNORM));
			_primaryMedications.push(new HypertensionMedication("ACE Inhibitor", LISINOPRIL_20_MG_ORAL_TABLET_RXNORM,
					LISINOPRIL_40_MG_ORAL_TABLET_RXNORM));

			BindingUtils.bindSetter(recordIsLoading_changeHandler, _record, "isLoading");
		}

		private function recordIsLoading_changeHandler(isLoading:Boolean):void
		{
			if (!isLoading)
			{
				_medicationScheduleItemsCollection = _record.medicationScheduleItemsModel.medicationScheduleItemCollection;
				_systolicVitalSignsCollection = _record.vitalSignsModel.getVitalSignsByCategory(VitalSignsModel.SYSTOLIC_CATEGORY) as
						ArrayCollection;

				determineHighestHypertensionMedication();

				determineMostRecentDoseChange();

				determineMostRecentSystolicVitalSign();

				if ((_currentDateSource.now().time - _mostRecentDoseChange.time) > NUMBER_OF_MILLISECONDS_IN_TWO_WEEKS)
				{
					if (_mostRecentSystolicVitalSign)
					{
						if (_mostRecentSystolicVitalSign.resultAsNumber > 130)
						{

						}
						else
						{

						}
					}
				}
			}


		}

		private function determineHighestHypertensionMedication():void
		{
			for each (var hypertensionMedication:HypertensionMedication in _primaryMedications)
			{
				hypertensionMedication.determineMedicationStage(_medicationScheduleItemsCollection);

				if (hypertensionMedication.currentDose != 0)
				{
					_highestHypertensionMedication = hypertensionMedication;
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
			_mostRecentSystolicVitalSign = _systolicVitalSignsCollection.getItemAt(_systolicVitalSignsCollection.length -
					1) as VitalSign;
		}

		public function handleHypertensionMedicationDoseSelected(hypertensionMedication:HypertensionMedication,
																 doseSelected:int, altKey:Boolean, ctrlKey:Boolean):void
		{
			if (altKey && ctrlKey)
			{
				if (hypertensionMedication.currentDose < doseSelected)
				{
					hypertensionMedication.currentDose = doseSelected;
				}
				else
				{
					hypertensionMedication.currentDose = doseSelected - 1;
				}
			}
			else if (altKey)
			{
				if (hypertensionMedication.systemDoseSelected == doseSelected)
				{
					hypertensionMedication.systemDoseSelected = 0;
				}
				else
				{
					hypertensionMedication.systemDoseSelected = doseSelected;
				}
			}
			else if (ctrlKey)
			{
				if (hypertensionMedication.coachDoseSelected == doseSelected)
				{
					hypertensionMedication.coachDoseSelected = -1;
					hypertensionMedication.coachDoseAction = null;
				}
				else
				{
					hypertensionMedication.coachDoseSelected = doseSelected;
					if (doseSelected <= hypertensionMedication.currentDose)
					{
						hypertensionMedication.coachDoseAction = HypertensionMedication.REMOVE
					}
					else
					{
						hypertensionMedication.coachDoseAction = HypertensionMedication.ADD;
					}
				}

				if (hypertensionMedication.patientDoseSelected == doseSelected)
				{
					hypertensionMedication.coachDoseAdviseVsAgree = HypertensionMedication.AGREE;
				}
				else
				{
					hypertensionMedication.coachDoseAdviseVsAgree = HypertensionMedication.ADVISE;
				}
			}
			else
			{
				if (hypertensionMedication.patientDoseSelected == doseSelected)
				{
					hypertensionMedication.patientDoseSelected = -1;
					hypertensionMedication.patientDoseAction = null;
				}
				else
				{
					hypertensionMedication.patientDoseSelected = doseSelected;
					if (doseSelected <= hypertensionMedication.currentDose)
					{
						hypertensionMedication.patientDoseAction = HypertensionMedication.REMOVE
					}
					else
					{
						hypertensionMedication.patientDoseAction = HypertensionMedication.ADD;
					}
				}

				if (hypertensionMedication.coachDoseSelected == doseSelected)
				{
					hypertensionMedication.patientDoseAdviseVsAgree = HypertensionMedication.AGREE;
				}
				else
				{
					hypertensionMedication.patientDoseAdviseVsAgree = HypertensionMedication.ADVISE;
				}
			}
		}

		public function get primaryMedications():Vector.<HypertensionMedication>
		{
			return _primaryMedications;
		}
	}
}
