package collaboRhythm.plugins.bloodPressure.model
{
	[Bindable]
	public class ConfirmChangePopUpModel
	{
		private var _shouldFinalize:Boolean;
		private var _confirmationMessage:String;
		private var _headerMessage:String;
		private var _selectionsAgreeWithSystem:Boolean;
		private var _selectionsMessage:String;

		public function ConfirmChangePopUpModel(confirmationMessage:String, headerMessage:String, selectionsAgreeWithSystem:Boolean,
												selectionsMessage:String)
		{
			_confirmationMessage = confirmationMessage;
			_headerMessage = headerMessage;
			_selectionsAgreeWithSystem = selectionsAgreeWithSystem;
			_selectionsMessage = selectionsMessage;
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

		public function get headerMessage():String
		{
			return _headerMessage;
		}

		public function set headerMessage(value:String):void
		{
			_headerMessage = value;
		}

		public function get selectionsAgreeWithSystem():Boolean
		{
			return _selectionsAgreeWithSystem;
		}

		public function set selectionsAgreeWithSystem(value:Boolean):void
		{
			_selectionsAgreeWithSystem = value;
		}

		public function get selectionsMessage():String
		{
			return _selectionsMessage;
		}

		public function set selectionsMessage(value:String):void
		{
			_selectionsMessage = value;
		}
	}
}
