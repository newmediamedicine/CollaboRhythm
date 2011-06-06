package collaboRhythm.tablet.view
{

    import collaboRhythm.shared.model.VideoMessage;

    import flash.events.Event;

    public class VideosViewEvent extends Event
    {
        public static const PLAY_VIDEO_MESSAGE:String = "Play Video Message";

        private var _videoMessage:VideoMessage;

        public function VideosViewEvent(type:String, videoMessage:VideoMessage)
        {
            super(type, true);
            _videoMessage = videoMessage;
        }

        public function get videoMessage():VideoMessage
        {
            return _videoMessage;
        }
    }
}
