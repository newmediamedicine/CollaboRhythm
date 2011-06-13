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
        public static const SET_STATUS:String = "Set Status";

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

        public function postVideoMessage(record:Record, videoMessage:VideoMessage):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(POST_DOCUMENT, null, record);
            _pha.documents_POST(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, videoMessage.convertToXML(), healthRecordServiceRequestDetails);
        }

        public function deleteVideoMessage(record:Record, videoMessage:VideoMessage):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(POST_DOCUMENT, null, record);
            _pha.documents_X_setStatusPOST(null, null, null, record.id, videoMessage.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, "reason=deleted&status=archived", healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            if (healthRecordServiceRequestDetails.indivoApiCall == GET_VIDEOMESSAGES_REPORT)
            {
                healthRecordServiceRequestDetails.record.videoMessagesModel.videoMessagesReportXml = responseXml;
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == POST_DOCUMENT)
            {
                // TODO: Handle the event that the videoMessage document fails to upload
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == SET_STATUS)
            {
                // TODO: Handle the event that changing the status fails
            }
        }
    }
}
