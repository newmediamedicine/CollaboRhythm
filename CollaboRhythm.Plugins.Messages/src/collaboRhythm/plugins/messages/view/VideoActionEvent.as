package collaboRhythm.plugins.messages.view
{
	import flash.events.Event;

	public class VideoActionEvent extends Event
	{
		public static const VIDEO_RECORDED:String = "Video Available";
		public static const VIDEO_PLAYABLE:String = "Video Playable";
		public static const PLAY_VIDEO:String = "Play Video";

		private var _netStreamLocation:String;

		public function VideoActionEvent(type:String, netStreamLocation:String)
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
