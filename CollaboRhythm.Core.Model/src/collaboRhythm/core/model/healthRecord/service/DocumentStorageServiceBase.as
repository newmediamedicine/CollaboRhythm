package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.XmlMarshaller;
	import collaboRhythm.core.model.healthRecord.RelationshipXmlMarshaller;
	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.IDocumentCollection;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	import flash.events.Event;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	/**
	 * Event that is dispatched when the isLoading property changes.
	 */
	[Event("isLoadingChange")]

	/**
	 * Base class for implementing a document storage service, responsible for loading and persisting health record
	 * documents of a particular type (one service per type).
	 */
	public class DocumentStorageServiceBase extends PhaHealthRecordServiceBase
	{
		protected static const GET_REPORTS_MINIMAL:String = "reports_minimal_X_GET";

		/**
		 * Event that is dispatched when the isLoading property changes.
		 */
		public static const IS_LOADING_CHANGE_EVENT:String = "isLoadingChange";
		protected static const PRIMARY_REPORT_REQUEST:String = "primaryReport";

		private var _isLoading:Boolean;
		protected var _relationshipXmlMarshaller:RelationshipXmlMarshaller;
		protected var _xmlMarshaller:XmlMarshaller;
		protected var _targetDocumentType:String;
		protected var _targetClass:Class;
		protected var _targetDocumentSchema:Class;
		protected var _debuggingToolsEnabled:Boolean;
		protected var _pendingReportRequests:HashMap = new HashMap();

		protected var _pendingReplacedDocumentRequests:HashMap = new HashMap();

		private var _shouldLoadReplacedDocuments:Boolean;

		public function DocumentStorageServiceBase(consumerKey:String, consumerSecret:String, baseURL:String,
												   account:Account,
												   debuggingToolsEnabled:Boolean, targetDocumentType:String,
												   targetClass:Class, targetDocumentSchema:Class)
		{
			super(consumerKey, consumerSecret, baseURL, account);
			_debuggingToolsEnabled = debuggingToolsEnabled;
			_targetDocumentType = targetDocumentType;
			_targetClass = targetClass;
			_targetDocumentSchema = targetDocumentSchema;
			initializeXmlMarshaller();
		}

		[Bindable(event="isLoadingChange")]
		public function get isLoading():Boolean
		{
			return _isLoading;
		}

		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
			dispatchEvent(new Event(IS_LOADING_CHANGE_EVENT));
		}

		/**
		 * Loads all documents of the type supported by this service into the specified record.
		 * Subclasses should override and extend this to implement loading of the particular document type supported.
		 *
		 * @param record the record in which to load documents
		 */
		public function loadDocuments(record:Record):void
		{
			isLoading = true;
			_relationshipXmlMarshaller = new RelationshipXmlMarshaller();
			_relationshipXmlMarshaller.record = record;
		}

		override protected function handleResponse(event:IndivoClientEvent, responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var requestDetails:HealthRecordServiceRequestDetails = event.userData as HealthRecordServiceRequestDetails;
			if (requestDetails == null)
				throw new Error("userData must be a HealthRecordServiceRequestDetails object");

			var record:Record = requestDetails.record;
			if (record == null)
				throw new Error("userData.record must be a Record object");

			if (requestDetails.indivoApiCall == GET_REPORTS_MINIMAL)
			{
				handleReportResponse(event, responseXml, healthRecordServiceRequestDetails);
			}
			else if (requestDetails.indivoApiCall == GET_DOCUMENT)
			{
				handleGetDocument(responseXml, record, healthRecordServiceRequestDetails);
			}
			else if (requestDetails.indivoApiCall == GET_METADATA)
			{
				var document:IDocument = healthRecordServiceRequestDetails.document;
				if (document)
				{
					DocumentMetadata.parseDocumentMetadata(responseXml, document.meta);
					_relationshipXmlMarshaller.unmarshallRelationshipsFromMetadata(responseXml, document);
					unmarshallSpecialRelationships(responseXml, document);
					record.addDocument(document);
					loadReplacedDocuments(record, document);
				}
			}
			checkPendingRequests(record);
		}

		protected function handleReportResponse(event:IndivoClientEvent, responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{

		}

		protected function handleGetDocument(responseXml:XML, record:Record,
											 previousHealthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):IDocument
		{
			var document:IDocument = unmarshallDocumentXml(responseXml);
			document.meta.id = previousHealthRecordServiceRequestDetails.customData as String;

			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_METADATA, null, record);
			healthRecordServiceRequestDetails.document = document;
			_pha.documents_X_metaGET(null, null, null, record.id, document.meta.id,
									 _activeAccount.oauthAccountToken,
									 _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
			return document;
		}

		override protected function handleError(event:IndivoClientEvent, errorStatus:String,
												healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			var isRetrying:Boolean = super.handleError(event, errorStatus, healthRecordServiceRequestDetails);
			if (!isRetrying)
				isLoading = false;
			return isRetrying;
		}

		/**
		 * The document type that this service targets.
		 */
		public function get targetDocumentType():String
		{
			return _targetDocumentType;
		}

		/**
		 * The XML QName (qualified name) of the XML representation of the document that this service targets.
		 */
		protected function get targetDocumentQName():QName
		{
			var parts:Array = targetDocumentType.split("#");
			return new QName(parts[0] + "#", parts[1]);
		}

		/**
		 * The document class that this service targets.
		 */
		protected function get targetClass():Class
		{
			return _targetClass;
		}

		/**
		 * Returns the embedded schema for the document type that this service targets.
		 */
		protected function get targetDocumentSchema():Class
		{
			return _targetDocumentSchema;
		}

		/**
		 * Initializes the XmlMarshaller used by this service for marshalling and unmarshalling the document type
		 * that this service targets.
		 */
		protected function initializeXmlMarshaller():void
		{
			_xmlMarshaller = new XmlMarshaller();
			_xmlMarshaller.addSchema(Schemas.CodedValuesSchema);
			_xmlMarshaller.addSchema(Schemas.ValuesSchema);
			if (targetDocumentSchema)
			{
				_xmlMarshaller.addSchema(targetDocumentSchema);
			}
			if (targetDocumentType && targetDocumentQName && targetClass)
			{
				_xmlMarshaller.registerClass(targetDocumentQName, targetClass);
			}
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "CodedValue"), CodedValue);
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "ValueAndUnit"),
										 ValueAndUnit);
		}

		/**
		 * Uses xmlMarshaller to unmarshall the XML for each document in the reports. The metadata and relationships
		 * are also unmarshalled.
		 * @param reportsXml
		 * @return
		 */
		protected function parseReportsXml(record:Record, reportsXml:XML):ArrayCollection
		{
			var collection:ArrayCollection = new ArrayCollection();
			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			var numDocuments:int = reportsXml.Report.length();
			for each (var reportXml:XML in reportsXml.Report)
			{
				var document:IDocument = unmarshallReportXml(reportXml);
				DocumentMetadata.parseDocumentMetadata(reportXml.Meta.Document[0], document.meta);
				loadReplacedDocuments(record, document);
				if (document && documentShouldBeIncludedTestSettings(document, nowTime))
				{
					_relationshipXmlMarshaller.unmarshallRelationships(reportXml, document);
					unmarshallSpecialRelationships(reportXml, document);
					collection.addItem(document);
				}
			}
			logParsedReportDocuments(collection, numDocuments);
			return collection;
		}

		protected function logParsedReportDocuments(collection:ArrayCollection, numDocuments:int):void
		{
			var numDocumentsFiltered:Number = numDocuments - collection.length;
			var filteredClause:String = numDocumentsFiltered > 0 ? (" (" + (numDocumentsFiltered) + " document" +
					(numDocumentsFiltered == 1 ? "" : "s") + " filtered out)") : "";
			var ofTotalClause:String = numDocumentsFiltered > 0 ? (" of " + numDocuments) : "";
			_logger.info("Parsed " + collection.length + ofTotalClause + " " + targetDocumentType +
					" document" + (collection.length == 1 ? "" : "s") + " from report" + filteredClause);
		}

		public function marshallToXml(document:IDocument):String
		{
			return _xmlMarshaller.marshallToXml(targetDocumentQName, document);
		}

		public function unmarshallReportXml(reportXml:XML):IDocument
		{
			var element:XML = reportXml.Item.elements(targetDocumentQName)[0];
			return element ? (unmarshallDocumentXml(element)) : null;
		}

		public function unmarshallDocumentXml(documentXml:XML):IDocument
		{
			return _xmlMarshaller.unmarshallXml(documentXml, targetDocumentQName) as IDocument;
		}

		protected function unmarshallSpecialRelationships(reportXml:XML, document:IDocument):void
		{
			// optionally override in subclasses
		}

		/**
		 * Method to determine which documents should be included as part of the collection of document of documents
		 * in the model. It first determines if the setting debuggingToolsEnabled is true, if so, then the document
		 * is included. If false, then documentShouldBeIncluded, which is overridden by subclasses makes the
		 * determination.
		 * @param document the document to filter
		 * @param nowTime the demo time ("current" time) as a Number value
		 * @return true if the document should be included; otherwise false
		 */
		private function documentShouldBeIncludedTestSettings(document:IDocument, nowTime:Number):Boolean
		{
			if (!_debuggingToolsEnabled)
			{
				return true;
			}
			else
			{
				return documentShouldBeIncluded(document, nowTime);
			}
		}

		/**
		 * Filter method to determine which documents should be included as part of the collection of documents in the
		 * model. Subclasses should override this method to ensure that changing the demo date will filter out "future"
		 * documents. It is only called when the setting debuggingToolsEnabled is true.
		 * @param document the document to filter
		 * @param nowTime the demo time ("current" time) as a Number value
		 * @return true if the document should be included; otherwise false
		 */
		protected function documentShouldBeIncluded(document:IDocument, nowTime:Number):Boolean
		{
			return true;
		}

		public function closeRecord():void
		{
			activeAccount = null;
			if (_relationshipXmlMarshaller)
				_relationshipXmlMarshaller.record = null;
		}

		protected function loadReplacedDocuments(record:Record, document:IDocument):void
		{
			if (shouldLoadReplacedDocuments)
			{
				if (document.meta.replacesId)
				{
					var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_DOCUMENT,
																																	null,
																																	record);
					healthRecordServiceRequestDetails.customData = document.meta.replacesId;
					_pha.documents_XGET(null, null, null, record.id, document.meta.replacesId,
										_activeAccount.oauthAccountToken,
										_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
					updatePendingReplacedDocumentRequest(document);
				}
				else
				{
					removePendingReplacedDocumentRequest(document);
				}
				checkPendingRequests(record);
			}
		}

		private function removePendingReplacedDocumentRequest(document:IDocument):void
		{
			if (_pendingReplacedDocumentRequests.getItem(document.meta.originalId) != null)
			{
				_pendingReplacedDocumentRequests.remove(document.meta.originalId);
			}
		}

		private function updatePendingReplacedDocumentRequest(document:IDocument):void
		{
			if (_pendingReplacedDocumentRequests.getItem(document.meta.originalId) == null)
			{
				_pendingReplacedDocumentRequests.put(document.meta.originalId, document.meta.originalId);
			}
		}

		public function get shouldLoadReplacedDocuments():Boolean
		{
			return _shouldLoadReplacedDocuments;
		}

		public function set shouldLoadReplacedDocuments(value:Boolean):void
		{
			_shouldLoadReplacedDocuments = value;
		}

		protected function checkPendingRequests(record:Record):void
		{
			if (numPendingRequests == 0)
				finishLoading(record);
		}

		protected function get numPendingRequests():int
		{
			return _pendingReportRequests.size() + _pendingReplacedDocumentRequests.size();
		}

		private function finishLoading(record:Record):void
		{
			var documentCollection:IDocumentCollection = record.documentCollections.getItem(targetDocumentType);
			if (documentCollection == null)
				throw new Error("Failed to get the document collection for document type " + targetDocumentType);

			documentCollection.isInitialized = true;

			isLoading = false;
			dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
		}
	}
}
