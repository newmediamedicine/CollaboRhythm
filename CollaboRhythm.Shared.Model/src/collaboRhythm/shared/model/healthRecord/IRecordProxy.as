package collaboRhythm.shared.model.healthRecord
{

	import collaboRhythm.shared.model.healthRecord.DocumentBase;

	import mx.collections.ArrayCollection;

	/**
	 * Represents the actions which can be performed on a record with regard to document operations.
	 */
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

		/**
		 * Removes (deletes, voids, or archives) the document from the record. Generally used for deleting a document that has
		 * been persisted and needs to be deleted or have its status changed. The removal will NOT be persisted to the server
		 * until saveChanges is called (a "save immediately" feature, like with addDocument has not been implemented yet).
		 *
		 * @param document The document to remove from the record
		 * @param removeAction The removal action to take (delete, void, or archive)
		 * @param reason When the document status is set to void or archive, a reason for the removal can optionally be provided
		 * @param recursive If true, the removal action will also be applied recursively to documents that this document relates to
		 * @return The number of documents removed (generally 1 if not recursive)
		 */
		// TODO: resolve compile error when DocumentBase.ACTION_DELETE is used as default for removeAction
		function removeDocument(document:IDocument, removeAction:String = "delete",
								reason:String = null, recursive:Boolean = false):int;

		/**
		 * Saves all changes to all documents in this record to the server.
		 */
		function saveAllChanges():void;

		/**
		 * Saves changes to all specified documents (documents which must be part of this record) to the server.
		 *
		 * @param documents The documents to save
		 */
		function saveChanges(documents:ArrayCollection):void;
	}
}
