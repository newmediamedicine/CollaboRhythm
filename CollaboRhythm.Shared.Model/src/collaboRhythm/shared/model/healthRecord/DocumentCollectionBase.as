package collaboRhythm.shared.model.healthRecord
{

	import mx.collections.ArrayCollection;

	/**
	 * Base class for a model class that manages a collection of documents of a specific type on a health record.
	 * There should generally be one subclass of DocumentCollectionBase for each type of document.
	 */
	[Bindable]
	public class DocumentCollectionBase implements IDocumentCollection
	{
		private var _documents:ArrayCollection = new ArrayCollection();
		private var _documentType:String;
		private var _isStitched:Boolean;
		private var _isInitialized:Boolean = false;
		private var _recordProxy:IRecordProxy;

		public function DocumentCollectionBase(documentType:String)
		{
			_documentType = documentType;
		}

		/**
		 * Adds a document to the collection. Generally used for initializing the collection.
		 * Note that this should NOT be considered sufficient for adding a new document that does not yet exist in the
		 * on the server (has not been saved).
		 * <p>
		 * Subclasses should override this method if the document also needs to be tracked or stored in any additional
		 * lists or maps that are part of the collection class.
		 *
		 * @param document The document to add. The document must have a type which matches documentType.
		 */
		public function addDocument(document:IDocument):void
		{
			validateDocumentType(document);
			documents.addItem(document);
		}

		/**
		 * Adds a document to the record. Generally used for creating a new document. Adding a document to the record
		 * will cause the document to be persisted to the server immediately only if saveImmediately is true.
		 *
		 * @param document The document to add. The document must have a type which matches documentType.
		 * @param saveImmediately If true, a request will be made to persist the document to the server immediately;
		 * otherwise, the document will not be persisted until requested.
		 */
		public function addDocumentToRecord(document:IDocument, saveImmediately:Boolean=false):void
		{
			validateDocumentType(document);
			recordProxy.addDocument(document, saveImmediately);
		}

		/**
		 * Validates that the document is of a valid type for this collection. Throws an error if it is not.
		 * @param document The document to validate
		 */
		protected function validateDocumentType(document:IDocument):void
		{
			if (!document)
				throw new ArgumentError("Attempted to add null document");

			if (document.meta.type != documentType)
				throw new Error("Attempted to add document of type \"" + document.meta.type + "\" to collection that holds documents of type \"" + documentType + "\"");
		}

		public function removeDocument(document:IDocument):void
		{
			if (documents.contains(document))
			{
				documents.removeItemAt(documents.getItemIndex(document));
			}
		}

		public function get documents():ArrayCollection
		{
			return _documents;
		}

		public function get documentType():String
		{
			return _documentType;
		}

		public function set documentType(value:String):void
		{
			_documentType = value;
		}

		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}

		public function get isStitched():Boolean
		{
			return _isStitched;
		}

		public function set isStitched(value:Boolean):void
		{
			_isStitched = value;
		}

		public function set recordProxy(value:IRecordProxy):void
		{
			_recordProxy = value;
		}

		public function get recordProxy():IRecordProxy
		{
			return _recordProxy;
		}

		/**
		 * Updates the collection when a document has been created/updated and persisted and the id has changed.
		 * If the id does not affect this collection (id is not used as a key in a map) then this method does not need
		 * to do anything. Default behavior is to remove and re-add the document to the collection.
		 * Subclasses may override this method if special handling is required.
		 *
		 * @param oldId The id of the document before it was updated
		 * @param document The document which was updated (with its new id set)
		 */
		public function handleUpdatedId(oldId:String, document:IDocument):void
		{
			removeDocument(document);
			addDocument(document);
		}
	}
}
