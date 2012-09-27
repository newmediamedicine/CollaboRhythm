package collaboRhythm.core.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.core.model.healthRecord.service.supportClasses.ExpectedOperations;
	import collaboRhythm.core.model.healthRecord.service.supportClasses.IRecordSynchronizer;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.BackgroundProcessCollectionModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.Attachment;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.healthRecord.document.Problem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.Action;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.ActionGroup;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.ActionStep;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.DevicePlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.MeasurementPlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.MedicationPlan;
	import collaboRhythm.shared.model.healthRecord.document.healthActionPlan.Target;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionGroupResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.ActionStepResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.DeviceResult;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Measurement;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.Occurrence;
	import collaboRhythm.shared.model.healthRecord.document.healthActionResult.StopCondition;

	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class RecordSynchronizer implements IRecordSynchronizer
	{
		protected var _logger:ILogger;
		private var _record:Record;
		private var _synchronizationService:SynchronizationService;
		private const classesForSynchronization:Vector.<Class> = new <Class>[
			HealthActionResult,
			ActionGroupResult,
			ActionResult,
			ActionStepResult,
			DeviceResult,
			Measurement,
			collaboRhythm.shared.model.healthRecord.document.healthActionResult.MedicationAdministration,
			Occurrence,
			StopCondition,
			HealthActionPlan,
			Action,
			ActionGroup,
			ActionStep,
			DevicePlan,
			MeasurementPlan,
			MedicationPlan,
			collaboRhythm.shared.model.healthRecord.document.healthActionPlan.StopCondition,
			Target,			

			AdherenceItem,
			Attachment,
			HealthActionOccurrence,
			MedicationAdministration,
			Message,
			VitalSign,
			Equipment,
			HealthActionSchedule,
			MedicationFill,
			MedicationOrder,
			MedicationScheduleItem,
			Problem,
			ScheduleItemBase,
//			ScheduleItemOccurrence,
			DocumentMetadata,
			CodedValue,
			ValueAndUnit,
			Relationship,
			RecurrenceRule,
		];
		private var _backgroundProcessModel:BackgroundProcessCollectionModel;

		private var _isSynchronizationStarted:Boolean;
		private var _expectedDocumentsCount:int = 0;
		private var _expectedRelationshipsCount:int = 0;
		[ArrayElementType("collaboRhythm.core.model.SynchronizedDocumentUpdate")]
		private var _pendingSynchronizedDocumentUpdates:ArrayCollection = new ArrayCollection();
		[ArrayElementType("collaboRhythm.core.model.SynchronizedRelationshipUpdate")]
		private var _pendingSynchronizedRelationshipUpdates:ArrayCollection = new ArrayCollection();

		public function RecordSynchronizer(record:Record,
										   collaborationLobbyNetConnectionServiceProxy:CollaborationLobbyNetConnectionServiceProxy,
										   backgroundProcessModel:BackgroundProcessCollectionModel)
		{
			_backgroundProcessModel = backgroundProcessModel;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_record = record;
			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy);
			
			for each (var type:Class in classesForSynchronization)
				registerClassForSynchronization(type);
		}

		private function registerClassForSynchronization(type:Class):void
		{
			registerClassAlias(ReflectionUtils.getClassInfo(type).name, type);
		}

		private function addPendingSynchronizedUpdateDocument(update:SynchronizedDocumentUpdate):void
		{
			_pendingSynchronizedDocumentUpdates.addItem(update);
		}

		private function addPendingSynchronizedUpdateRelationship(update:SynchronizedRelationshipUpdate):void
		{
			_pendingSynchronizedRelationshipUpdates.addItem(update);
		}

		public function synchronizeDocument(record:Record,
											document:IDocument, oldId:String,
											isUpdate:Boolean, isSynchronizing:Boolean):void
		{
			updateDocument(new SynchronizedDocumentUpdate(record.ownerAccountId, document, oldId, document.meta.id, isUpdate, isSynchronizing));
		}

		public function updateDocument(value:SynchronizedDocumentUpdate):void
		{
			if (_synchronizationService.synchronize("updateDocument", value, false))
			{
				return;
			}

			if (value.ownerAccountId != _record.ownerAccountId)
			{
				_logger.warn("Failed to synchronize document: incoming account ID " + value.ownerAccountId + " does not match current local account ID " + _record.ownerAccountId);
				return;
			}

			addPendingSynchronizedUpdateDocument(value);
			processPendingUpdates();
		}

		private function processSynchronizedDocumentUpdate(value:SynchronizedDocumentUpdate):void
		{
			updateSynchronizingBackgroundProcess();

			if (!value.isUpdate)
			{
				if (value.document && value.document.meta && value.newId)
				{
					// TODO: figure out why the DocumentMetadata is not serializing correctly and fix it; for now we are using a workaround to get the correct id
					value.document.meta.id = value.newId;
					_record.addDocument(value.document, false);
				}
			}
			else
			{
				var document:IDocument = value.document;
				var isUpdate:Boolean = value.isUpdate;
				var oldId:String = value.oldId;

				var documentCollection:DocumentCollectionBase = record.documentCollections.getItem(document.meta.type);
				if (!documentCollection)
					throw new Error("Failed to get document collection for document type " + document.meta.type);

				if (!isUpdate)
					record.originalDocumentsById.remove(oldId);
				record.completeDocumentsById.remove(oldId);
				record.currentDocumentsById.remove(oldId);

				// update the document to use it's new id
				document.meta.id = value.newId;

				// Let the associated IDocumentCollection on the record handle the updated id (default behavior is to remove and re-add)
				documentCollection.handleUpdatedId(oldId, document);

				// Re-add the document to the record
				record.originalDocumentsById.put(document.meta.id, document);
				record.completeDocumentsById.put(document.meta.id, document);
				record.currentDocumentsById.put(document.meta.id, document);
			}
		}

		private function updateSynchronizingBackgroundProcess(isRunning:Boolean = true):void
		{
			_backgroundProcessModel.updateProcess(getQualifiedClassName(this), "Synchronizing...", isRunning);
		}

		public function synchronizeRelationship(record:Record,
												relationship:Relationship,
												isSynchronizing:Boolean):void
		{
			if (relationship.relatesFrom && relationship.relatesFrom.meta && relationship.relatesFrom.meta.id)
				relationship.relatesFromId = relationship.relatesFrom.meta.id;
			if (relationship.relatesTo && relationship.relatesTo.meta && relationship.relatesTo.meta.id)
				relationship.relatesToId = relationship.relatesTo.meta.id;
			updateRelationship(new SynchronizedRelationshipUpdate(record.ownerAccountId, relationship, isSynchronizing));
		}

		public function updateRelationship(value:SynchronizedRelationshipUpdate):void
		{
			if (_synchronizationService.synchronize("updateRelationship", value, false))
			{
				return;
			}

			if (value.ownerAccountId != _record.ownerAccountId)
			{
				_logger.warn("Failed to synchronize relationship: incoming account ID " + value.ownerAccountId + " does not match current local account ID " + _record.ownerAccountId);
				return;
			}

			addPendingSynchronizedUpdateRelationship(value);
			processPendingUpdates();
		}

		private function processPendingUpdates():void
		{
			if (_isSynchronizationStarted)
			{
				while (_pendingSynchronizedDocumentUpdates.length > 0)
				{
					processSynchronizedDocumentUpdate(_pendingSynchronizedDocumentUpdates.removeItemAt(0) as SynchronizedDocumentUpdate);
					_expectedDocumentsCount--;
				}

				if (_expectedDocumentsCount == 0)
				{
					while (_pendingSynchronizedRelationshipUpdates.length > 0)
					{
						processSynchronizedRelationshipUpdate(_pendingSynchronizedRelationshipUpdates.removeItemAt(0) as SynchronizedRelationshipUpdate);
						_expectedRelationshipsCount--;
					}

					if (_expectedRelationshipsCount == 0)
					{
						_isSynchronizationStarted = false;
						record.isLoading = false;
						updateSynchronizingBackgroundProcess(false);
					}
				}
			}
		}

		private function processSynchronizedRelationshipUpdate(value:SynchronizedRelationshipUpdate):void
		{
			updateSynchronizingBackgroundProcess();

			if (value.relationship)
			{
				var fromDocument:DocumentBase = record.currentDocumentsById.getItem(value.relationship.relatesFromId);
				var toDocument:DocumentBase = record.currentDocumentsById.getItem(value.relationship.relatesToId);
				if (value.relationship.type && fromDocument && toDocument)
				{
					record.addRelationship(value.relationship.type, fromDocument, toDocument);
				}
			}
		}

		public function closeRecord():void
		{
			_record = null;
			_synchronizationService.removeEventListener(this);
			_synchronizationService = null;
		}

		public function get record():Record
		{
			return _record;
		}

		public function startSynchronizing(expectedOperations:ExpectedOperations):void
		{
			if (_synchronizationService.synchronize("startSynchronizing", expectedOperations, false))
			{
				return;
			}

			if (_isSynchronizationStarted || _expectedDocumentsCount > 0 || _expectedRelationshipsCount > 0)
			{
				_logger.warn("Attempted to synchronize when previous synchronization was not complete. _isSynchronizationStarted=" +
						_isSynchronizationStarted + " _expectedDocumentsCount=" + _expectedDocumentsCount +
						" _expectedRelationshipsCount=" + _expectedRelationshipsCount);
				return;
			}

			_isSynchronizationStarted = true;
			_expectedDocumentsCount = expectedOperations.updateDocumentsCount;
			_expectedRelationshipsCount = expectedOperations.updateRelationshipsCount;
			updateSynchronizingBackgroundProcess();
			record.isLoading = true;
			clearLocalNonSynchedDocuments();
			processPendingUpdates();
		}

		public function stopSynchronizing(failedOperations:ExpectedOperations):void
		{
			if (_synchronizationService.synchronize("stopSynchronizing", failedOperations, false))
			{
				return;
			}

			_expectedDocumentsCount -= failedOperations.updateDocumentsCount;
			_expectedRelationshipsCount -= failedOperations.updateRelationshipsCount;
			processPendingUpdates();
		}

		private function clearLocalNonSynchedDocuments():void
		{
			for each (var document:IDocument in record.completeDocumentsById.values())
			{
				if (document.meta && document.meta.id && document.meta.id.indexOf(Record.SKIP_PERSIST_DOCUMENT_ID_PREFIX) != -1)
				{
					// setting the pendingAction will ensure that the document is removed from completeDocumentsById
					document.pendingAction = DocumentBase.ACTION_CREATE;
					record.removeDocument(document);
				}
			}

		}
	}
}
