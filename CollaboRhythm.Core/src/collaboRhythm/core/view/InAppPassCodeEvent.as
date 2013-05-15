package collaboRhythm.core.view
{
	import flash.events.Event;

	public class InAppPassCodeEvent extends Event
	{
		public static const PASSCODE_ENTERED:String = "passcode entered";

		private var _passcode:String;

		public function InAppPassCodeEvent(type:String, passcode:String)
		{
			super(type);

			_passcode = passcode;
		}

		public function get passcode():String
		{
			return _passcode;
		}
	}
}
