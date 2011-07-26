package collaboRhythm.tablet.view
{

	import flash.events.Event;

	public class ConnectivityEvent extends Event
	{
		public static const RETRY:String = "retry";
		public static const IGNORE:String = "ignore";
		public static const QUIT:String = "quit";

		public function ConnectivityEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
