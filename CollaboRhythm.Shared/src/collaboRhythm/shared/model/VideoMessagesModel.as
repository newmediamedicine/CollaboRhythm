package collaboRhythm.shared.model
{

    import collaboRhythm.shared.model.healthRecord.VideoMessagesHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.collections.ArrayCollection;

    public class VideoMessagesModel
    {
        private var _record:Record;
        private var _videoMessagesHealthRecordService:VideoMessagesHealthRecordService;
        private var _videoMessagesCollection:ArrayCollection = new ArrayCollection();
        private var _videoMessageCount:int = 0;
        private var _currentDateSource:ICurrentDateSource;

        public function VideoMessagesModel(settings:Settings, activeAccount:Account, record:Record)
        {
            _record = record;
            _videoMessagesHealthRecordService = new VideoMessagesHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
        }

        public function getVideoMessages():void
        {
            _videoMessagesHealthRecordService.getVideoMessages(_record);
        }

		public function set videoMessagesReportXML(value:XML):void
		{
            for each (var videoMessageReport:XML in value.Report)
			{
				var videoMessage:VideoMessage = new VideoMessage();
                videoMessage.initFromReportXML(videoMessageReport);
                if (videoMessage.fileId > videoMessageCount)
                {
                    videoMessageCount = videoMessage.fileId;
                }
                _videoMessagesCollection.addItem(videoMessage);
			}
		}

        public function createVideoMessage(from:String):void
        {
            var videoMessage:VideoMessage = new VideoMessage();
            videoMessage.init((_videoMessageCount+1).toString(), "FlashMediaServer", "test", from, currentDateSource.now(), currentDateSource.now());
            _videoMessageCount += 1;
            _videoMessagesCollection.addItem(videoMessage);
            _videoMessagesHealthRecordService.postVideoMessage(_record, videoMessage);
        }

        public function get videoMessagesCollection():ArrayCollection
        {
            return _videoMessagesCollection;
        }

        public function set videoMessagesCollection(value:ArrayCollection):void
        {
            _videoMessagesCollection = value;
        }

        public function get videoMessageCount():int
        {
            return _videoMessageCount;
        }

        public function set videoMessageCount(value:int):void
        {
            _videoMessageCount = value;
        }

        public function get currentDateSource():ICurrentDateSource
        {
            return _currentDateSource;
        }
    }
}
