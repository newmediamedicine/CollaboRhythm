package collaboRhythm.plugins.insulinTitrationSupport.model
{
	public class ConfirmChangePopUpModel
	{
		private var _previousDoseValue:Number;
		private var _dosageChangeValueLabel:String;
		private var _newDose:Number;
		private var _confirmationMessage:String;

		public function ConfirmChangePopUpModel(previousDoseValue:Number, dosageChangeValueLabel:String, newDose:Number, confirmationMessage:String)
		{
			_previousDoseValue = previousDoseValue;
			_dosageChangeValueLabel = dosageChangeValueLabel;
			_newDose = newDose;
			_confirmationMessage = confirmationMessage;
		}

		public function get newDose():Number
		{
			return _newDose;
		}

		public function get dosageChangeValueLabel():String
		{
			return _dosageChangeValueLabel;
		}

		public function get previousDoseValue():Number
		{
			return _previousDoseValue;
		}

		public function get confirmationMessage():String
		{
			return _confirmationMessage;
		}
	}
}
