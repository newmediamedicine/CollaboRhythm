package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Contact;
    import collaboRhythm.shared.model.Demographics;
    import collaboRhythm.shared.model.Record;

    import org.indivo.client.IndivoClientEvent;

    public class DemographicsHealthRecordService extends PhaHealthRecordServiceBase
    {
         // Indivo Api calls used in this healthRecordService
        public static const GET_DEMOGRAPHICS:String = "Get Demographics";
        public static const GET_CONTACT:String = "Get Contact";

        public function DemographicsHealthRecordService(oauthChromeConsumerKey:String,
                                                         oauthChromeConsumerSecret:String, indivoServerBaseURL:String,
                                                         account:Account)
        {
            super(oauthChromeConsumerKey, oauthChromeConsumerSecret, indivoServerBaseURL, account);
        }

        // get the demographics for a record
        public function getDemographics(record:Record):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_DEMOGRAPHICS, null, record);
            _pha.special_demographicsGET(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
            healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_CONTACT, null, record);
            _pha.special_contactGET(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            if (healthRecordServiceRequestDetails.indivoApiCall == GET_DEMOGRAPHICS)
                healthRecordServiceRequestDetails.record.demographics = new Demographics(responseXml);
            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_CONTACT)
                healthRecordServiceRequestDetails.record.contact = new Contact(responseXml);
        }
    }
}
