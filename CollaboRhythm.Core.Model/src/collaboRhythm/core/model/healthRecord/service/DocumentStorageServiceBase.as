package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.XmlMarshaller;
	import collaboRhythm.core.model.healthRecord.RelationshipXmlMarshaller;
	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import flash.events.Event;

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
		/**
		 * Event that is dispatched when the isLoading property changes.
		 */
		public static const IS_LOADING_CHANGE_EVENT:String = "isLoadingChange";
		private var _isLoading:Boolean;
		protected var _relationshipXmlMarshaller:RelationshipXmlMarshaller;
		protected var _xmlMarshaller:XmlMarshaller;
		protected var _targetDocumentType:String;
		protected var _targetClass:Class;
		protected var _targetDocumentSchema:Class;

		public function DocumentStorageServiceBase(consumerKey:String, consumerSecret:String, baseURL:String,
												   account:Account, targetDocumentType:String, targetClass:Class,
												   targetDocumentSchema:Class)
		{
			super(consumerKey, consumerSecret, baseURL, account);
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
			super.handleResponse(event, responseXml, healthRecordServiceRequestDetails);
			isLoading = false;
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
			_xmlMarshaller.addSchema(targetDocumentSchema);
			_xmlMarshaller.registerClass(targetDocumentQName, targetClass);
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
		protected function parseReportsXml(reportsXml:XML):ArrayCollection
		{
			var collection:ArrayCollection = new ArrayCollection();
			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			for each (var reportXml:XML in reportsXml.Report)
			{
				var document:IDocument = unmarshallReportXml(reportXml);
				if (document && documentShouldBeIncluded(document, nowTime))
				{
					DocumentMetadata.parseDocumentMetadata(reportXml.Meta.Document[0], document.meta);
					_relationshipXmlMarshaller.unmarshallRelationships(reportXml, document);
					unmarshallSpecialRelationships(reportXml, document);
					collection.addItem(document);
				}
			}

			_logger.info("Parsed " + collection.length + " " + targetDocumentType + " document" + (collection.length == 1 ? "" : "s") + " from report");
			return collection;
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
		 * Filter method to determine which documents should be included as part of the collection of documents in the
		 * model. Subclasses should override this method to ensure that changing the demo date will filter out "future"
		 * documents.
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
			_relationshipXmlMarshaller.record = null;
		}
	}
}
