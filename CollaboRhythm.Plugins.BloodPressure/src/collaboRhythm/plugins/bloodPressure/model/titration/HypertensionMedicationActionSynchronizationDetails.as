package collaboRhythm.plugins.bloodPressure.model.titration
{
	public class HypertensionMedicationActionSynchronizationDetails
	{
		private var _hypertensionMedicationClass:String;
		private var _doseSelected:int;
		private var _altKey:Boolean;
		private var _ctrlKey:Boolean;
		private var _selectionByAccountId:String;

		public function HypertensionMedicationActionSynchronizationDetails()
		{

		}

		public function get hypertensionMedicationClass():String
		{
			return _hypertensionMedicationClass;
		}

		public function set hypertensionMedicationClass(value:String):void
		{
			_hypertensionMedicationClass = value;
		}

		public function get doseSelected():int
		{
			return _doseSelected;
		}

		public function set doseSelected(value:int):void
		{
			_doseSelected = value;
		}

		public function get altKey():Boolean
		{
			return _altKey;
		}

		public function set altKey(value:Boolean):void
		{
			_altKey = value;
		}

		public function get ctrlKey():Boolean
		{
			return _ctrlKey;
		}

		public function set ctrlKey(value:Boolean):void
		{
			_ctrlKey = value;
		}

		public function get selectionByAccountId():String
		{
			return _selectionByAccountId;
		}

		public function set selectionByAccountId(value:String):void
		{
			_selectionByAccountId = value;
		}
	}
}
