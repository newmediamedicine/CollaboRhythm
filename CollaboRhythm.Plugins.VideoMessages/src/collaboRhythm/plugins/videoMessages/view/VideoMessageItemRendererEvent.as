package collaboRhythm.plugins.videoMessages.view
{

    import collaboRhythm.shared.model.healthRecord.document.VideoMessage;

    import flash.events.Event;

    public class VideoMessageItemRendererEvent extends Event
    {
        public static const PLAY_VIDEO_MESSAGE:String = "Play Video Message";
        public static const DELETE_VIDEO_MESSAGE:String = "Delete Video Message";

        private var _videoMessage:VideoMessage;

        public function VideoMessageItemRendererEvent(type:String, videoMessage:VideoMessage)
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
