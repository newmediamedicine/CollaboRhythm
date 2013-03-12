package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

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
		private var _medicationScheduleItem:MedicationScheduleItem;

		private var _medicationName1:MedicationName;
		private var _medicationName2:MedicationName;
		private var _defaultNdcCode1:String;
		private var _defaultNdcCode2:String;

		protected var _currentDateSource:ICurrentDateSource;

		public function HypertensionMedication(medicationClass:String, medicationDefinition1:Array, medicationDefinition2:Array)
		{
			_medicationClass = medicationClass;
			_rxNorm1 = medicationDefinition1[0];
			_rxNorm2 = medicationDefinition2[0];
			_medicationName1 = MedicationNameUtil.parseName(medicationDefinition1[1]);
			_medicationName2 = MedicationNameUtil.parseName(medicationDefinition2[1]);
			_defaultNdcCode1 = medicationDefinition1[2];
			_defaultNdcCode2 = medicationDefinition2[2];
			medicationName = _medicationName1.medicationName;
			dose1 = _medicationName1.strength;
			dose2 = _medicationName2.strength;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function determineCurrentDose(medicationScheduleItemsCollection:ArrayCollection):void
		{
			for each (var medicationScheduleItem:MedicationScheduleItem in medicationScheduleItemsCollection)
			{
				if (medicationScheduleItem.isScheduledCurrently())
				{
					if ((medicationScheduleItem.name.value == _rxNorm1 && medicationScheduleItem.dose.value == "1") ||
							(medicationScheduleItem.name.value == _rxNorm2 &&
									medicationScheduleItem.dose.value == "0.5"))
					{
						this.medicationScheduleItem = medicationScheduleItem;
						currentDose = 1;
						return;
					}
					else if ((medicationScheduleItem.name.value == _rxNorm1 &&
							medicationScheduleItem.dose.value == "2") ||
							(medicationScheduleItem.name.value == _rxNorm2 && medicationScheduleItem.dose.value == "1"))
					{
						this.medicationScheduleItem = medicationScheduleItem;
						currentDose = 2;
						return;
					}
				}
			}
			currentDose = 0;
		}

		public function handleDoseSelected(doseSelected:int, altKey:Boolean, ctrlKey:Boolean,
										   selectionByAccountId:String, isPatient:Boolean):void
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

				addOrRemoveHypertensionMedicationDoseSelection(doseSelected, action, selectionType, selectionByAccountId);
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
																	   selectionType:String,
																	   selectionByAccountId:String):void
		{
			var matchParameters:MatchParameters = HypertensionMedication.getMatchParameters(selectionType ==
					HypertensionMedicationDoseSelection.SYSTEM, selectionByAccountId);

			if (doseSelected == 1)
			{
				var remove:Boolean = removeHypertensionMedicationDoseSelections(_dose1SelectionArrayCollection,
						matchParameters.matchData, matchParameters.matchFunction);
				removeHypertensionMedicationDoseSelections(_dose2SelectionArrayCollection, matchParameters.matchData, matchParameters.matchFunction);

				if (!remove)
				{
					var hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
							action, selectionType, selectionByAccountId, false, this, _currentDateSource.now());
					addSelectionToCollection(hypertensionMedicationDoseSelection, _dose1SelectionArrayCollection);
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
							action, selectionType, selectionByAccountId, false, this, _currentDateSource.now());
					addSelectionToCollection(hypertensionMedicationDoseSelection, _dose2SelectionArrayCollection);
				}
			}
		}

		protected function addSelectionToCollection(hypertensionMedicationDoseSelection:HypertensionMedicationDoseSelection,
													doseSelectionCollection:ArrayCollection):void
		{
			if (hypertensionMedicationDoseSelection.selectionType == HypertensionMedicationDoseSelection.SYSTEM)
			{
				doseSelectionCollection.addItemAt(hypertensionMedicationDoseSelection, 0);
			}
			else
			{
				doseSelectionCollection.addItem(hypertensionMedicationDoseSelection);
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
					selection.selectionByAccountId == selectionByAccountId;
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

		public function get defaultNdcCode1():String
		{
			return _defaultNdcCode1;
		}

		public function set defaultNdcCode1(value:String):void
		{
			_defaultNdcCode1 = value;
		}

		public function get defaultNdcCode2():String
		{
			return _defaultNdcCode2;
		}

		public function set defaultNdcCode2(value:String):void
		{
			_defaultNdcCode2 = value;
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

		/**
		 * Increase, Decrease, or null, indicating what is the intended action by the patient.
		 * @see HypertensionMedicationDoseSelection.INCREASE
		 * @see HypertensionMedicationDoseSelection.DECREASE
		 */
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
			if (doseSelected == DoseStrengthCode.LOW) return dose1;
			if (doseSelected == DoseStrengthCode.HIGH) return dose2;
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

		public function restoreMedicationDoseSelection(doseSelected:int, newDose:int, selectionByAccountId:String,
													   patientAccountId:String, decisionDate:Date):void
		{
			var selection:HypertensionMedicationDoseSelection = new HypertensionMedicationDoseSelection(doseSelected,
					determineAction(doseSelected), selectionByAccountId ==
							patientAccountId ? HypertensionMedicationDoseSelection.PATIENT : HypertensionMedicationDoseSelection.COACH,
					selectionByAccountId, true, this, decisionDate);

			if (selection.newDose == newDose)
			{
				var index:int = 0;
				var targetIndex:int = 0;
				for each (var existingSelection:HypertensionMedicationDoseSelection in
						_doseSelectionArrayCollectionVector[doseSelected])
				{
					if (existingSelection.isBefore(selection))
					{
						targetIndex = index + 1;
					}
					index++;
				}

				_doseSelectionArrayCollectionVector[doseSelected].addItemAt(selection, targetIndex);

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

		public function clearSystemSelections():void
		{
			removeAllHypertensionMedicationDoseSelections(HypertensionMedicationDoseSelection.SYSTEM, matchSelectionByType);
		}

		public static function getMatchParameters(isSystem:Boolean, selectionByAccountId:String):MatchParameters
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
				matchData = selectionByAccountId;
				matchFunction = matchSelectionByAccountId;
			}
			return new MatchParameters(matchData, matchFunction);
		}

		public function set medicationScheduleItem(medicationScheduleItem:MedicationScheduleItem):void
		{
			_medicationScheduleItem = medicationScheduleItem;
		}

		public function get medicationScheduleItem():MedicationScheduleItem
		{
			return _medicationScheduleItem;
		}

		public function get medicationName1():MedicationName
		{
			return _medicationName1;
		}

		public function set medicationName1(value:MedicationName):void
		{
			_medicationName1 = value;
		}

		public function get medicationName2():MedicationName
		{
			return _medicationName2;
		}

		public function set medicationName2(value:MedicationName):void
		{
			_medicationName2 = value;
		}

		public function getScheduleDose(medicationOrder:MedicationOrder,
										selection:HypertensionMedicationDoseSelection):Number
		{
			if (medicationOrder.name.value == rxNorm1)
			{
				return selection.newDose == 1 ? 1 : 2;
			}
			else if (medicationOrder.name.value == rxNorm2)
			{
				return selection.newDose == 2 ? 1 : 0.5;
			}
			else
			{
				_logger.error("Unexpected RxNorm code in MedicationOrder " + medicationOrder.name.toString());
				return 1;
			}
		}

		public function getSelectionForAccount(byAccountSelection:Account):HypertensionMedicationDoseSelection
		{
			return getMatchingSelection(byAccountSelection.accountId, matchSelectionByAccountId);
		}

		/**
		 * Finds the most recent matching HypertensionMedicationDoseSelection, or null if there are no matches.
		 * @param matchData Data passed to the match function for matching
		 * @param matchFunction Function to test for a matching HypertensionMedicationDoseSelection. First parameter is
		 * the HypertensionMedicationDoseSelection, second parameter is a String (optional data).
		 * @return the most recent matching HypertensionMedicationDoseSelection, or null if there are no matches
		 */
		public function getMatchingSelection(matchData:String, matchFunction:Function):HypertensionMedicationDoseSelection
		{
			for each (var doseSelectionArrayCollection:ArrayCollection in _doseSelectionArrayCollectionVector)
			{
				for (var i:int = doseSelectionArrayCollection.length - 1; i >= 0; i--)
				{
					var selection:HypertensionMedicationDoseSelection = doseSelectionArrayCollection[i];
					if (matchFunction(selection, matchData))
					{
						return selection;
					}
				}
			}
			return null;
		}
	}
}
