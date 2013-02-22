package collaboRhythm.shared.model
{

	public class BackgroundProcessModel
	{
		private var _processKey:String;
		private var _message:String;

		public function BackgroundProcessModel(processKey:String, message:String)
		{
			_processKey = processKey;
			_message = message;
		}

		public function get message():String
		{
			return _message;
		}

		public function set message(value:String):void
		{
			_message = value;
		}

		public function get processKey():String
		{
			return _processKey;
		}

		public function set processKey(value:String):void
		{
			_processKey = value;
		}
	}
}
