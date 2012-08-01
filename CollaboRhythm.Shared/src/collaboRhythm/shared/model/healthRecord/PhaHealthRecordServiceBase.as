package collaboRhythm.shared.model.healthRecord
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.StringUtils;
	import collaboRhythm.shared.model.healthRecord.document.Message;

	import org.indivo.client.IndivoClientEvent;
	import org.indivo.client.Pha;

	public class PhaHealthRecordServiceBase extends HealthRecordServiceBase
	{
		protected var _pha:Pha;

		/**
		 * App id (PHA) used for all document creation calls. This app must exist in the database. As long as we are
		 * using a chrome app to make the API call, we don't actually need to have the app associated with the current
		 * record in order for this call to succeed.
		 */
		private static const INDIVO_APP_ID_FOR_DOCUMENT_CREATION:String = "medications@apps.indivo.org";

		// Indivo Api calls used in this healthRecordService
		public static const GET_DOCUMENT:String = "Get Document";
		public static const GET_METADATA:String = "Get Metadata";
		public static const CREATE_DOCUMENT:String = "Create Document";
		public static const UPDATE_DOCUMENT:String = "Update Document";
		public static const DELETE_DOCUMENT:String = "Delete Document";
		public static const VOID_DOCUMENT:String = "Void Document";
		public static const ARCHIVE_DOCUMENT:String = "Archive Document";
		public static const RELATE_DOCUMENTS:String = "Relate Documents";
		public static const RELATE_NEW_DOCUMENT:String = "Relate New Document";
		public static const GET_MESSAGE:String = "Get Message";
		public static const SEND_MESSAGE:String = "Send Message";

		public function PhaHealthRecordServiceBase(oauthPhaConsumerKey:String, oauthPhaConsumerSecret:String,
												   indivoServerBaseURL:String, account:Account)
		{
			super(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL, account);

			if (oauthPhaConsumerKey && oauthPhaConsumerSecret && indivoServerBaseURL)
			{
				_pha = new Pha(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL);
				_pha.addEventListener(IndivoClientEvent.COMPLETE, indivoClientEventHandler);
				_pha.addEventListener(IndivoClientEvent.ERROR, indivoClientEventHandler)
			}
		}

		public function createDocument(record:Record, document:IDocument, documentXmlString:String):void
		{
			if (StringUtils.isEmpty(document.meta.id))
				throw new Error("Document must have an id before attempting to create it. The initial id is used as the external id and then the id is later updated with the real document id.");

			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(CREATE_DOCUMENT,
					null, record);
			healthRecordServiceRequestDetails.document = document;

			// Use an external id to avoid creating duplicates. It appears that occasionally the Indivo server will
			// return a failure code (403 I believe) even though the document was created successfully. Retrying the
			// request without using an external id will result in a duplicate document being created.
//            _pha.documents_external_X_XPUT(null, null, null, record.id, INDIVO_APP_ID_FOR_DOCUMENT_CREATION, document.meta.id, _activeAccount.oauthAccountToken,
//                                _activeAccount.oauthAccountTokenSecret, documentXmlString, healthRecordServiceRequestDetails);

			// TODO: figure out why external id is not working on new Indivo server (version 1.0); currently we are not using the external id, which could potentially result in duplicate documents being created
			_pha.documents_POST(null, null, null, record.id, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, documentXmlString, healthRecordServiceRequestDetails);
		}

		public function updateDocument(record:Record, document:IDocument, documentXmlString:String):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(UPDATE_DOCUMENT,
					null, record);
			healthRecordServiceRequestDetails.document = document;
			_pha.documents_X_replacePOST(null, null, null, record.id, document.meta.id,
					_activeAccount.oauthAccountToken,
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
					null, record);
			healthRecordServiceRequestDetails.document = document;
			_pha.documents_XDELETE(null, null, null, record.id, document.meta.id, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret,
					healthRecordServiceRequestDetails);
		}

		private function setDocumentStatus(record:Record, document:IDocument, reason:String, status:String,
										   indivoApiCall:String):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(indivoApiCall,
					null, record);
			healthRecordServiceRequestDetails.document = document;
			var formUrlEncoded:String = "reason=" + reason + "&status=" + status;
			_pha.documents_X_setStatusPOST(null, null, null, record.id, document.meta.id,
					_activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, formUrlEncoded,
					healthRecordServiceRequestDetails);
		}

		public function relateDocuments(record:Record, relationship:Relationship):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(RELATE_DOCUMENTS,
					null, record);
			healthRecordServiceRequestDetails.customData = relationship;
			_pha.documents_X_rels_X_XPUT(null, null, null, record.id, relationship.relatesFrom.meta.id,
					relationship.shortType, relationship.relatesTo.meta.id,
					_activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret,
					healthRecordServiceRequestDetails);
		}

		public function relateNewDocument(record:Record, documentId:String, otherDocument:XML, relType:String):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(RELATE_NEW_DOCUMENT,
					null, record);
			_pha.documents_X_rels_X_POST(null, null, null, record.id, documentId, relType,
					_activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret,
					otherDocument, healthRecordServiceRequestDetails);
		}

		public function getMessage(accountId:String, message:Message):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MESSAGE,
					null, null, null, null, message);
			_pha.accounts_X_inbox_XGET(null, null, null, accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, message.id, healthRecordServiceRequestDetails);
		}

		public function getSentMessage(accountId:String, message:Message):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_MESSAGE,
					null, null, null, null, message);
			_pha.accounts_X_sent_XGET(null, null, null, accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, message.id, healthRecordServiceRequestDetails);
		}

		public function sendMessage(accountId:String, requestXml:String, message:Message):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(SEND_MESSAGE,
					null, null, null, null, message);
			_pha.accounts_X_sendPOST(requestXml, null, null, null, accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
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
			else if (healthRecordServiceRequestDetails.indivoApiCall == GET_MESSAGE)
			{
				getMessageCompleteHandler(responseXml, healthRecordServiceRequestDetails);
			}
			else if (healthRecordServiceRequestDetails.indivoApiCall == SEND_MESSAGE)
			{
				sendMessageCompleteHandler(responseXml, healthRecordServiceRequestDetails);
			}
		}

		override protected  function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			if (healthRecordServiceRequestDetails.indivoApiCall == SEND_MESSAGE)
			{
				sendMessageErrorHandler(errorStatus, healthRecordServiceRequestDetails);
			}

			return defaultHandleError(event, healthRecordServiceRequestDetails);
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
			dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, event, null,
					healthRecordServiceRequestDetails, responseXml));
		}

		protected function updateDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
														 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Update document COMPLETE " + responseXml.@id + " " + responseXml.@type);
			dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, event, null,
					healthRecordServiceRequestDetails, responseXml));
		}

		protected function archiveDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
														  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Archive document COMPLETE");
		}

		protected function voidDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
													   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Void document COMPLETE");
		}

		protected function relateNewDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
															healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Relate new document COMPLETE");
		}

		protected function relateDocumentsCompleteHandler(event:IndivoClientEvent, responseXml:XML,
														  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Relate documents COMPLETE");
		}

		protected function getMessageCompleteHandler(responseXml:XML,
													 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Get message COMPLETE");
		}

		protected function sendMessageCompleteHandler(responseXml:XML,
													healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Send message COMPLETE");
		}


		protected function sendMessageErrorHandler(errorStatus:String,
												healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			_logger.info("Send message ERROR");
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
