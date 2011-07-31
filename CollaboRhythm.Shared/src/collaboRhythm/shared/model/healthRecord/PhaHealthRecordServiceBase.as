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
        public static const UPDATE_DOCUMENT:String = "Update Document";
        public static const DELETE_DOCUMENT:String = "Delete Document";
        public static const VOID_DOCUMENT:String = "Void Document";
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

        public function createDocument(record:Record, document:IDocument, documentXmlString:String):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(CREATE_DOCUMENT,
                                                                                                                            null,
                                                                                                                            record);
			healthRecordServiceRequestDetails.document = document;
            _pha.documents_POST(null, null, null, record.id, _activeAccount.oauthAccountToken,
                                _activeAccount.oauthAccountTokenSecret, documentXmlString, healthRecordServiceRequestDetails);
        }

        public function updateDocument(record:Record, document:IDocument, documentXmlString:String):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(UPDATE_DOCUMENT,
                                                                                                                            null,
                                                                                                                            record);
			healthRecordServiceRequestDetails.document = document;
            _pha.documents_X_replacePOST(null, null, null, record.id, document.meta.id, _activeAccount.oauthAccountToken,
                                _activeAccount.oauthAccountTokenSecret, documentXmlString, healthRecordServiceRequestDetails);
        }

        public function archiveDocument(record:Record, document:IDocument, reason:String):void
        {
			setDocumentStatus(record, document, reason, "archived", ARCHIVE_DOCUMENT);
		}

		public function voidDocument(record:Record, document:IDocument, reason:String):void
		{
			setDocumentStatus(record, document, reason, "void", VOID_DOCUMENT);
		}

		public function deleteDocument(record:Record, document:IDocument):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(DELETE_DOCUMENT,
																															null,
																															record);
			healthRecordServiceRequestDetails.document = document;
			_pha.documents_XDELETE(null, null, null, record.id, document.meta.id, _activeAccount.oauthAccountToken,
										   _activeAccount.oauthAccountTokenSecret,
										   healthRecordServiceRequestDetails);
		}

		private function setDocumentStatus(record:Record, document:IDocument, reason:String, status:String,
										   indivoApiCall:String):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(indivoApiCall,
																															null,
																															record);
			healthRecordServiceRequestDetails.document = document;
			var formUrlEncoded:String = "reason=" + reason + "&status=" + status;
			_pha.documents_X_setStatusPOST(null, null, null, record.id, document.meta.id, _activeAccount.oauthAccountToken,
										   _activeAccount.oauthAccountTokenSecret, formUrlEncoded,
										   healthRecordServiceRequestDetails);
		}

        public function relateDocuments(record:Record, relationship:Relationship):void
        {
            var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(RELATE_DOCUMENTS,
                                                                                                                            null,
                                                                                                                            record);
			healthRecordServiceRequestDetails.customData = relationship;
            _pha.documents_X_rels_X_XPUT(null, null, null, record.id, relationship.relatesFrom.meta.id, relationship.shortType, relationship.relatesTo.meta.id,
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
                createDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
            if (healthRecordServiceRequestDetails.indivoApiCall == UPDATE_DOCUMENT)
            {
                updateDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == DELETE_DOCUMENT)
            {
                deleteDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == ARCHIVE_DOCUMENT)
            {
                archiveDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == VOID_DOCUMENT)
            {
                voidDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == RELATE_NEW_DOCUMENT)
            {
                relateNewDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
            else if (healthRecordServiceRequestDetails.indivoApiCall == RELATE_DOCUMENTS)
            {
                relateDocumentsCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
            }
        }

		protected function deleteDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
														 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Delete document COMPLETE");
		}

        protected function createDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
														 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
			_logger.info("Create document COMPLETE " + responseXml.@id + " " + responseXml.@type);
            dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, null, null, healthRecordServiceRequestDetails, responseXml));
        }

        protected function updateDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
														 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _logger.info("Update document COMPLETE " + responseXml.@id + " " + responseXml.@type);
            dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, null, null, healthRecordServiceRequestDetails, responseXml));
        }

        protected function archiveDocumentCompleteHandler(event:IndivoClientEvent,
														  responseXml:XML,
														  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _logger.info("Archive document COMPLETE");
        }

        protected function voidDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
													   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _logger.info("Void document COMPLETE");
        }

        protected function relateNewDocumentCompleteHandler(event:IndivoClientEvent,
															responseXml:XML,
															healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _logger.info("Relate new document COMPLETE");
        }

        protected function relateDocumentsCompleteHandler(event:IndivoClientEvent,
														  responseXml:XML,
														  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
        {
            _logger.info("Relate documents COMPLETE");
        }

		override protected function retryFailedRequest(event:IndivoClientEvent,
											  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_pha.phaRequest(null, null, null, event.urlRequest.method, event.relativePath,
							_activeAccount.oauthAccountToken,
							_activeAccount.oauthAccountTokenSecret, event.requestXml, event.params,
							healthRecordServiceRequestDetails);
		}
    }
}
