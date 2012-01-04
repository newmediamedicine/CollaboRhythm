package collaboRhythm.core.model
{

	public class BackgroundProcessModel
	{
		private var _message:String;
		public function BackgroundProcessModel(processKey:String, message:String)
		{
		}

		public function get message():String
		{
			return _message;
		}

		public function set message(value:String):void
		{
			_message = value;
		}
	}
}
