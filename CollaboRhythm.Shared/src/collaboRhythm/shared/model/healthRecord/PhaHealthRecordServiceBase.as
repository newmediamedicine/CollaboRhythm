package collaboRhythm.shared.model.healthRecord
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.Record;

    import org.indivo.client.IndivoClientEvent;
    import org.indivo.client.Pha;

    public class PhaHealthRecordServiceBase extends HealthRecordServiceBase
    {
        protected var _pha:Pha;

        // Indivo Api calls used in this healthRecordService
        public static const CREATE_DOCUMENT:String = "Create Document";
        public static const ARCHIVE_DOCUMENT:String = "Archive Document";
        public static const RELATE_DOCUMENTS:String = "Relate Documents";
        public static const RELATE_NEW_DOCUMENT:String = "Relate New Document";

        public function PhaHealthRecordServiceBase(oauthPhaConsumerKey:String, oauthPhaConsumerSecret:String,
                                                   indivoServerBaseURL:String, account:Account)
        {
            super(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL, account);

            _pha = new Pha(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL);
            _pha.addEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
            _pha.addEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler)
        }

        public function createDocument(record:Record, document:XML):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(CREATE_DOCUMENT,
                                                                                                                            null,
                                                                                                                            record);
            _pha.documents_POST(null, null, null, record.id, _activeAccount.oauthAccountToken,
                                _activeAccount.oauthAccountTokenSecret, document, healthRecordServiceRequestDetails);
        }

        public function archiveDocument(record:Record, documentId:String, reason:String):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(ARCHIVE_DOCUMENT,
                                                                                                                            null,
                                                                                                                            record);
            var formUrlEncoded:String = "reason=" + reason + "&status=archived";
            _pha.documents_X_setStatusPOST(null, null, null, record.id, documentId, _activeAccount.oauthAccountToken,
                                           _activeAccount.oauthAccountTokenSecret, formUrlEncoded,
                                           healthRecordServiceRequestDetails);
        }

        public function relateDocuments(record:Record, documentId:String, otherDocumentId:String, relType:String):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(RELATE_DOCUMENTS,
                                                                                                                            null,
                                                                                                                            record);
            _pha.documents_X_rels_X_XPUT(null, null, null, record.id, documentId, relType, otherDocumentId,
                                         _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret,
                                         healthRecordServiceRequestDetails);
        }

        public function relateNewDocument(record:Record, documentId:String, otherDocument:XML, relType:String):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(RELATE_NEW_DOCUMENT,
                                                                                                                            null,
                                                                                                                            record);
            _pha.documents_X_rels_X_POST(null, null, null, record.id, documentId, relType,
                                         _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret,
                                         otherDocument, healthRecordServiceRequestDetails);
        }

        protected override function handleResponse(event:IndivoClientEvent, responseXml:XML,
                                                   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            if (healthRecordServiceRequestDetails.indivoApiCall == CREATE_DOCUMENT)
            {
                createDocumentCompleteHandler(responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == ARCHIVE_DOCUMENT)
            {
                archiveDocumentCompleteHandler(responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == RELATE_NEW_DOCUMENT)
            {
                relateNewDocumentCompleteHandler(responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == RELATE_DOCUMENTS)
            {
                relateDocumentsCompleteHandler(responseXml, healthRecordServiceRequestDetails);
            }
        }

        private function createDocumentCompleteHandler(responseXml:XML,
                                                       healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            trace("creating document - SUCCEEDED");
            dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, null, null, null, responseXml));
        }

        private function archiveDocumentCompleteHandler(responseXml:XML,
                                                        healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            trace("creating document - SUCCEEDED");
        }

        private function relateNewDocumentCompleteHandler(responseXml:XML,
                                                        healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            trace("relating new document - SUCCEEDED");
        }

        private function relateDocumentsCompleteHandler(responseXml:XML,
                                                        healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            trace("relating documents - SUCCEEDED");
        }

        protected override function handleError(event:IndivoClientEvent, errorStatus:String,
                                                healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _logger.info("Unhandled IndivoClientEvent error: " + errorStatus);
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
//        		private function addPendingRequest(requestType:String, id:String):void
//		{
//			var key:String = getPendingRequestKey(requestType, id);
//			if (_pendingRequests.keys.contains(key))
//			{
//				throw new Error("request with matching key is already pending: " + key);
//			}
//
//			_pendingRequests.put(key, key);
//		}
//
//		private function removePendingRequest(requestType:String, id:String):void
//		{
//			var key:String = getPendingRequestKey(requestType, id);
//			if (_pendingRequests.keys.contains(key))
//			{
//				_pendingRequests.remove(key);
//				if (_pendingRequests.size() == 0)
//					this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
//			}
//		}
//
//		private function getPendingRequestKey(requestType:String, id:String):String
//		{
//			return requestType + " " + id;
//		}

    }
}
