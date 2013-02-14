package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class HypertensionMedication
	{
		public static const ADVISE:String = "Advise";
		public static const AGREE:String = "Agree";

		public static const ADD:String = "Add";
		public static const REMOVE:String = "Remove";

		private var _medicationClass:String;
		private var _rxNorm1:String;
		private var _rxNorm2:String;
		private var _medicationName:String;

		private var _dose1:String;
		private var _dose2:String;

		private var _currentDose:int = 0;

		private var _systemDoseSelected:int = -1;
		private var _systemDoseAction:String;
		private var _patientDoseSelected:int = -1;
		private var _patientDoseAction:String;
		private var _coachDoseSelected:int = -1;
		private var _coachDoseAction:String;

		private var _patientDoseAdviseVsAgree:String;
		private var _coachDoseAdviseVsAgree:String;

		public function HypertensionMedication(medicationClass:String, rxNorm1:String, rxNorm2:String)
		{
			_medicationClass = medicationClass;
			_rxNorm1 = rxNorm1;
			_rxNorm2 = rxNorm2;
			var medicationName1:MedicationName = MedicationNameUtil.parseName(rxNorm1);
			var medicationName2:MedicationName = MedicationNameUtil.parseName(rxNorm2);
			medicationName = medicationName1.medicationName;
			dose1 = medicationName1.strength;
			dose2 = medicationName2.strength;
		}

		public function determineMedicationStage(medicationScheduleItemsCollection:ArrayCollection):void
		{
			for each (var medicationScheduleItem:MedicationScheduleItem in medicationScheduleItemsCollection)
			{
				if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "1") || (medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "0.5"))
				{
					currentDose = 1;
				}
				else if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "2") || (medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "1"))
				{
					currentDose = 2;
				}
			}
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


		public function get dose1():String
		{
			return _dose1;
		}

		public function set dose1(value:String):void
		{
			_dose1 = value;
		}

		public function get dose2():String
		{
			return _dose2;
		}

		public function set dose2(value:String):void
		{
			_dose2 = value;
		}

		public function get currentDose():int
		{
			return _currentDose;
		}

		public function set currentDose(value:int):void
		{
			_currentDose = value;
		}

		public function get systemDoseSelected():int
		{
			return _systemDoseSelected;
		}

		public function set systemDoseSelected(value:int):void
		{
			_systemDoseSelected = value;
		}

		public function get patientDoseSelected():int
		{
			return _patientDoseSelected;
		}

		public function set patientDoseSelected(value:int):void
		{
			_patientDoseSelected = value;
		}

		public function get coachDoseSelected():int
		{
			return _coachDoseSelected;
		}

		public function set coachDoseSelected(value:int):void
		{
			_coachDoseSelected = value;
		}

		public function get systemDoseAction():String
		{
			return _systemDoseAction;
		}

		public function set systemDoseAction(value:String):void
		{
			_systemDoseAction = value;
		}

		public function get patientDoseAction():String
		{
			return _patientDoseAction;
		}

		public function set patientDoseAction(value:String):void
		{
			_patientDoseAction = value;
		}

		public function get coachDoseAction():String
		{
			return _coachDoseAction;
		}

		public function set coachDoseAction(value:String):void
		{
			_coachDoseAction = value;
		}

		public function get patientDoseAdviseVsAgree():String
		{
			return _patientDoseAdviseVsAgree;
		}

		public function set patientDoseAdviseVsAgree(value:String):void
		{
			_patientDoseAdviseVsAgree = value;
		}

		public function get coachDoseAdviseVsAgree():String
		{
			return _coachDoseAdviseVsAgree;
		}

		public function set coachDoseAdviseVsAgree(value:String):void
		{
			_coachDoseAdviseVsAgree = value;
		}
	}
}
