package collaboRhythm.core.controller
{

	import flash.desktop.NativeApplication;
	import flash.events.Event;

	public class ApplicationExitUtil
	{
		public function ApplicationExitUtil()
		{
		}

		/**
		 * Close the entire application, sending out an event to any processes that might want to interrupt the closing
		 */
		public static function exit():void
		{
			var exitingEvent:Event = new Event(Event.EXITING, false, true);
			NativeApplication.nativeApplication.dispatchEvent(exitingEvent);
			if (!exitingEvent.isDefaultPrevented())
			{
				NativeApplication.nativeApplication.exit();
			}
		}
	}
}
