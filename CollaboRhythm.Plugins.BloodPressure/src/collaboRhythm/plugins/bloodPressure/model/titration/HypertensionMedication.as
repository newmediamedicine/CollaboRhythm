package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.bloodPressure.model.*;
	import collaboRhythm.shared.model.Account;
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

		private var _dose1:String;
		private var _dose2:String;

		private var _currentDose:int = 0;

		private var _patientDoseSelected:int = -1;
		private var _patientDoseAction:String;

		private var _dose1SelectionArrayCollection:ArrayCollection = new ArrayCollection();
		private var _dose2SelectionArrayCollection:ArrayCollection = new ArrayCollection();

		private var _doseSelectionArrayCollectionVector:Vector.<ArrayCollection> = new <ArrayCollection>[new ArrayCollection(), _dose1SelectionArrayCollection, _dose2SelectionArrayCollection];
		private var _pair:HypertensionMedicationAlternatePair;

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

		public function determineCurrentDose(medicationScheduleItemsCollection:ArrayCollection):void
		{
			for each (var medicationScheduleItem:MedicationScheduleItem in medicationScheduleItemsCollection)
			{
				if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "1") ||
						(medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "0.5"))
				{
					currentDose = 1;
				}
				else if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "2") ||
						(medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "1"))
				{
					currentDose = 2;
				}
			}
		}

		public function handleDoseSelected(doseSelected:int, altKey:Boolean, ctrlKey:Boolean, selectionByAccount:Account,
										   isPatient:Boolean):void
		{
			if (altKey && ctrlKey)
			{
				if (currentDose < doseSelected)
				{
					currentDose = doseSelected;
				}
				else
				{
					currentDose = doseSelected - 1;
				}
			}
			else
			{
				var action:String = determineAction(doseSelected);
				var selectionType:String;

				if (altKey)
				{
					selectionType = HypertensionMedicationDoseSelection.SYSTEM;
				}
				else if (isPatient == ctrlKey)
				{
					selectionType = HypertensionMedicationDoseSelection.COACH;
				}
				else
				{
					if (patientDoseSelected == doseSelected)
					{
						patientDoseSelected = -1;
						patientDoseAction = null;
					}
					else
					{
						patientDoseSelected = doseSelected;
						patientDoseAction = action;
					}

					selectionType = HypertensionMedicationDoseSelection.PATIENT;
				}

				addOrRemoveHypertensionMedicationDoseSelection(doseSelected, action, selectionType, selectionByAccount);
			}
		}

		private function determineAction(doseSelected:int):String
		{
			var action:String;

			if (doseSelected <= currentDose)
			{
				action = HypertensionMedicationDoseSelection.DECREASE;
			}
			else
			{
				action = HypertensionMedicationDoseSelection.INCREASE;
			}

			return action;
		}

		public function addOrRemoveHypertensionMedicationDoseSelection(doseSelected:int, action:String,
																		selectionType:String, selectionByAccount:Account):void
		{
			if (doseSelected == 1)
			{
				var remove:Boolean = removeHypertensionMedicationDoseSelection(_dose1SelectionArrayCollection,
						selectionType);
				removeHypertensionMedicationDoseSelection(_dose2SelectionArrayCollection, selectionType);

				if (!remove)
				{
					var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
							action, selectionType, selectionByAccount, false, this);
					_dose1SelectionArrayCollection.addItem(hypertensionMedicationDoseSelection);
				}
			}
			else if (doseSelected == 2)
			{
				var remove:Boolean = removeHypertensionMedicationDoseSelection(_dose2SelectionArrayCollection,
						selectionType);
				removeHypertensionMedicationDoseSelection(_dose1SelectionArrayCollection, selectionType);

				if (!remove)
				{
					var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
							action, selectionType, selectionByAccount, false, this);
					_dose2SelectionArrayCollection.addItem(hypertensionMedicationDoseSelection);
				}
			}
		}

		public function removeHypertensionMedicationDoseSelection(doseSelectionArrayCollection:ArrayCollection,
																   selectionType:String):Boolean
		{
			var indexToRemove:int = -1;
			for each (var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection in
					doseSelectionArrayCollection)
			{
				if (hypertensionMedicationDoseSelection.selectionType == selectionType)
				{
					indexToRemove = doseSelectionArrayCollection.getItemIndex(hypertensionMedicationDoseSelection);
					hypertensionMedicationDoseSelection.medication = null;
				}
			}

			if (indexToRemove == -1)
			{
				return false;
			}
			else
			{
				doseSelectionArrayCollection.removeItemAt(indexToRemove);
				return true;
			}
		}

		public function removeAllHypertensionMedicationDoseSelections(selectionType:String):void
		{
			removeHypertensionMedicationDoseSelection(_dose1SelectionArrayCollection, selectionType);
			removeHypertensionMedicationDoseSelection(_dose2SelectionArrayCollection, selectionType);

			if (selectionType == HypertensionMedicationDoseSelection.PATIENT)
			{
				patientDoseSelected = -1;
				patientDoseAction = null;
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

		public function get patientDoseSelected():int
		{
			return _patientDoseSelected;
		}

		public function set patientDoseSelected(value:int):void
		{
			_patientDoseSelected = value;
		}

		public function get patientDoseAction():String
		{
			return _patientDoseAction;
		}

		public function set patientDoseAction(value:String):void
		{
			_patientDoseAction = value;
		}

		public function get dose1SelectionArrayCollection():ArrayCollection
		{
			return _dose1SelectionArrayCollection;
		}

		public function get dose2SelectionArrayCollection():ArrayCollection
		{
			return _dose2SelectionArrayCollection;
		}

		public function get doseSelections():Vector.<HypertensionMedicationDoseSelection>
		{
			var doseSelections:Vector.<HypertensionMedicationDoseSelection> = new <HypertensionMedicationDoseSelection>[];
			for each (var selection:HypertensionMedicationDoseSelection in _dose1SelectionArrayCollection)
			{
				doseSelections.push(selection);
			}
			for each (selection in _dose2SelectionArrayCollection)
			{
				doseSelections.push(selection);
			}
			return doseSelections;
		}

		public function getDoseDescription(doseSelected:int):String
		{
			if (doseSelected == DoseStrengthCode.HALF) return dose1;
			if (doseSelected == DoseStrengthCode.FULL) return dose2;
			return null;
		}

		public function set pair(pair:HypertensionMedicationAlternatePair):void
		{
			_pair = pair;
		}

		public function get pair():HypertensionMedicationAlternatePair
		{
			return _pair;
		}

		public function restoreMedicationDoseSelection(doseSelected:int, newDose:int, selectionByAccount:Account, patientAccountId:String,
													   decisionDate:Date):void
		{
			var selection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
					determineAction(doseSelected),
					selectionByAccount && selectionByAccount.accountId ==
							patientAccountId ? HypertensionMedicationDoseSelection.PATIENT : HypertensionMedicationDoseSelection.COACH,
					selectionByAccount, true, this);

			if (selection.newDose == newDose)
			{
				_doseSelectionArrayCollectionVector[doseSelected].addItem(selection);
			}
		}

		public function clearSelections():void
		{
			for each (var arrayCollection:ArrayCollection in _doseSelectionArrayCollectionVector)
			{
				arrayCollection.removeAll();
			}
		}
	}
}
