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
		 * @param document the document to add
		 */
		public function addDocument(document:IDocument):void
		{
			validateDocumentType(document);
			documents.addItem(document);
		}

		/**
		 * Validates that the document is of a valid type for this collection. Throws an error if it is not.
		 * @param document the document to validate
		 */
		protected function validateDocumentType(document:IDocument):void
		{
			if (!document)
				throw new ArgumentError("Attempted to add null document");

			if (document.type != documentType)
				throw new Error("Attempted to add document of type \"" + document.type + "\" to collection that holds documents of type \"" + documentType + "\"");
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
	}
}
