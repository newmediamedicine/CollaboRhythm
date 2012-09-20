package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.supportClasses.ChangeSet;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.Relationship;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	/**
	 * Service responsible for persisting changes to documents in a record to a health record server.
	 */
	public class SaveChangesHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _healthRecordServiceFacade:HealthRecordServiceFacade;
		private var _pendingCreateDocuments:HashMap = new HashMap();
		private var _pendingRemoveDocuments:HashMap = new HashMap();
		private var _pendingUpdateDocuments:HashMap = new HashMap();
		private var _relationshipsRequiringDocuments:ArrayCollection = new ArrayCollection();
		private var _pendingRelateDocuments:ArrayCollection = new ArrayCollection();
		private var _unexpectedErrorsChangeSet:ChangeSet = new ChangeSet();
		private var _connectionErrorsChangeSet:ChangeSet = new ChangeSet();
		private const REMOVE_RELATES_TO_RELATIONSHIPS_FROM_UPDATED_DOCUMENTS:Boolean = false;

		public function SaveChangesHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													   account:Account,
													   healthRecordServiceFacade:HealthRecordServiceFacade)
		{
			super(consumerKey, consumerSecret, baseURL, account);
			_healthRecordServiceFacade = healthRecordServiceFacade;
		}

		/**
		 * Resets the count of failed operations. This should generally be called after isSaving becomes false and the
		 * user chooses to retry the saving operation.
		 */
		public function resetConnectionErrorsChangeSet():void
		{
			connectionErrorsChangeSet.clear();
			_healthRecordServiceFacade.hasConnectionErrorsSaving = false;
			relationshipsRequiringDocuments.removeAll();
		}

		public function resetUnexpectedErrorChangeSet():void
		{
			unexpectedErrorsChangeSet.clear();
			_healthRecordServiceFacade.hasUnexpectedErrorsSaving = false;
			relationshipsRequiringDocuments.removeAll();
		}

		/**
		 * Checks to see if there are unsaved changes (unsaved to the server) in a given record.
		 * This method currently only looks for unsaved changes to documents. It does not address unsaved relationships.
		 *
		 * @param record The record to query whether there are unsaved changes
		 */
		public function hasUnsavedChanges(record:Record):Boolean
		{
			for each (var document:IDocument in record.completeDocumentsById.values())
			{
				if (document == null)
				{
					_logger.warn("Attempted to check for unsaved changes to a null document. Document skipped.");
				}
				else if (document.pendingAction == DocumentBase.ACTION_CREATE)
				{
					return true;
				}
				else if (document.pendingAction == DocumentBase.ACTION_VOID)
				{
					return true;
				}
				else if (document.pendingAction == DocumentBase.ACTION_DELETE)
				{
					return true;
				}
				else if (document.pendingAction == DocumentBase.ACTION_UPDATE)
				{
					return true;
				}
				// TODO: handle other actions
			}

			if (record.newRelationships)
			{
				for each (var relationship:Relationship in record.newRelationships)
				{
					if (relationship.pendingAction == Relationship.ACTION_CREATE)
					{
						return true;
					}
				}
			}

			return false;
		}

		/**
		 * Saves all changes to all documents in the specified record to the server.
		 *
		 * @param record The record to save
		 */
		public function saveAllChanges(record:Record):void
		{
			saveChanges(record, record.completeDocumentsById.values(), record.newRelationships);
		}

		/**
		 * Saves changes to all specified documents (documents which must be part of the specified record) to the server.
		 *
		 * @param record The record which the specified documents belong to
		 * @param documents The documents to save
		 * @param relationships The relationships to save
		 */
		public function saveChanges(record:Record, documents:ArrayCollection, relationships:ArrayCollection = null):void
		{
			for each (var document:IDocument in documents)
			{
				if (document == null)
				{
					_logger.warn("Attempted to save changes for a null document. Document skipped.");
				}
				else if (document.pendingAction == DocumentBase.ACTION_CREATE)
				{
					if (addPendingOperation(pendingCreateDocuments, document))
						createDocument(record, document, getDocumentXml(document));
				}
				else if (document.pendingAction == DocumentBase.ACTION_VOID)
				{
					if (addPendingOperation(pendingRemoveDocuments, document))
						voidDocument(record, document, document.pendingActionReason);
				}
				else if (document.pendingAction == DocumentBase.ACTION_DELETE)
				{
					if (addPendingOperation(pendingRemoveDocuments, document))
						deleteDocument(record, document);
				}
				else if (document.pendingAction == DocumentBase.ACTION_UPDATE)
				{
					if (addPendingOperation(pendingUpdateDocuments, document))
						updateDocument(record, document, getDocumentXml(document));
				}
				// TODO: handle other actions
			}

			// TODO: handle relationships more optimally
			if (relationships)
			{
				for each (var relationship:Relationship in relationships)
				{
					if (!relationshipsRequiringDocuments.contains(relationship))
					{
						relationshipsRequiringDocuments.addItem(relationship);
					}
				}
				checkRelationshipsRequiringDocuments(record);
			}

			if (numPendingOperations > 0)
				_logger.info("Save changes initiated. " + pendingOperationsSummary);

			updateIsSaving();
		}

		private function addPendingOperation(pendingChangeMap:HashMap, document:IDocument):Boolean
		{
			if (pendingChangeMap.getItem(document.meta.id) == null)
			{
				pendingChangeMap.put(document.meta.id, document);
				document.isBeingSaved = true;
				return true;
			}
			else
			{
				return false;
			}
		}

		private function get pendingOperationsSummary():String
		{
			return "Pending documents (create, update, remove): " + pendingCreateDocuments.size() + ", " +
					pendingUpdateDocuments.size() + ", " + pendingRemoveDocuments.size() +
					". Relationships (being created, requiring documents): " + pendingRelateDocuments.length + ", " +
					relationshipsRequiringDocuments.length;
		}

		public function get errorsSavingSummary():String
		{
			if (errorsSavingCount > 0)
			{
				var parts:Array = new Array();
				if (unexpectedErrorsChangeSet.length > 0)
					parts.push("Unexpected error " + unexpectedErrorsChangeSet.summary);
				if (connectionErrorsChangeSet.length > 0)
					parts.push("Connection error " + connectionErrorsChangeSet.summary);

				return parts.join(". ") + ".";
			}
			else
				return "No failed operations.";
		}


		private function checkRelationshipsRequiringDocuments(record:Record):void
		{
			var relationshipsRequiringDocumentsCopy:ArrayCollection = new ArrayCollection(relationshipsRequiringDocuments.toArray());
			for each (var relationship:Relationship in relationshipsRequiringDocumentsCopy)
			{
				if (relationship.relatesFrom == null || relationship.relatesTo == null || relationship.type == null)
				{
					const invalidRelationshipMessage:String = "Warning: failed to create a {0} relationship. relatesFrom={1} relatesFromId={2} relatesTo={3} relatesToId={4}. This can happen if either the relatesFrom or relatesTo document has been deleted, voided, archived, or replaced, or if it has failed to load for some other reason.";
					_logger.warn(invalidRelationshipMessage, relationship.type, relationship.relatesFrom,
							relationship.relatesFromId, relationship.relatesTo, relationship.relatesToId);
					relationshipsRequiringDocuments.removeItemAt(relationshipsRequiringDocuments.getItemIndex(relationship));
				}
				else
				{
					const waitingToCreateMessage:String = "Warning: waiting to create a {0} relationship but the document to relate {1} {2} has a pendingAction of {3} and is not in the pendingCreateDocuments, unexpectedErrorsChangeSet, or connectionErrorsChangeSet. Relationship will probably never be created.";
					var relatesFromDocumentReady:Boolean = relationship.relatesFrom.pendingAction == null;
					var relatesToDocumentReady:Boolean = relationship.relatesTo.pendingAction == null;
					if (!relatesFromDocumentReady)
					{
						if (pendingCreateDocuments.getItem(relationship.relatesFrom.meta.id) == null &&
								!unexpectedErrorsChangeSet.containsCreateDocument(relationship.relatesFrom.meta.id) &&
								!connectionErrorsChangeSet.containsCreateDocument(relationship.relatesFrom.meta.id))
							_logger.warn(waitingToCreateMessage, relationship.type, "from",
									relationship.relatesFrom.meta.id, relationship.relatesFrom.pendingAction);
					}
					if (!relatesToDocumentReady)
					{
						if (pendingCreateDocuments.getItem(relationship.relatesTo.meta.id) == null &&
								!unexpectedErrorsChangeSet.containsCreateDocument(relationship.relatesTo.meta.id) &&
								!connectionErrorsChangeSet.containsCreateDocument(relationship.relatesTo.meta.id))
							_logger.warn(waitingToCreateMessage, relationship.type, "to",
									relationship.relatesTo.meta.id, relationship.relatesTo.pendingAction);
					}
					if (relatesFromDocumentReady && relatesToDocumentReady)
					{
						relationshipsRequiringDocuments.removeItemAt(relationshipsRequiringDocuments.getItemIndex(relationship));
						pendingRelateDocuments.addItem(relationship);
						relateDocuments(record, relationship);
					}
				}
			}
		}

		private function getDocumentXml(document:IDocument):String
		{
			// get the appropriate service that can convert this document type to XML
			var service:DocumentStorageServiceBase = _healthRecordServiceFacade.getService(document.meta.type);
			return service.marshallToXml(document);
		}

		override protected function deleteDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
																  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			super.deleteDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
			finishRemove(responseXml, healthRecordServiceRequestDetails);
		}

		override protected function voidDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
																healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			super.voidDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
			finishRemove(responseXml, healthRecordServiceRequestDetails);
		}

		private function finishRemove(responseXml:XML,
									  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var document:IDocument = healthRecordServiceRequestDetails.document;
			if (document == null)
				throw new Error("Document not specified on the HealthRecordServiceRequestDetails. Unable to finish remove operation.");

			var record:Record = healthRecordServiceRequestDetails.record;
			if (record == null)
				throw new Error("Record not specified on the HealthRecordServiceRequestDetails. Unable to finish remove operation.");

			document.pendingAction = null;
			document.isBeingSaved = false;
			removePendingDocument(document.meta.id, pendingRemoveDocuments);
			record.completeDocumentsById.remove(document.meta.id);
			record.originalDocumentsById.remove(document.meta.id);

			// eliminate any "standard" references to the document that was removed
			document.clearRelationships();

			document.isBeingSaved = false;

			// TODO: eliminate any "special" references to the document that was removed; currently we are removing relationships from document.isRelatedFrom, but not, for example, medicationScheduleItem.adherenceItems

			updateIsSaving();
		}

		override protected function createDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
																  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (handleCreateUpdateResponse(event, responseXml, healthRecordServiceRequestDetails, false))
				super.createDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
		}

		private function handleCreateUpdateResponse(event:IndivoClientEvent, responseXml:XML,
													healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails,
													isUpdate:Boolean):Boolean
		{
			var document:IDocument = healthRecordServiceRequestDetails.document;
			if (document == null)
				throw new Error("Document not specified on the HealthRecordServiceRequestDetails. Unable to finish create operation.");

			document.pendingAction = null;

			var failureWarning:String;
			if (responseXml.name() != "Document")
			{
				failureWarning = "Event from document creation was Complete, but response XML is not a Document.";
			}
			else if (!responseXml.hasOwnProperty("@id"))
			{
				failureWarning = "Event from document creation was Complete, but response XML does not have an id attribute.";
			}
			else if (!responseXml.hasOwnProperty("@type"))
			{
				failureWarning = "Event from document creation was Complete, but response XML does not have a type attribute.";
			}
			else if (responseXml.@type.toString() == "")
			{
				failureWarning = "Document was created (id = " + responseXml.@id.toString() + "), but has no type " +
						"(expected " + document.meta.type +
						"). XML of submitted document may be incompatible with schema on server. You may want to delete the document and try again.";
			}
			else if (document.meta.type != responseXml.@type.toString())
			{
				failureWarning = "Unexpected response. Document was created (id = " + responseXml.@id.toString() +
						"), but has the wrong type " +
						"(expected " + document.meta.type + ", actual " + responseXml.@type.toString() +
						"). You may want to delete the document and try again.";
			}

			var record:Record = healthRecordServiceRequestDetails.record;
			if (record == null)
				throw new Error("Record not specified on the HealthRecordServiceRequestDetails. Unable to finish create operation.");

			var documentCollection:DocumentCollectionBase = record.documentCollections.getItem(document.meta.type);
			if (!documentCollection)
				throw new Error("Failed to get document collection for document type " + document.meta.type);

			// We now have the "real" id of the document, but the OLD id of the document was used as the key in various collections.
			// Using the OLD id of the created document, remove the document from the appropriate collections
			var oldId:String = document.meta.id;
			if (!isUpdate)
				record.originalDocumentsById.remove(oldId);
			record.completeDocumentsById.remove(oldId);
			record.currentDocumentsById.remove(oldId);

			if (failureWarning)
			{
				documentCollection.removeDocument(document);
				_logger.warn(failureWarning + " Submitted document XML: " + event.requestXml + " Response: " +
						responseXml);
				return false;
			}

			// update the document to use it's new id
			document.meta.id = responseXml.@id.toString();

			// Let the associated IDocumentCollection on the record handle the updated id (default behavior is to remove and re-add)
			documentCollection.handleUpdatedId(oldId, document);

			// Re-add the document to the record
			record.originalDocumentsById.put(document.meta.id, document);
			record.completeDocumentsById.put(document.meta.id, document);
			record.currentDocumentsById.put(document.meta.id, document);

			if (isUpdate)
			{
				updateRelationships(record, document);
			}
			else
			{
				// update any "standard" references to the document that was added
				for each (var relationship:Relationship in document.relatesTo)
				{
					relationship.relatesFromId = document.meta.id;
				}
				for each (relationship in document.isRelatedFrom)
				{
					relationship.relatesToId = document.meta.id;
				}
			}

			// TODO: updateSpecialRelationships ?
//			documentCollection.updateSpecialRelationships(document);

			// TODO: handle relationships more optimally
			checkRelationshipsRequiringDocuments(record);

			if (isUpdate)
				removePendingDocument(oldId, pendingUpdateDocuments);
			else
				removePendingDocument(oldId, pendingCreateDocuments);
			document.isBeingSaved = false;

			updateIsSaving();

			return true;
		}

		private function updateRelationships(record:Record, document:IDocument):void
		{
			for each (var relationship:Relationship in document.isRelatedFrom)
			{
				// create new relationships for relationships from other documents to this updated (replaced) document
				relationship.relatesToId = document.meta.id;
				relationship.pendingAction = Relationship.ACTION_CREATE;
			}

			saveChanges(record, null, document.isRelatedFrom);

			for each (relationship in document.relatesTo)
			{
				if (REMOVE_RELATES_TO_RELATIONSHIPS_FROM_UPDATED_DOCUMENTS)
				{
					var otherDocument:IDocument = relationship.relatesTo;
					if (otherDocument)
					{
						removeFromCollection(otherDocument.isRelatedFrom, relationship);
					}
					removeFromCollection(document.relatesTo, relationship);
				}
				else
				{
					relationship.relatesFromId = document.meta.id;
					relationship.pendingAction = Relationship.ACTION_CREATE;
				}
			}

			saveChanges(record, null, document.relatesTo);
		}

		private function removeFromCollection(relationshipsCollection:ArrayCollection, relationship:Relationship):void
		{
			var index:int = relationshipsCollection.getItemIndex(relationship);
			if (index != -1)
				relationshipsCollection.removeItemAt(index);
		}

		override protected function relateDocumentsCompleteHandler(event:IndivoClientEvent, responseXml:XML,
																   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var relationship:Relationship = healthRecordServiceRequestDetails.customData as Relationship;
			if (relationship == null)
				throw new Error("Relationship not specified on the HealthRecordServiceRequestDetails. Unable to finish relate documents operation.");

			var failureWarning:String;
			if (responseXml.name() != "ok")
			{
				failureWarning = "Event from relate documents was Complete, but response XML is not ok.";
			}

			var record:Record = healthRecordServiceRequestDetails.record;
			if (record == null)
				throw new Error("Record not specified on the HealthRecordServiceRequestDetails. Unable to finish create operation.");

			if (failureWarning)
			{
				_logger.warn(failureWarning + " Submitted request: " + event.relativePath + " Response: " +
						responseXml);
			}

			relationship.pendingAction = null;

			// remove the appropriate relationship from pendingRelateDocuments
			removePendingRelationship(relationship);
			record.removeNewRelationship(relationship);

			updateIsSaving();

			super.relateDocumentsCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
		}

		private function removePendingRelationship(relationship:Relationship):void
		{
			for each (var pendingRelationship:Relationship in pendingRelateDocuments)
			{
				if (pendingRelationship == relationship)
				{
					relationship.pendingAction = null;
					pendingRelateDocuments.removeItemAt(pendingRelateDocuments.getItemIndex(relationship));
				}
			}
		}

		private function updateIsSaving():void
		{
			var pendingOperations:int = numPendingOperations;
			_healthRecordServiceFacade.hasConnectionErrorsSaving = connectionErrorsChangeSet.length > 0;
			_healthRecordServiceFacade.hasUnexpectedErrorsSaving = unexpectedErrorsChangeSet.length > 0;
			var isSaving:Boolean = pendingOperations > 0;
			if (_healthRecordServiceFacade.isSaving != isSaving)
			{
				_healthRecordServiceFacade.isSaving = isSaving;
				_logger.info("Saving " + (isSaving ? "in progress. " + pendingOperationsSummary + ". " : "complete. ") +
						errorsSavingSummary);
			}
		}

		private function get numPendingOperations():int
		{
			return pendingCreateDocuments.size() + pendingUpdateDocuments.size() + pendingRemoveDocuments.size() +
					pendingRelateDocuments.length;
		}

		private function get errorsSavingCount():int
		{
			return unexpectedErrorsChangeSet.length + connectionErrorsChangeSet.length;
		}

		private function get currentRecord():Record
		{
			return _healthRecordServiceFacade.currentRecord;
		}

		override protected function updateDocumentCompleteHandler(event:IndivoClientEvent, responseXml:XML,
																  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (handleCreateUpdateResponse(event, responseXml, healthRecordServiceRequestDetails, true))
				super.updateDocumentCompleteHandler(event, responseXml, healthRecordServiceRequestDetails);
		}

		override protected function handleError(event:IndivoClientEvent, errorStatus:String,
												healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			var isRetrying:Boolean = super.handleError(event, errorStatus, healthRecordServiceRequestDetails);
			if (!isRetrying)
			{
				var document:IDocument = healthRecordServiceRequestDetails.document;

				var errorChangeSet:ChangeSet;
				if (event.isConnectionError)
					errorChangeSet = connectionErrorsChangeSet;
				else
					errorChangeSet = unexpectedErrorsChangeSet;

				// update the appropriate "pending" collections
				if (healthRecordServiceRequestDetails.indivoApiCall == CREATE_DOCUMENT)
				{
					errorChangeSet.addDocument(document);
					removePendingDocument(document.meta.id, pendingCreateDocuments);
					document.isBeingSaved = false;
				}
				else if (healthRecordServiceRequestDetails.indivoApiCall == UPDATE_DOCUMENT)
				{
					errorChangeSet.addDocument(document);
					removePendingDocument(document.meta.id, pendingUpdateDocuments);
					document.isBeingSaved = false;
				}
				else if (healthRecordServiceRequestDetails.indivoApiCall == DELETE_DOCUMENT ||
						healthRecordServiceRequestDetails.indivoApiCall == ARCHIVE_DOCUMENT ||
						healthRecordServiceRequestDetails.indivoApiCall == VOID_DOCUMENT)
				{
					errorChangeSet.addDocument(document);
					removePendingDocument(document.meta.id, pendingRemoveDocuments);
					document.isBeingSaved = false;
				}
				else if (healthRecordServiceRequestDetails.indivoApiCall == RELATE_NEW_DOCUMENT)
				{
					throw new Error("Unexpected indivoApiCall on response healthRecordServiceRequestDetails: " +
							healthRecordServiceRequestDetails.indivoApiCall);
				}
				else if (healthRecordServiceRequestDetails.indivoApiCall == RELATE_DOCUMENTS)
				{
					var relationship:Relationship = healthRecordServiceRequestDetails.customData as Relationship;
					if (relationship == null)
						throw new Error("Relationship not specified on the HealthRecordServiceRequestDetails. Unable to finish relate documents operation.");
					errorChangeSet.addRelationship(relationship);
					removePendingRelationship(relationship);
				}

				updateIsSaving();
			}
			return isRetrying;
		}

		private function addFailedDocument(document:IDocument, pendingChangeMap:HashMap):void
		{
			pendingChangeMap.put(document.meta.id, document);
		}

		private function removePendingDocument(documentId:String, pendingChangeMap:HashMap):void
		{
			if (pendingChangeMap.getItem(documentId))
			{
				pendingChangeMap.remove(documentId);
			}
			else
			{
				_logger.warn("Failed to remove document " + documentId + " from pending document operations.");
			}
		}

		public function get pendingCreateDocuments():HashMap
		{
			return _pendingCreateDocuments;
		}

		public function get pendingRemoveDocuments():HashMap
		{
			return _pendingRemoveDocuments;
		}

		public function get relationshipsRequiringDocuments():ArrayCollection
		{
			return _relationshipsRequiringDocuments;
		}

		public function get pendingRelateDocuments():ArrayCollection
		{
			return _pendingRelateDocuments;
		}

		public function get pendingUpdateDocuments():HashMap
		{
			return _pendingUpdateDocuments;
		}

		public function get unexpectedErrorsChangeSet():ChangeSet
		{
			return _unexpectedErrorsChangeSet;
		}

		public function get connectionErrorsChangeSet():ChangeSet
		{
			return _connectionErrorsChangeSet;
		}

		public function get connectionErrorsSummary():String
		{
			return connectionErrorsChangeSet.summary;
		}

		public function get unexpectedErrorsSummary():String
		{
			return unexpectedErrorsChangeSet.summary;
		}
	}
}
