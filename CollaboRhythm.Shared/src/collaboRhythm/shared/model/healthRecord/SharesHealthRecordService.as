package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;

    import org.indivo.client.IndivoClientEvent;

    public class SharesHealthRecordService extends PhaHealthRecordServiceBase
    {
        public function SharesHealthRecordService(oauthConsumerKey:String, oauthConsumerSecret:String,
                                                  indivoServerBaseURL:String, account:Account)
        {
            super(oauthConsumerKey, oauthConsumerSecret, indivoServerBaseURL, account);
        }

        // call to get all of the records with which the primary record is shared
        public function getShares(primaryRecord:Record):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(null,
                                                                                                                            null,
                                                                                                                            primaryRecord);
            _pha.shares_GET(null, null, null, null, primaryRecord.id, _activeAccount.oauthAccountToken,
                            _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        // loop through all of the records with which the primary record is shared
        // Get or create the account that owns each of those records and add it to a hasmap on the account actively in session
        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            for each (var shareXml:XML in responseXml.Share)
            {
                if (shareXml.hasOwnProperty("@account"))
                {
                    var account:Account;
                    // check to see if an account already exists for the owner with whom the record was shared
                    // this would happen if that owner had also shared a record with the primary account
                    if (_activeAccount.sharedRecordAccounts.hasOwnProperty(shareXml.@account))
                    {
                        // if the account already exists in the sharedRecordAccounts, get it
                        account = _activeAccount.sharedRecordAccounts[shareXml.@account];
                    }
                    else
                    {
                        // otherwise create an account for the owner with which the record is shared
                        // we don't care if that account has a record, since the owner is not sharing the record with the primary account
                        account = new Account();
                        account.accountId = shareXml.@account;
                    }

                    // add the record share account to the active account
                    _activeAccount.addRecordShareAccount(account);
                }
            }

            // dispatch an event to indicate that the record shares have been retrieved
            dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
        }
    }
}
