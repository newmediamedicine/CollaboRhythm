package collaboRhythm.shared.model
{

	import mx.collections.ArrayCollection;

	public interface IRecordStorageService
	{
		/**
		 * Saves all changes to all documents in the specified record to the server.
		 *
		 * @param record The record to save
		 */
		function saveAllChanges(record:Record):void;

		/**
		 * Saves changes to all specified documents (documents which must be part of the specified record) to the server.
		 *
		 * @param record The record which the specified documents belong to
		 * @param documents The documents to save
		 * @param relationships The relationships to save
		 */
		function saveChanges(record:Record, documents:ArrayCollection, relationships:ArrayCollection=null):void;
	}
}
