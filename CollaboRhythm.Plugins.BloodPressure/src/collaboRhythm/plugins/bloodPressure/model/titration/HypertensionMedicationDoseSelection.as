package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;

	/**
	 * Model class indicating a selection (decision or recommendation) for a medication dose.
	 */
	public class HypertensionMedicationDoseSelection
	{
		//Actions
		public static const INCREASE:String = "Increase";
		public static const DECREASE:String = "Decrease";

		//SelectionTypes
		public static const SYSTEM:String = "System";
		public static const PATIENT:String = "Patient";
		public static const COACH:String = "Coach";

		private var _doseSelected:int;
		private var _newDose:int;
		private var _action:String;
		private var _selectionType:String;
		private var _selectionByAccountId:String;
		private var _persisted:Boolean;
		private var _medication:HypertensionMedication;
		private var _selectionDate:Date;

		public function HypertensionMedicationDoseSelection(doseSelected:int, action:String, selectionType:String,
															selectionByAccountId:String, persisted:Boolean,
															medication:HypertensionMedication, selectionDate:Date)
		{
			_doseSelected = doseSelected;
			_action = action;
			_selectionType = selectionType;
			_selectionByAccountId = selectionByAccountId;
			_persisted = persisted;
			_medication = medication;
			_selectionDate = selectionDate;
			updateNewDose();
		}

		private function updateNewDose():void
		{
			newDose = doseSelected + (action == DECREASE ? -1 : 0);
		}

		/**
		 * Dose level clicked on to make the selection.
		 * This is the dose strength to which the selection applies (and where it should be visually associated). For example,
		 * if the dose is being decreased from 2 to 1 (newDose = 1) then the doseSelected would be 2.
		 *
		 * @see DoseStrengthCode
		 */
		public function get doseSelected():int
		{
			return _doseSelected;
		}

		public function set doseSelected(value:int):void
		{
			_doseSelected = value;
			updateNewDose();
		}

		/**
		 * Increase, Decrease, or null, indicating what is the intended action of the selection.
		 * @see HypertensionMedicationDoseSelection.INCREASE
		 * @see HypertensionMedicationDoseSelection.DECREASE
		 */
		public function get action():String
		{
			return _action;
		}

		public function set action(value:String):void
		{
			_action = value;
		}

		/**
		 * System, Coach, or Patient indicating the type of entity that made the decision or recommendation.
		 * @see HypertensionMedicationDoseSelection.SYSTEM
		 * @see HypertensionMedicationDoseSelection.COACH
		 * @see HypertensionMedicationDoseSelection.PATIENT
		 */
		public function get selectionType():String
		{
			return _selectionType;
		}

		public function set selectionType(value:String):void
		{
			_selectionType = value;
		}

		/**
		 * The account that made the selection (if applicable)
		 */
		public function get selectionByAccountId():String
		{
			return _selectionByAccountId;
		}

		public function set selectionByAccountId(value:String):void
		{
			_selectionByAccountId = value;
		}

		/**
		 * Indicates that the dose selection has been persisted to the patient's record.
		 */
		public function get persisted():Boolean
		{
			return _persisted;
		}

		public function set persisted(value:Boolean):void
		{
			_persisted = value;
		}

		public function getSummary(includeSelectionType:Boolean = false):String
		{
			var summary:String = (includeSelectionType ? selectionType + " " : "");

			var verb:String = (action == INCREASE) ? (medication.currentDose == DoseStrengthCode.NONE ? "Add" : "Increase") : (newDose == DoseStrengthCode.NONE ? "Remove" : "Decrease");
			summary += includeSelectionType ? verb.toLowerCase() : verb;
			summary += " " + medication.medicationName;
			if (newDose != DoseStrengthCode.NONE)
			{
				summary += (medication.currentDose == DoseStrengthCode.NONE ? " at " : " to ") + DoseStrengthCode.describe(newDose);
				if (newDose > DoseStrengthCode.NONE)
				{
					summary += " (" + medication.getDoseDescription(newDose) + ")";
				}
			}
			return summary;
		}

		/**
		 * Dose strength code indicating what the new dose level would be after the selection.
		 * @see DoseStrengthCode
		 */
		public function get newDose():int
		{
			return _newDose;
		}

		public function set newDose(value:int):void
		{
			_newDose = value;
		}

		/**
		 * Determines if this selection is in agreement with the selection of the other party
		 * @return true if the dose selection is in agreement with the selection of the other party (other party for coach is patient, other party for patient is coach); otherwise, returns false indicating a new suggestion (or potentially disagreement).
		 */
		public function isInAgreement():Boolean
		{
			// TODO: implement
			return false;
		}

		public function get medication():HypertensionMedication
		{
			return _medication;
		}

		public function set medication(value:HypertensionMedication):void
		{
			_medication = value;
		}

		public function get rxNorm():String
		{
			return newDose == 1 ? medication.rxNorm1 : (newDose == 2 ? medication.rxNorm2 : null);
		}

		public function get medicationName():MedicationName
		{
			return newDose == 1 ? medication.medicationName1 : (newDose == 2 ? medication.medicationName2 : null);
		}

		public function get defaultNdcCode():String
		{
			return newDose == 1 ? medication.defaultNdcCode1 : (newDose == 2 ? medication.defaultNdcCode2 : null);
		}

		public function getScheduleDose(medicationOrder:MedicationOrder):Number
		{
			return medication.getScheduleDose(medicationOrder, this);
		}

		public function get selectionDate():Date
		{
			return _selectionDate;
		}

		public function set selectionDate(value:Date):void
		{
			_selectionDate = value;
		}

		/**
		 * Returns true if this selection should be ordered before the otherSelection.
		 * @param otherSelection
		 * @return
		 */
		public function isBefore(otherSelection:HypertensionMedicationDoseSelection):Boolean
		{
			if (selectionType == HypertensionMedicationDoseSelection.SYSTEM)
			{
				return true;
			}
			else if (otherSelection.selectionType == HypertensionMedicationDoseSelection.SYSTEM)
			{
				return false;
			}
			return selectionDate && otherSelection.selectionDate &&
					selectionDate.valueOf() < otherSelection.selectionDate.valueOf();
		}
	}
}
