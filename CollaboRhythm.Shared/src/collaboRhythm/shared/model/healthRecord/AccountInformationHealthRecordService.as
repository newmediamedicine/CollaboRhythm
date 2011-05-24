package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;

    import org.indivo.client.IndivoClientEvent;

    public class AccountInformationHealthRecordService extends AdminHealthRecordServiceBase
    {

        public function AccountInformationHealthRecordService(adminConsumerKey:String, adminConsumerSecret:String,
                                                              indivoServerBaseURL:String, account:Account)
        {
            super(adminConsumerKey, adminConsumerSecret, indivoServerBaseURL, account);
        }

        public function retrieveAccountInformation(account:Account):void
        {
            _admin.addEventListener(IndivoClientEvent.COMPLETE, retrieveAccountInformationCompleteHandler);
            _admin.addEventListener(IndivoClientEvent.ERROR, retrieveAccountInformationErrorHandler);
            _admin.accounts_XGET(account.accountId)
        }

        private function retrieveAccountInformationCompleteHandler(event:IndivoClientEvent):void
        {
            var responseXml:XML = event.response;
            // if credentials get implemented for accounts, they could be read here and set for the account
        }

        private function retrieveAccountInformationErrorHandler(event:IndivoClientEvent):void
        {
//            _logger.info("Unhandled IndivoClientEvent error: " + parseErrorStatus(event));
        }
    }
}
