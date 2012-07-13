package collaboRhythm.plugins.insulinTitrationSupport.model
{
	public class ConfirmChangePopUpModel
	{
		private var _previousDoseValue:Number;
		private var _dosageChangeValueLabel:String;
		private var _newDose:Number;

		public function ConfirmChangePopUpModel(previousDoseValue:Number, dosageChangeValueLabel:String, newDose:Number)
		{
			_previousDoseValue = previousDoseValue;
			_dosageChangeValueLabel = dosageChangeValueLabel;
			_newDose = newDose;
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
	}
}
