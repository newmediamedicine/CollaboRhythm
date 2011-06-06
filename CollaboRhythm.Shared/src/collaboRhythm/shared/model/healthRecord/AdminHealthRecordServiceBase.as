package collaboRhythm.shared.model.healthRecord {

    import collaboRhythm.shared.model.Account;

    import org.indivo.client.Admin;
    import org.indivo.client.IndivoClientEvent;

    public class AdminHealthRecordServiceBase extends HealthRecordServiceBase {

        protected var _admin:Admin;

        public function AdminHealthRecordServiceBase(oauthChromeConsumerKey:String, oauthChromeConsumerSecret:String, indivoServerBaseURL:String, account:Account) {
            super(oauthChromeConsumerKey, oauthChromeConsumerSecret, indivoServerBaseURL, account);

            _admin = new Admin(oauthChromeConsumerKey, oauthChromeConsumerSecret, indivoServerBaseURL);
            _admin.addEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
            _admin.addEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler)
        }

//        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//        {
//            _admin.dispatchEvent(new HealthRecordServiceEvent(healthRecordServiceRequestDetails.healthRecordServiceCompleteEventType, null, null, healthRecordServiceRequestDetails, responseXml));
//        }
//
//        protected override function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//        {
//            _admin.dispatchEvent(new HealthRecordServiceEvent(healthRecordServiceRequestDetails.healthRecordServiceErrorEventType, null, null, healthRecordServiceRequestDetails, null, errorStatus));
//        }
    }
}
