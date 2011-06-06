package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;
    import collaboRhythm.shared.model.VideoMessage;

    import org.indivo.client.IndivoClientEvent;

    public class VideoMessagesHealthRecordService extends PhaHealthRecordServiceBase
    {
        // Indivo Api calls used in this healthRecordService
        public static const GET_VIDEOMESSAGES_REPORT:String = "Get VideoMessages Report";
        public static const POST_DOCUMENT:String = "Post Document";

        public function VideoMessagesHealthRecordService(oauthConsumerKey:String, oauthConsumerSecret:String,
                                                   indivoServerBaseURL:String, account:Account)
        {
            super(oauthConsumerKey, oauthConsumerSecret, indivoServerBaseURL, account);
        }

        public function getVideoMessages(record:Record):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_VIDEOMESSAGES_REPORT, null, record);
            _pha.reports_minimal_X_GET(null, null, null, null, record.id, "videomessages", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        public function postVideoMessage(record:Record,  videoMessage:VideoMessage):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(POST_DOCUMENT, null, record);
            _pha.documents_POST(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, videoMessage.convertToXML(), healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            if (healthRecordServiceRequestDetails.indivoApiCall == GET_VIDEOMESSAGES_REPORT)
            {
                healthRecordServiceRequestDetails.record.videoMessagesModel.videoMessagesReportXml = responseXml;
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == POST_DOCUMENT)
            {
                // TODO: Handle the circumstance that the videoMessage document fails to upload
            }
        }
    }
}
