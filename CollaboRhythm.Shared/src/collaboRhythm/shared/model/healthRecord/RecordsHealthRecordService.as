package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import org.indivo.client.IndivoClientEvent;

    public class RecordsHealthRecordService extends PhaHealthRecordServiceBase
    {
        // Indivo Api calls used in this healthRecordService
        public static const GET_RECORDS:String = "Get Records";
        public static const GET_RECORD_OWNER:String = "Get Record Owner";

        // a counter to know when all of the get record own calls have completed
        private var _getRecordOwnersCount:int = 0;

        // TODO: Eliminate this hack once proper authentication has been completed
        private var _settings:Settings;

        public function RecordsHealthRecordService(oauthConsumerKey:String, oauthConsumerSecret:String,
                                                   indivoServerBaseURL:String, account:Account, settings:Settings)
        {
            super(oauthConsumerKey, oauthConsumerSecret, indivoServerBaseURL, account);
            _settings = settings;
        }

        // call to get all of the records associated with the account actively in session
        // will also get the account that owns each of the shared records
        public function getRecords():void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_RECORDS);
            _pha.accounts_X_records_GET(null, null, null, null, _activeAccount.accountId, _activeAccount.oauthAccountToken,
                                        _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            if (healthRecordServiceRequestDetails.indivoApiCall == GET_RECORDS)
            {
                getRecordsCompleteHandler(responseXml, event);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == GET_RECORD_OWNER)
            {
                getRecordOwnerCompleteHandler(responseXml, healthRecordServiceRequestDetails, event);
            }
        }

		protected override function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			return handleErrorForSingleRequest(event, errorStatus, healthRecordServiceRequestDetails);
		}

        // loop through all of the records and determine which is the primary record and which are shared records
        private function getRecordsCompleteHandler(responseXml:XML, indivoClientEvent:IndivoClientEvent):void
        {
            // used to avoid duplicate records in an account (such as when a record is shared via a full record share and one or more carenets)
            var _uniqueRecords:Vector.<String> = new Vector.<String>();
            
            for each (var recordXml:XML in responseXml.Record)
            {
                // error check to make sure that the record has an id
                if (recordXml.hasOwnProperty("@id"))
                {
                    // avoid duplicate records in an account (such as when a record is shared via a full record share and one or more carenets)
                    if (_uniqueRecords.indexOf(recordXml.@id) == -1)
                    {
                        _uniqueRecords.push(recordXml.@id);
                        var record:Record = new Record(recordXml);
                        // Keep track of all of the records as well as which are shares and which is the primary
                        // TODO: This assumes that there is only one record for an account that is not shared, check to make sure
                        if (record.shared)
                        {
                            // get the account that owns each of the shared records and keep a counter so that we know when all calls are complete
                            _getRecordOwnersCount += 1;
                            getRecordOwner(record);
                        }
                        else
                        {
                            // assumes that the record that is not shared is the primary record
                            // TODO: Make sure this is the case. Checking to see if the account owning the record matches will not work because an account can own multiple records
                            _activeAccount.primaryRecord = record;
                        }
                    }
                }
            }

            // if no records are shared with the account actively in session, then the service is complete
            if (_getRecordOwnersCount == 0)
            {
                dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, indivoClientEvent));
            }
        }

        // call to get the account that owns a record that is shared with the account actively in session
        private function getRecordOwner(record:Record):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_RECORD_OWNER, null, record);
            _pha.records_X_owner_GET(null, null, null, record.id, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
        }

        // handle the account that owns a record that is shared with the account actively in session
        // create the account for that owner and add it to a hasmap on the account actively in session
        private function getRecordOwnerCompleteHandler(responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails,
													   indivoClientEvent:IndivoClientEvent):void
        {
            // error check to make sure that account has an id
            if (responseXml.hasOwnProperty("@id"))
            {
                // create an account for the owner of the record
                var account:Account = new Account();
                account.accountId = responseXml.@id;

                // get the record from the request details
                var record:Record = healthRecordServiceRequestDetails.record;
                if (record == null)
                    throw new Error("event.userData must be a Record object");

                // set the record for the account
                account.primaryRecord = record;

                // add the shared record account to the active account
                _activeAccount.addSharedRecordAccount(account);
            }

            _getRecordOwnersCount -= 1;
            if (_getRecordOwnersCount == 0)
            {
                // when the owners of all of the accounts are handled, then the service is complete
                dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, indivoClientEvent));
            }
        }
    }
}
