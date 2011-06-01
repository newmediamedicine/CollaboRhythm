package collaboRhythm.shared.model
{
    import collaboRhythm.shared.model.healthRecord.DocumentMetadata;

    import collaboRhythm.shared.model.DateUtil;
    import com.adobe.utils.DateUtil;

    [Bindable]
    public class VideoMessage extends DocumentMetadata
    {
        private var _activeAccount:Account;

        private var _fileId:int;
        private var _storageType:String;
        private var _subject:String;
        private var _from:Account;
        private var _dateRecorded:Date;
        private var _dateSent:Date;

        public function VideoMessage(activeAccount:Account)
        {
            _activeAccount = activeAccount;
        }

        public function init(fileId:String, storageType:String, subject:String, from:String, dateRecorded:Date, dateSent:Date):void
		{
			_fileId = int(fileId);
            _storageType = storageType;
            _subject = subject;
            // TODO: Add checking here for null and potentially return null from the init
            // This might occur if there was previously a sharing relationship, a video was sent, but then the sharing relationship was removed
            _from = _activeAccount.allSharingAccounts[from];
            _dateRecorded = dateRecorded;
            _dateSent = dateSent;
		}

		public function initFromReportXML(videoMessageReportXml:XML):void
		{
			parseDocumentMetadata(videoMessageReportXml.Meta.Document[0], this);
			var videoMessageXml:XML = videoMessageReportXml.Item.VideoMessage[0];
			_fileId = int(videoMessageXml.fileId);
			_storageType = videoMessageXml.storageType;
			_subject = videoMessageXml.subject;
			_from = _activeAccount.allSharingAccounts[videoMessageXml.from];
            _dateRecorded = collaboRhythm.shared.model.DateUtil.parseW3CDTF(videoMessageXml.dateRecorded);
            _dateSent = collaboRhythm.shared.model.DateUtil.parseW3CDTF(videoMessageXml.dateSent);
		}

        public function convertToXML():XML
		{
			var videoMessageXml:XML = <VideoMessage/>;
			videoMessageXml.@xmlns = "http://indivo.org/vocab/xml/documents#";
			videoMessageXml.fileId = fileId;
            videoMessageXml.storageType = storageType;
            videoMessageXml.subject = subject;
            videoMessageXml.from = from;
            videoMessageXml.dateRecorded = com.adobe.utils.DateUtil.toW3CDTF(dateRecorded);
            videoMessageXml.dateSent = com.adobe.utils.DateUtil.toW3CDTF(dateSent);
			
			return videoMessageXml;
		}

        public function get fileId():int
        {
            return _fileId;
        }

        public function set fileId(value:int):void
        {
            _fileId = value;
        }

        public function get storageType():String
        {
            return _storageType;
        }

        public function set storageType(value:String):void
        {
            _storageType = value;
        }

        public function get subject():String
        {
            return _subject;
        }

        public function set subject(value:String):void
        {
            _subject = value;
        }

        public function get from():Account
        {
            return _from;
        }

        public function set from(value:Account):void
        {
            _from = value;
        }

        public function get dateRecorded():Date
        {
            return _dateRecorded;
        }

        public function set dateRecorded(value:Date):void
        {
            _dateRecorded = value;
        }

        public function get dateSent():Date
        {
            return _dateSent;
        }

        public function set dateSent(value:Date):void
        {
            _dateSent = value;
        }
    }
}
