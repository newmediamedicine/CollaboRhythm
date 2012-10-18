package collaboRhythm.plugins.schedule.shared.view
{
	import flash.events.Event;

	public class ScheduledHealthActionDetailViewEvent extends Event
	{
		public static const PLAY_VIDEO:String = "Play Video";

		private var _instructionalVideoPath:String;

		public function ScheduledHealthActionDetailViewEvent(type:String, instructionalVideoPath:String)
		{
			super(type);

			_instructionalVideoPath = instructionalVideoPath;
		}

		public function get instructionalVideoPath():String
		{
			return _instructionalVideoPath;
		}
	}
}
