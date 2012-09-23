/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model
{

	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.IDocumentCollection;
	import collaboRhythm.shared.model.healthRecord.IRecord;
	import collaboRhythm.shared.model.healthRecord.IRecordProxy;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentModel;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionOccurrencesModel;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlansModel;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResultsModel;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedulesModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFillsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrdersModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.ProblemsModel;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	[Bindable]
	public class Record implements IRecord, IRecordProxy
	{
		private var _id:String;
		private var _ownerAccountId:String;
		private var _label:String;
		private var _shared:Boolean = false;
		private var _role_label:String;
		private var _demographics:Demographics;
		private var _contact:Contact;

		[ArrayElementType("collaboRhythm.shared.model.healthRecord.IDocumentCollection")]
		private var _documentCollections:HashMap = new HashMap(); // key: document type, value: IDocumentCollection
		private var _completeDocumentsById:HashMap = new HashMap(); // key: document id, value: IDocument
		private var _originalDocumentsById:HashMap = new HashMap(); // key: document id, value: IDocument
		private var _currentDocumentsById:HashMap = new HashMap(); // key: document id, value: IDocument
		private var _medicationOrdersModel:MedicationOrdersModel;
		private var _medicationFillsModel:MedicationFillsModel;
		private var _medicationScheduleItemsModel:MedicationScheduleItemsModel;
		private var _medicationAdministrationsModel:MedicationAdministrationsModel;
		private var _equipmentModel:EquipmentModel;
		private var _healthActionSchedulesModel:HealthActionSchedulesModel;
		private var _adherenceItemsModel:AdherenceItemsModel;
		private var _problemsModel:ProblemsModel = new ProblemsModel();
		private var _appData:HashMap = new HashMap();
		private var _vitalSignsModel:VitalSignsModel;
		private var _healthActionPlansModel:HealthActionPlansModel;
		private var _healthActionResultsModel:HealthActionResultsModel;
		private var _healthActionOccurrencesModel:HealthActionOccurrencesModel;
		private var _newRelationships:ArrayCollection = new ArrayCollection(); // of Relationship instances that have not been persisted

		// TODO: move HealthChartsModel to blood pressure plugin; eliminate healthChartsModel property and field; use appData instead
		private var _healthChartsModel:HealthChartsModel;
		private var _storageService:IRecordStorageService;
		private var _isLoading:Boolean;
		private var _isSaving:Boolean;
		private var _hasConnectionErrorsSaving:Boolean;
		private var _hasUnexpectedErrorsSaving:Boolean;
		private var _dateLoaded:Date;

		public function Record(recordXml:XML)
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			_id = recordXml.@id;
			_label = recordXml.@label;
			if (recordXml.hasOwnProperty("@shared"))
				_shared = HealthRecordHelperMethods.stringToBoolean(recordXml.@shared);
			if (recordXml.hasOwnProperty("@role_label"))
				_role_label = recordXml.@role_label;
			initDocumentModels();
		}

		private function initDocumentModels():void
		{
			// TODO: fix the handling of problems
			// the problems model is not currently cleared because it is only loaded once when in clinician mode
			// the problems model is not currently used in patient mode
			medicationOrdersModel = new MedicationOrdersModel();
			medicationFillsModel = new MedicationFillsModel();
			medicationScheduleItemsModel = new MedicationScheduleItemsModel();
			medicationAdministrationsModel = new MedicationAdministrationsModel();
			equipmentModel = new EquipmentModel();
			healthActionSchedulesModel = new HealthActionSchedulesModel();
			adherenceItemsModel = new AdherenceItemsModel();
			vitalSignsModel = new VitalSignsModel();
			healthActionPlansModel = new HealthActionPlansModel();
			healthActionResultsModel = new HealthActionResultsModel();
			healthActionOccurrencesModel = new HealthActionOccurrencesModel();

			documentCollections.clear();
			addDocumentCollection(medicationOrdersModel);
			addDocumentCollection(medicationFillsModel);
			addDocumentCollection(medicationScheduleItemsModel);
			addDocumentCollection(medicationAdministrationsModel);
			addDocumentCollection(equipmentModel);
			addDocumentCollection(healthActionSchedulesModel);
			addDocumentCollection(adherenceItemsModel);
			addDocumentCollection(problemsModel);
			addDocumentCollection(vitalSignsModel);
			addDocumentCollection(healthActionPlansModel);
			addDocumentCollection(healthActionResultsModel);
			addDocumentCollection(healthActionOccurrencesModel);
		}

		protected function addDocumentCollection(documentCollection:IDocumentCollection):void
		{
			documentCollection.recordProxy = this;
			documentCollections.put(documentCollection.documentType, documentCollection);
		}

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		public function get shared():Boolean
		{
			return _shared;
		}

		public function set shared(value:Boolean):void
		{
			_shared = value;
		}

		public function get role_label():String
		{
			return _role_label;
		}

		public function set role_label(value:String):void
		{
			_role_label = value;
		}

		public function get demographics():Demographics
		{
			return _demographics;
		}

		public function set demographics(value:Demographics):void
		{
			_demographics = value;
		}

		public function get contact():Contact
		{
			return _contact;
		}

		public function set contact(value:Contact):void
		{
			_contact = value;

			// TODO: store the images with the record (as a binary document) or use some other identifier for the file name
		}

		public function get equipmentModel():EquipmentModel
		{
			return _equipmentModel;
		}

		public function set equipmentModel(value:EquipmentModel):void
		{
			_equipmentModel = value;
			addDocumentCollection(value);
		}

		public function get adherenceItemsModel():AdherenceItemsModel
		{
			return _adherenceItemsModel;
		}

		public function set adherenceItemsModel(value:AdherenceItemsModel):void
		{
			_adherenceItemsModel = value;
			addDocumentCollection(value);
		}

		public function get appData():HashMap
		{
			return _appData;
		}

		public function getAppData(key:String, type:Class):Object
		{
			var data:Object = appData[key] as type;
			if (data)
				return data;
			else
				throw new Error("appData on Record does not contain a " + (type as Class).toString() + " for key " +
						key);
		}

		public function clearDocuments():void
		{
			initDocumentModels();
			completeDocumentsById.clear();
			originalDocumentsById.clear();
			currentDocumentsById.clear();
		}

		public function get problemsModel():ProblemsModel
		{
			return _problemsModel;
		}

		public function set problemsModel(value:ProblemsModel):void
		{
			_problemsModel = value;
			addDocumentCollection(value);
		}

		public function get medicationOrdersModel():MedicationOrdersModel
		{
			return _medicationOrdersModel;
		}

		public function set medicationOrdersModel(value:MedicationOrdersModel):void
		{
			_medicationOrdersModel = value;
			addDocumentCollection(value);
		}

		public function get medicationFillsModel():MedicationFillsModel
		{
			return _medicationFillsModel;
		}

		public function set medicationFillsModel(value:MedicationFillsModel):void
		{
			_medicationFillsModel = value;
			addDocumentCollection(value);
		}

		public function get medicationScheduleItemsModel():MedicationScheduleItemsModel
		{
			return _medicationScheduleItemsModel;
		}

		public function set medicationScheduleItemsModel(value:MedicationScheduleItemsModel):void
		{
			_medicationScheduleItemsModel = value;
			addDocumentCollection(value);
		}

		public function get medicationAdministrationsModel():MedicationAdministrationsModel
		{
			return _medicationAdministrationsModel;
		}

		public function set medicationAdministrationsModel(value:MedicationAdministrationsModel):void
		{
			_medicationAdministrationsModel = value;
			addDocumentCollection(value);
		}

		public function get healthActionSchedulesModel():HealthActionSchedulesModel
		{
			return _healthActionSchedulesModel;
		}

		public function set healthActionSchedulesModel(value:HealthActionSchedulesModel):void
		{
			_healthActionSchedulesModel = value;
			addDocumentCollection(value);
		}

		public function get vitalSignsModel():VitalSignsModel
		{
			return _vitalSignsModel;
		}

		public function set vitalSignsModel(value:VitalSignsModel):void
		{
			_vitalSignsModel = value;
			addDocumentCollection(value);
		}

		// TODO: move HealthChartsModel to blood pressure plugin; eliminate healthChartsModel property and field; use appData instead
		public function get healthChartsModel():HealthChartsModel
		{
			return _healthChartsModel;
		}

		public function set healthChartsModel(value:HealthChartsModel):void
		{
			_healthChartsModel = value;
		}

		/**
		 * Map of document collections where the key is the document type (fully qualified, such as
		 * "http://indivo.org/vocab/xml/documents#Problem") and the value is a corresponding instance of
		 * IDocumentCollection.
		 */
		[ArrayElementType("collaboRhythm.shared.model.healthRecord.IDocumentCollection")]
		public function get documentCollections():HashMap
		{
			return _documentCollections;
		}

		/**
		 * Map of all current documents (excluding deleted, voided, and archived documents)
		 * where the key is the document id and the value is an IDocument.
		 */
		public function get currentDocumentsById():HashMap
		{
			return _currentDocumentsById;
		}

		/**
		 * Map of all documents that are part of the record where the key is the document id (only existing, persisted
		 * documents are included) and the value is an IDocument.
		 */
		public function get originalDocumentsById():HashMap
		{
			return _originalDocumentsById;
		}

		/**
		 * Adds the document to the record. The record will keep track of the document (indexed by id) and also add
		 * the document to the appropriate document collection (model) class.
		 * <p>
		 * If document.pendingAction is null, the document will be considered a persisted part of the record (a subsequent
		 * deletion/void/archive operation will remove the document from the "current" but not the "original" list of
		 * documents, so that the operation can be persisted or reverted at a later time). Note that, if the document is
		 * added during collaboration, the document.pendingAction is null. It is still considered a persisted part of the
		 * record. There is the possibility that the initiating client, which is supposed to persist the document, will
		 * fail to do so. This case needs to be handled in the future.
		 * <p>
		 * If document.pendingAction is DocumentBase.ACTION_CREATE, the document will
		 * be considered part of the "current" list of documents, but if subsequently deleted (before being persisted)
		 * it will be completely gone.
		 *
		 * @param document The document to add to the record.
		 * @param persist If true, the pending action for the document will be set to DocumentBase.ACTION_CREATE. Otherwise
		 * whether or not the document is persisted on a save operation will depend on the value of document.pendingAction set outside of
		 * this method. Persist is set to false in collaboration on the receiving client since the change is persisted
		 * by the initiating client.
		 */
		// TODO: Deal with the case that the document is added during collaboration, and is considered a persisted part
		// of the record by the receiving client, but the sending client never persists the document.
		public function addDocument(document:IDocument, persist:Boolean = false):void
		{
			if (document.meta.type == null)
				throw new Error("The type of the document must be set when it is created. A document cannot be deleted if no type is specified.");

			var documentCollection:DocumentCollectionBase = documentCollections.getItem(document.meta.type);
			if (!documentCollection)
				throw new Error("Failed to get document collection for document type " + document.meta.type);

			if (persist)
				document.pendingAction = DocumentBase.ACTION_CREATE;

			// we rely on the document.pendingAction flag to indicate if the document is being loaded from the server
			if (document.pendingAction == null)
			{
				originalDocumentsById.put(document.meta.id, document);
			}
			else if (document.pendingAction == DocumentBase.ACTION_CREATE)
			{
				if (document.meta.id == null)
				{
					document.meta.id = UIDUtil.createUID();
				}
			}
			else
			{
				throw new Error("Attempted to add a document with an invalid value for pendingAction: " +
						document.pendingAction);
			}

			completeDocumentsById.put(document.meta.id, document);
			currentDocumentsById.put(document.meta.id, document);

			documentCollection.addDocument(document);

			updateReplacedBy(document);
		}

		private function updateReplacedBy(document:IDocument):void
		{
			if (document.meta.replacedById != null)
			{
				document.meta.replacedBy = currentDocumentsById.getItem(document.meta.replacedById);
			}
		}

		/**
		 * Removes the document to the record.
		 *
		 * @param document The document to remove from the record.
		 * @param persist If true, the pendingAction for the document will be set to the removeAction specified. Otherwise the
		 * document is removed from the record, but the pendingAction is not set. Persist is set to false in collaboration
		 * on the receiving client since the change is persisted by the initiating client.
		 * @param recursive If true, all documents that the document "relatesTo" will also be removed.
		 * @param removeAction If persist is true, this remove action will be used in persisting the removal of the
		 * document. The options are DocumentBase.ACTION_DELETE, DocumentBase.ACTION_VOID, DocumentBase.ACTION_ARCHIVE.
		 * @param reason A string describing the reason that the document was removed. This is only used in persisting
		 * the removal.
		 */
		public function removeDocument(document:IDocument, persist:Boolean = false, recursive:Boolean = false,
									   removeAction:String = DocumentBase.ACTION_DELETE, reason:String = null):int
		{
			if (recursive)
				return removeDocumentAndDescendants(document, persist, removeAction, reason);
			else
				return removeOneDocument(document, persist, removeAction, reason);
		}

		private function removeOneDocument(document:IDocument, persist:Boolean, removeAction:String, reason:String):int
		{
			if (document.meta.type == null)
				throw new Error("The type of the document must be set when it is created. A document cannot be deleted if no type is specified.");

			var documentCollection:DocumentCollectionBase = documentCollections.getItem(document.meta.type);
			if (!documentCollection)
				throw new Error("Failed to get document collection for document type " + document.meta.type);

			var expectDocumentInCollections:Boolean = true;

			if (document.pendingAction == DocumentBase.ACTION_DELETE ||
					document.pendingAction == DocumentBase.ACTION_ARCHIVE ||
					document.pendingAction == DocumentBase.ACTION_VOID)
			{
				// no changes should be required to the collections, but check to be sure
				expectDocumentInCollections = false;
			}

			// Remove the relationships before removing the document from the appropriate collections so that anyone
			// listening to collection change events will not see misleading relationships still in place when
			// the collection change event has just been fired.
			removeNewRelationshipsForDocument(document);
			document.clearRelationships();

			documentCollection.removeDocument(document);

			if (currentDocumentsById.getItem(document.meta.id) != null)
			{
				// TODO: warn if document was found but should have already been removed from the record
//				if (expectDocumentInCollections)
//					_logger.warn("Document should have already been removed from the record (pendingAction = " + document.pendingAction + "), but was in currentDocumentsById");
				currentDocumentsById.remove(document.meta.id);
			}

			if (document.pendingAction == DocumentBase.ACTION_CREATE)
			{
				// document was never persisted to the server, so just remove it from the completeDocumentsById and clear the pendingAction flag
				completeDocumentsById.remove(document.meta.id);
				document.pendingAction = null;
				return 0;
			}
			else
			{
				if (persist)
				{
					document.pendingActionReason = reason;
					if (document.pendingAction != removeAction)
					{
						document.pendingAction = removeAction;
						return 1;
					}
					else
					{
						return 0;
					}
				}
				else
				{
					return 0;
				}
			}
		}

		private function removeNewRelationshipsForDocument(document:IDocument):void
		{
			for each (var relationship:Relationship in document.isRelatedFrom)
			{
				removeNewRelationship(relationship);
			}
			for each (relationship in document.relatesTo)
			{
				removeNewRelationship(relationship);
			}
		}

		private function removeDocumentAndDescendants(document:IDocument, persist:Boolean, removeAction:String,
													  reason:String):int
		{
			var deletedCount:int = 0;
			var documents:Vector.<IDocument> = new <IDocument>[document];
			do
			{
				var currentDocument:IDocument = documents.pop();
				for each (var relationship:Relationship in currentDocument.relatesTo)
				{
					if (relationship.relatesTo)
						documents.push(relationship.relatesTo);
				}

				deletedCount += removeOneDocument(currentDocument, persist, removeAction, reason);
			}
			while (documents.length > 0);

			return deletedCount;
		}

		public function get completeDocumentsById():HashMap
		{
			return _completeDocumentsById;
		}

		public function hasUnsavedChanges():Boolean
		{
			if (!storageService)
				throw new Error("The storageService must be provided to connect the record to a storage service before saveAllChanges can be used.");

			return storageService.hasUnsavedChanges(this);
		}

		public function saveAllChanges():void
		{
			if (!storageService)
				throw new Error("The storageService must be provided to connect the record to a storage service before saveAllChanges can be used.");

			storageService.saveAllChanges(this);
		}

		public function saveChanges(documents:ArrayCollection, relationships:ArrayCollection = null):void
		{
			if (!storageService)
				throw new Error("The storageService must be provided to connect the record to a storage service before saveChanges can be used.");

			storageService.saveChanges(this, documents, relationships);
		}

		public function get storageService():IRecordStorageService
		{
			return _storageService;
		}

		public function set storageService(value:IRecordStorageService):void
		{
			_storageService = value;
		}

		/**
		 * Adds a relationship to the record. The documents involved are also stitched.
		 *
		 * @param relationshipType The type of relationship between the two documents.
		 * @param fromDocument The document in the subject of the relationship.
		 * @param toDocument The document in the predicate of the relationship.
		 * @param persist If persist is true, the pendingAction for the relationship will be set to Relationship.ACTION_CREATE.
		 * Otherwise, whether or not the relationship will be persisted on a save operation will depend on the value of pendingAction
		 * set outside of this method to calling this method. Persist is set to false in collaboration on the receiving client
		 * since the change is persisted by the initiating client.
		 */
		public function addRelationship(relationshipType:String, fromDocument:DocumentBase, toDocument:DocumentBase,
										persist:Boolean = false):Relationship
		{
			if (!relationshipType)
				throw new ArgumentError("relationshipType must not be null");

			if (!fromDocument)
				throw new ArgumentError("fromDocument must not be null");

			if (!toDocument)
				throw new ArgumentError("toDocument must not be null");

			if (fromDocument == toDocument)
				throw new ArgumentError("fromDocument must be different than toDocument");

			var relationship:Relationship = new Relationship();
			relationship.type = relationshipType;
			relationship.relatesFrom = fromDocument;
			relationship.relatesTo = toDocument;

			fromDocument.relatesTo.addItem(relationship);
			toDocument.isRelatedFrom.addItem(relationship);

			if (persist)
			{
				relationship.pendingAction = Relationship.ACTION_CREATE;
				_newRelationships.addItem(relationship);
			}
			return relationship;
		}

		public function get newRelationships():ArrayCollection
		{
			return _newRelationships;
		}

		public function get isLoading():Boolean
		{
			return _isLoading;
		}

		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
		}

		public function get isSaving():Boolean
		{
			return _isSaving;
		}

		public function set isSaving(value:Boolean):void
		{
			_isSaving = value;
		}

		public function get hasConnectionErrorsSaving():Boolean
		{
			return _hasConnectionErrorsSaving;
		}

		public function set hasConnectionErrorsSaving(value:Boolean):void
		{
			_hasConnectionErrorsSaving = value;
		}

		public function get hasUnexpectedErrorsSaving():Boolean
		{
			return _hasUnexpectedErrorsSaving;
		}

		public function set hasUnexpectedErrorsSaving(value:Boolean):void
		{
			_hasUnexpectedErrorsSaving = value;
		}

		/**
		 * Removes a relationship from the newRelationships collection. This should be called after
		 * a relationship has been saved to the server and is no longer considered "new".
		 *
		 * @param relationship The relationship to remove.
		 */
		public function removeNewRelationship(relationship:Relationship):void
		{
			var index:int = newRelationships.getItemIndex(relationship);
			if (index != -1)
				newRelationships.removeItemAt(index);
		}

		public function get dateLoaded():Date
		{
			return _dateLoaded;
		}

		public function set dateLoaded(value:Date):void
		{
			_dateLoaded = value;
		}

		public function get healthActionPlansModel():HealthActionPlansModel
		{
			return _healthActionPlansModel;
		}

		public function set healthActionPlansModel(value:HealthActionPlansModel):void
		{
			_healthActionPlansModel = value;
			addDocumentCollection(value);
		}

		public function get healthActionResultsModel():HealthActionResultsModel
		{
			return _healthActionResultsModel;
		}

		public function set healthActionResultsModel(value:HealthActionResultsModel):void
		{
			_healthActionResultsModel = value;
		}

		public function get healthActionOccurrencesModel():HealthActionOccurrencesModel
		{
			return _healthActionOccurrencesModel;
		}

		public function set healthActionOccurrencesModel(value:HealthActionOccurrencesModel):void
		{
			_healthActionOccurrencesModel = value;
		}

		public function get ownerAccountId():String
		{
			return _ownerAccountId;
		}

		public function set ownerAccountId(value:String):void
		{
			_ownerAccountId = value;
		}
	}
}
