package collaboRhythm.shared.model.healthRecord
{

	public interface IRecordProxy
	{
		/**
		 * Adds a document to the record. Generally used for creating a new document. Adding a document to the record
		 * will cause the document to be persisted to the server immediately only if saveImmediately is true.
		 *
		 * @param document The document to add. The document must have a type which matches documentType.
		 * @param saveImmediately If true, a request will be made to persist the document to the server immediately;
		 * otherwise, the document will not be persisted until requested.
		 */
		function addDocument(document:IDocument, saveImmediately:Boolean=false):void;
	}
}
