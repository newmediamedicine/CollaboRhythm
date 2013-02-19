package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.shared.model.Account;

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
		private var _account:Account;
		private var _persisted:Boolean;

		public function HypertensionMedicationDoseSelection(doseSelected:int, action:String, selectionType:String,
															account:Account = null, persisted:Boolean = false)
		{
			_doseSelected = doseSelected;
			_action = action;
			_selectionType = selectionType;
			_account = account;
			_persisted = persisted;
			updateNewDose();
		}

		private function updateNewDose():void
		{
			newDose = doseSelected + (action == DECREASE ? -1 : 0);
		}

		/**
		 * Selected dose strength
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

		public function get action():String
		{
			return _action;
		}

		public function set action(value:String):void
		{
			_action = value;
		}

		public function get selectionType():String
		{
			return _selectionType;
		}

		public function set selectionType(value:String):void
		{
			_selectionType = value;
		}

		public function get account():Account
		{
			return _account;
		}

		public function set account(value:Account):void
		{
			_account = value;
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

		public function getSummary(pair:HypertensionMedicationAlternatePair, medication:HypertensionMedication):String
		{
			var summary:String = selectionType + " " + medication.medicationName;
			if (action == INCREASE)
			{
				summary += " increase to ";
			}
			else
			{
				summary += " decrease to ";
			}

			summary += DoseStrengthCode.describe(newDose);
			if (newDose > DoseStrengthCode.NONE)
			{
				summary += " (" + medication.getDoseDescription(doseSelected) + ")";
			}
			return summary;
		}

		public function get newDose():int
		{
			return _newDose;
		}

		public function set newDose(value:int):void
		{
			_newDose = value;
		}
	}
}
