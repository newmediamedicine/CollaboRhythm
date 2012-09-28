package collaboRhythm.core.model.healthRecord.service.supportClasses
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;

	public interface IRecordSynchronizer
	{
		function synchronizeDocument(record:Record,
									 document:IDocument, oldId:String,
									 isUpdate:Boolean, isSynchronizing:Boolean):void;

		function synchronizeRelationship(record:Record,
										 relationship:Relationship,
										 isSynchronizing:Boolean):void;

		function startSynchronizing(expectedOperations:ExpectedOperations):void;
		function stopSynchronizing(failedOperations:ExpectedOperations):void;
	}
}
