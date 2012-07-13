package collaboRhythm.plugins.insulinTitrationSupport.model
{
	public class ConfirmChangePopUpModel
	{
		private var _currentDoseValue:Number;
		private var _dosageChangeValue:Number;
		private var _newDose:Number;

		public function ConfirmChangePopUpModel(currentDoseValue:Number, dosageChangeValue:Number, newDose:Number)
		{
			_currentDoseValue = currentDoseValue;
			_dosageChangeValue = dosageChangeValue;
			_newDose = newDose;
		}

		public function get currentDoseValue():Number
		{
			return _currentDoseValue;
		}

		public function get dosageChangeValue():Number
		{
			return _dosageChangeValue;
		}

		public function get dosageChangeValueLabel():String
		{
			return dosageChangeValue > 0 ? "+" + dosageChangeValue.toString() : dosageChangeValue.toString();
		}

		public function get newDose():Number
		{
			return _newDose;
		}
	}
}
