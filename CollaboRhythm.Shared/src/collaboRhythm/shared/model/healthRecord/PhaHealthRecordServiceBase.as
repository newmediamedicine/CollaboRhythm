package collaboRhythm.shared.model.healthRecord
{
    import collaboRhythm.shared.model.Account;

    import org.indivo.client.IndivoClientEvent;
    import org.indivo.client.Pha;

    public class PhaHealthRecordServiceBase extends HealthRecordServiceBase
    {
        protected var _pha:Pha;

        public function PhaHealthRecordServiceBase(oauthPhaConsumerKey:String, oauthPhaConsumerSecret:String,
                                                   indivoServerBaseURL:String, account:Account)
        {
            super(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL, account);

            _pha = new Pha(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL);
            _pha.addEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
            _pha.addEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler)
        }

//        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//        {
//            _pha.dispatchEvent(new HealthRecordServiceEvent(healthRecordServiceRequestDetails.healthRecordServiceCompleteEventType, null, null, healthRecordServiceRequestDetails, responseXml));
//        }
//
//        protected override function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//        {
//            _pha.dispatchEvent(new HealthRecordServiceEvent(healthRecordServiceRequestDetails.healthRecordServiceErrorEventType, null, null, healthRecordServiceRequestDetails, null, errorStatus));
//        }
    }
}
