package collaboRhythm.plugins.messages.view
{
	import flash.events.Event;

	public class VideoAvailableEvent extends Event
	{
		public static const VIDEO_AVAILABLE:String = "Video Available";

		private var _netStreamLocation:String;

		public function VideoAvailableEvent(type:String, netStreamLocation:String)
		{
			super(type, true);

			_netStreamLocation = netStreamLocation;
		}

		public function get netStreamLocation():String
		{
			return _netStreamLocation;
		}
	}
}
