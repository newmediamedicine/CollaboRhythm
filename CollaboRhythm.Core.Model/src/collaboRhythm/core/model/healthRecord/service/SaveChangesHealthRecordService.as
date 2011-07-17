package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	public class SaveChangesHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _pendingCreateDocuments:HashMap = new HashMap();
		private var _pendingRemoveDocuments:HashMap = new HashMap();
		public function SaveChangesHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		public function saveChanges(record:Record):void
		{
			for each (var document:IDocument in record.completeDocumentsById)
			{
				if (document.pendingAction == DocumentBase.ACTION_CREATE)
				{
					pendingCreateDocuments.put(document.id, document);
					//createDocument(record, document, getDocumentXml(document))
				}
				else if (document.pendingAction == DocumentBase.ACTION_VOID)
				{
					pendingRemoveDocuments.put(document.id, document);
					voidDocument(record, document.id, document.pendingActionReason);
				}
				// TODO: handle other actions
			}

			_logger.info("Save changes initiated. Pending create: " + pendingCreateDocuments.length + " Pending delete/void/archive: " + pendingRemoveDocuments.length);
		}

		private function getDocumentXml(document:IDocument):XML
		{
			// TODO: get the appropriate service that can convert this document type to XML
			// Alternatively, use the XmlMarshaller to marshall to XML
			var typeParts:Array = document.type.split("#");
			var elementName:String = typeParts[typeParts.length - 1];
			return < {elementName} />;
		}


		override protected function voidDocumentCompleteHandler(responseXml:XML,
																healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			super.voidDocumentCompleteHandler(responseXml, healthRecordServiceRequestDetails);
			finishRemove(responseXml, healthRecordServiceRequestDetails);
		}

		private function finishRemove(responseXml:XML,
									  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var document:IDocument = healthRecordServiceRequestDetails.document;
			pendingRemoveDocuments.remove(document.id);
			healthRecordServiceRequestDetails.record.completeDocumentsById.remove(document.id);
			healthRecordServiceRequestDetails.record.originalDocumentsById.remove(document.id);

			// eliminate any "standard" references to the document that was removed
			for each (var relationship:Relationship in document.relatesTo)
			{
				if (relationship.relatesTo != null)
				{
					var otherDocument:ArrayCollection = relationship.relatesTo.isRelatedFrom;
					if (otherDocument.contains(relationship))
					{
						otherDocument.removeItemAt(otherDocument.getItemIndex(relationship));
					}
				}
			}

			// TODO: eliminate any "special" references to the document that was removed; currently we are removing relationships from document.isRelatedFrom, but not, for example, medicationScheduleItem.adherenceItems
		}

		public function get pendingCreateDocuments():HashMap
		{
			return _pendingCreateDocuments;
		}

		public function get pendingRemoveDocuments():HashMap
		{
			return _pendingRemoveDocuments;
		}
	}
}
