package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;

    import mx.utils.URLUtil;

    import org.indivo.client.IndivoClientEvent;

    public class CreateSessionHealthRecordService extends AdminHealthRecordServiceBase
    {

        public function CreateSessionHealthRecordService(oauthChromeConsumerKey:String,
                                                         oauthChromeConsumerSecret:String, indivoServerBaseURL:String,
                                                         account:Account)
        {
            super(oauthChromeConsumerKey, oauthChromeConsumerSecret, indivoServerBaseURL, account);
        }

        public function createSession(username:String, password:String):void
        {
            _admin.create_session(username, password, new HealthRecordServiceRequestDetails("Create Session"));
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            var responseText:String = responseXml.toString();
            var appInfo:Object = URLUtil.stringToObject(responseText, "&");
            _activeAccount.accountId = appInfo["account_id"];
            _activeAccount.oauthAccountToken = appInfo["oauth_token"];
            _activeAccount.oauthAccountTokenSecret = appInfo["oauth_token_secret"];

            dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
        }

        protected override function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
        {
            if (super.handleError(event, errorStatus, healthRecordServiceRequestDetails))
			{
				return true;
			}
			else
			{
				dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.ERROR, null, null, null, null, errorStatus));
				return false;
			}
        }
    }
}
