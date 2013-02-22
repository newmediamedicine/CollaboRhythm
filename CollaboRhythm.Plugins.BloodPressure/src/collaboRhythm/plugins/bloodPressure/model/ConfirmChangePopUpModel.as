package collaboRhythm.plugins.bloodPressure.model
{
	public class ConfirmChangePopUpModel
	{
		private var _shouldFinalize:Boolean;
		private var _confirmationMessage:String;

		[Bindable]
		public function ConfirmChangePopUpModel(confirmationMessage:String)
		{
			_confirmationMessage = confirmationMessage;
		}

		public function get shouldFinalize():Boolean
		{
			return _shouldFinalize;
		}

		public function set shouldFinalize(value:Boolean):void
		{
			_shouldFinalize = value;
		}

		public function get confirmationMessage():String
		{
			return _confirmationMessage;
		}

		public function set confirmationMessage(value:String):void
		{
			_confirmationMessage = value;
		}
	}
}
