package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

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
		private var _logger:ILogger;

		public function HypertensionMedication(medicationClass:String, medicationDefinition1:Array, medicationDefinition2:Array)
		{
			_medicationClass = medicationClass;
			_rxNorm1 = medicationDefinition1[0];
			_rxNorm2 = medicationDefinition2[0];
			var medicationName1:MedicationName = MedicationNameUtil.parseName(medicationDefinition1[1]);
			var medicationName2:MedicationName = MedicationNameUtil.parseName(medicationDefinition2[1]);
			medicationName = medicationName1.medicationName;
			dose1 = medicationName1.strength;
			dose2 = medicationName2.strength;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
		}

		public function determineCurrentDose(medicationScheduleItemsCollection:ArrayCollection):void
		{
			for each (var medicationScheduleItem:MedicationScheduleItem in medicationScheduleItemsCollection)
			{
				if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "1") ||
						(medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "0.5"))
				{
					currentDose = 1;
					return;
				}
				else if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "2") ||
						(medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "1"))
				{
					currentDose = 2;
					return;
				}
			}
			currentDose = 0;
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
				removeAllHypertensionMedicationDoseSelections(null, matchSelectionAll);
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
					updatePatientDoseSelected(doseSelected, action);
					selectionType = HypertensionMedicationDoseSelection.PATIENT;
				}

				addOrRemoveHypertensionMedicationDoseSelection(doseSelected, action, selectionType, selectionByAccount);
			}
		}

		private function updatePatientDoseSelected(doseSelected:int, action:String):void
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
			var matchParameters:MatchParameters = HypertensionMedication.getMatchParameters(selectionType == HypertensionMedicationDoseSelection.SYSTEM, selectionByAccount);

			if (doseSelected == 1)
			{
				var remove:Boolean = removeHypertensionMedicationDoseSelections(_dose1SelectionArrayCollection,
						matchParameters.matchData, matchParameters.matchFunction);
				removeHypertensionMedicationDoseSelections(_dose2SelectionArrayCollection, matchParameters.matchData, matchParameters.matchFunction);

				if (!remove)
				{
					var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
							action, selectionType, selectionByAccount, false, this);
					_dose1SelectionArrayCollection.addItem(hypertensionMedicationDoseSelection);
				}
			}
			else if (doseSelected == 2)
			{
				var remove:Boolean = removeHypertensionMedicationDoseSelections(_dose2SelectionArrayCollection,
						matchParameters.matchData, matchParameters.matchFunction);
				removeHypertensionMedicationDoseSelections(_dose1SelectionArrayCollection, matchParameters.matchData, matchParameters.matchFunction);

				if (!remove)
				{
					var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
							action, selectionType, selectionByAccount, false, this);
					_dose2SelectionArrayCollection.addItem(hypertensionMedicationDoseSelection);
				}
			}
		}

		/**
		 * Match selection function that always returns true. Use this function to get all dose selections.
		 * @param selection
		 * @param ignored
		 * @return true
		 */
		public static function matchSelectionAll(selection:HypertensionMedicationDoseSelection, ignored:String):Boolean
		{
			return true;
		}

		/**
		 *
		 * @param selection
		 * @param selectionType
		 * @return
		 */
		public static function matchSelectionByType(selection:HypertensionMedicationDoseSelection, selectionType:String):Boolean
		{
			return selection.selectionType == selectionType;
		}

		public static function matchSelectionByAccountId(selection:HypertensionMedicationDoseSelection, selectionByAccountId:String):Boolean
		{
			return selection.selectionType != HypertensionMedicationDoseSelection.SYSTEM &&
					selection.selectionByAccount && selection.selectionByAccount.accountId == selectionByAccountId;
		}

		/**
		 * Removes the dose selection(s) for the specified collection and type.
		 * @param doseSelectionArrayCollection This should be dose1SelectionArrayCollection or dose2SelectionArrayCollection
		 * @param matchData Data passed to the match function for matching
		 * @param matchFunction Function to test for a matching HypertensionMedicationDoseSelection. First parameter is
		 * the HypertensionMedicationDoseSelection, second parameter is a String (optional data).
		 * @return true if one or more selections were removed
		 */
		public function removeHypertensionMedicationDoseSelections(doseSelectionArrayCollection:ArrayCollection,
																   matchData:String, matchFunction:Function):Boolean
		{
			var selectionRemoved:Boolean = false;
			for (var i:int = doseSelectionArrayCollection.length - 1; i >= 0; i--)
			{
				var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection = doseSelectionArrayCollection[i];
				if (matchFunction(hypertensionMedicationDoseSelection, matchData))
				{
					doseSelectionArrayCollection.removeItemAt(i);
					hypertensionMedicationDoseSelection.medication = null;
					selectionRemoved = true;
				}
			}

			return selectionRemoved;
		}

		/**
		 * Removes all the dose selection(s) for the specified type.
		 * @param matchData Data passed to the match function for matching
		 * @param matchFunction Function to test for a matching HypertensionMedicationDoseSelection. First parameter is
		 * the HypertensionMedicationDoseSelection, second parameter is a String (optional data).
		 */
		public function removeAllHypertensionMedicationDoseSelections(matchData:String, matchFunction:Function):void
		{
			removeHypertensionMedicationDoseSelections(_dose1SelectionArrayCollection, matchData, matchFunction);
			removeHypertensionMedicationDoseSelections(_dose2SelectionArrayCollection, matchData, matchFunction);

			if (matchData == null || matchData == HypertensionMedicationDoseSelection.PATIENT)
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

				if (selection.selectionType == HypertensionMedicationDoseSelection.PATIENT)
				{
					updatePatientDoseSelected(doseSelected, selection.action);
				}
			}
			else
			{
				_logger.warn("Failed to restore medication dose selection. Current medication dose has changed from when selection was made. " + selection.getSummary(true));
			}
		}

		public function clearSelections():void
		{
			for each (var arrayCollection:ArrayCollection in _doseSelectionArrayCollectionVector)
			{
				arrayCollection.removeAll();
			}
			patientDoseSelected = -1;
			patientDoseAction = null;
		}

		public static function getMatchParameters(isSystem:Boolean, selectionByAccount:Account):MatchParameters
		{
			var matchData:String;
			var matchFunction:Function;
			if (isSystem)
			{
				matchData = HypertensionMedicationDoseSelection.SYSTEM;
				matchFunction = matchSelectionByType;
			}
			else
			{
				matchData = selectionByAccount.accountId;
				matchFunction = matchSelectionByAccountId;
			}
			return new MatchParameters(matchData, matchFunction);
		}
	}
}
