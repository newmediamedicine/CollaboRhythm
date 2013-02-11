package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class HypertensionMedication
	{
		private var _medicationClass:String;
		private var _rxNorm1:String;
		private var _rxNorm2:String;
		private var _medicationName:String;
		private var _medicationDosageChoice1:String;
		private var _medicationDosageChoice2:String;
		private var _medicationStage:int = 0;
		private var _systemRecommendedMedicationStage:int;
		private var _patientRecommendedMedicationStage:int;
		private var _coachRecommendedMedicationStage:int;

		public function HypertensionMedication(medicationClass:String, rxNorm1:String, rxNorm2:String)
		{
			_medicationClass = medicationClass;
			_rxNorm1 = rxNorm1;
			_rxNorm2 = rxNorm2;
			var medicationName1:MedicationName = MedicationNameUtil.parseName(rxNorm1);
			var medicationName2:MedicationName = MedicationNameUtil.parseName(rxNorm2);
			_medicationName = medicationName1.medicationName;
			_medicationDosageChoice1 = medicationName1.strength;
			_medicationDosageChoice2 = medicationName2.strength;
		}

		public function determineMedicationStage(medicationScheduleItemsCollection:ArrayCollection):void
		{
			for each (var medicationScheduleItem:MedicationScheduleItem in medicationScheduleItemsCollection)
			{
				if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "1") || (medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "0.5"))
				{
					medicationStage = 1;
				}
				else if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "2") || (medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "1"))
				{
					medicationStage = 2;
				}
			}
		}

		public function get medicationStage():int
		{
			return _medicationStage;
		}

		public function set medicationStage(value:int):void
		{
			_medicationStage = value;
		}

		public function get systemRecommendedMedicationStage():int
		{
			return _systemRecommendedMedicationStage;
		}

		public function set systemRecommendedMedicationStage(value:int):void
		{
			_systemRecommendedMedicationStage = value;
		}

		public function get patientRecommendedMedicationStage():int
		{
			return _patientRecommendedMedicationStage;
		}

		public function set patientRecommendedMedicationStage(value:int):void
		{
			_patientRecommendedMedicationStage = value;
		}

		public function get coachRecommendedMedicationStage():int
		{
			return _coachRecommendedMedicationStage;
		}

		public function set coachRecommendedMedicationStage(value:int):void
		{
			_coachRecommendedMedicationStage = value;
		}

		public function get medicationClass():String
		{
			return _medicationClass;
		}

		public function set medicationClass(value:String):void
		{
			_medicationClass = value;
		}

		public function get rxNorm1():String
		{
			return _rxNorm1;
		}

		public function set rxNorm1(value:String):void
		{
			_rxNorm1 = value;
		}

		public function get rxNorm2():String
		{
			return _rxNorm2;
		}

		public function set rxNorm2(value:String):void
		{
			_rxNorm2 = value;
		}

		public function get medicationName():String
		{
			return _medicationName;
		}

		public function set medicationName(value:String):void
		{
			_medicationName = value;
		}

		public function get medicationDosageChoice1():String
		{
			return _medicationDosageChoice1;
		}

		public function set medicationDosageChoice1(value:String):void
		{
			_medicationDosageChoice1 = value;
		}

		public function get medicationDosageChoice2():String
		{
			return _medicationDosageChoice2;
		}

		public function set medicationDosageChoice2(value:String):void
		{
			_medicationDosageChoice2 = value;
		}
	}
}
