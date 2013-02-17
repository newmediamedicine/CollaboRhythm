package collaboRhythm.plugins.bloodPressure.model
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
		private var _action:String;
		private var _selectionType:String;
		private var _account:Account;

		public function HypertensionMedicationDoseSelection(doseSelected:int, action:String, selectionType:String,
															account:Account = null)
		{
			_doseSelected = doseSelected;
			_action = action;
			_selectionType = selectionType;
			_account = account;
		}

		public function get doseSelected():int
		{
			return _doseSelected;
		}

		public function set doseSelected(value:int):void
		{
			_doseSelected = value;
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
	}
}
