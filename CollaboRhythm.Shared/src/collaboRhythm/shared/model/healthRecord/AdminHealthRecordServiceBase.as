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

		override protected function retryFailedRequest(event:IndivoClientEvent,
											  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_admin.adminRequest(event.relativePath, event.requestXml,
															 healthRecordServiceRequestDetails,
															 event.urlRequest.method);
		}
	}
}
