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

	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
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
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFillsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrdersModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.ProblemsModel;
	import collaboRhythm.shared.model.healthRecord.document.VideoMessagesModel;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;

	[Bindable]
    public class Record implements IRecord, IRecordProxy
    {
        private var _id:String;
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
		private var _equipmentScheduleItemsModel:EquipmentScheduleItemsModel;
        private var _adherenceItemsModel:AdherenceItemsModel;
        private var _videoMessagesModel:VideoMessagesModel;
        private var _problemsModel:ProblemsModel;
        private var _appData:HashMap = new HashMap();
		private var _vitalSignsModel:VitalSignsModel;
		private var _newRelationships:ArrayCollection = new ArrayCollection(); // of Relationship instances that have not been persisted

		// TODO: move BloodPressureModel to blood pressure plugin; eliminate bloodPressureModel property and field; use appData instead
		private var _bloodPressureModel:BloodPressureModel;
		private var _storageService:IRecordStorageService;

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
			medicationOrdersModel = new MedicationOrdersModel();
            medicationFillsModel = new MedicationFillsModel();
            medicationScheduleItemsModel = new MedicationScheduleItemsModel();
            medicationAdministrationsModel = new MedicationAdministrationsModel();
            equipmentModel = new EquipmentModel();
            equipmentScheduleItemsModel = new EquipmentScheduleItemsModel();
            adherenceItemsModel = new AdherenceItemsModel();
            videoMessagesModel = new VideoMessagesModel();
            problemsModel = new ProblemsModel();
			vitalSignsModel = new VitalSignsModel();

			documentCollections.clear();
			addDocumentCollection(medicationOrdersModel);
			addDocumentCollection(medicationFillsModel);
			addDocumentCollection(medicationScheduleItemsModel);
			addDocumentCollection(medicationAdministrationsModel);
			addDocumentCollection(equipmentModel);
			addDocumentCollection(equipmentScheduleItemsModel);
			addDocumentCollection(adherenceItemsModel);
			addDocumentCollection(videoMessagesModel);
			addDocumentCollection(problemsModel);
			addDocumentCollection(vitalSignsModel);
		}

		protected function addDocumentCollection(documentCollection:IDocumentCollection):void
		{
			documentCollection.recordProxy = this;
			documentCollections[documentCollection.documentType] = documentCollection;
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

        public function get videoMessagesModel():VideoMessagesModel
        {
            return _videoMessagesModel;
        }

        public function set videoMessagesModel(value:VideoMessagesModel):void
        {
            _videoMessagesModel = value;
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
				throw new Error("appData on Record does not contain a " + (type as Class).toString() + " for key " + key);
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

        public function get equipmentScheduleItemsModel():EquipmentScheduleItemsModel
        {
            return _equipmentScheduleItemsModel;
        }

        public function set equipmentScheduleItemsModel(value:EquipmentScheduleItemsModel):void
        {
            _equipmentScheduleItemsModel = value;
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

		// TODO: move BloodPressureModel to blood pressure plugin; eliminate bloodPressureModel property and field; use appData instead
		public function get bloodPressureModel():BloodPressureModel
		{
			return _bloodPressureModel;
		}

		public function set bloodPressureModel(value:BloodPressureModel):void
		{
			_bloodPressureModel = value;
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
		 * documents, so that the operation can be persisted or reverted at a later time).
		 * If document.pendingAction is DocumentBase.ACTION_CREATE, the document will
		 * be considered part of the "current" list of documents, but if subsequently deleted (before being persisted)
		 * it will be completely gone.
		 *
		 * @param document The document to add to the record.
		 * @param saveImmediately If true, a request will be made to persist the document to the server immediately;
		 * otherwise, the document will not be persisted until requested.
		 */
		public function addDocument(document:IDocument, saveImmediately:Boolean=false):void
		{
			if (document.meta.type == null)
				throw new Error("The type of the document must be set when it is created. A document cannot be deleted if no type is specified.");

			var documentCollection:DocumentCollectionBase = documentCollections.getItem(document.meta.type);
			if (!documentCollection)
				throw new Error("Failed to get document collection for document type " + document.meta.type);

			// we rely on the document.pendingAction flag to indicate if the document is being loaded from the server
			if (document.pendingAction == null)
			{
				originalDocumentsById[document.meta.id] = document;
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
				throw new Error("Attempted to add a document with an invalid value for pendingAction: " + document.pendingAction);
			}

			completeDocumentsById[document.meta.id] = document;
			currentDocumentsById[document.meta.id] = document;

			documentCollection.addDocument(document);

			if (saveImmediately)
			{
				if (!storageService)
					throw new Error("The storageService must be provided to connect the record to a storage service before addDocument with saveImmediately can be used.");

				storageService.saveChanges(this, new ArrayCollection(new Array(document)), null);
			}
		}

		public function removeDocument(document:IDocument, removeAction:String = DocumentBase.ACTION_DELETE,
									   reason:String = null, recursive:Boolean = false):int
		{
			if (recursive)
				return removeDocumentAndDescendants(document, removeAction, reason);
			else
				return removeOneDocument(document, removeAction, reason);
		}

		private function removeOneDocument(document:IDocument, removeAction:String, reason:String):int
		{
			if (document.meta.type == null)
				throw new Error("The type of the document must be set when it is created. A document cannot be deleted if no type is specified.");

			var documentCollection:DocumentCollectionBase = documentCollections.getItem(document.meta.type);
			if (!documentCollection)
				throw new Error("Failed to get document collection for document type " + document.meta.type);

			var expectDocumentInCollections:Boolean = true;

			if (document.pendingAction == DocumentBase.ACTION_DELETE || document.pendingAction == DocumentBase.ACTION_ARCHIVE || document.pendingAction == DocumentBase.ACTION_VOID)
			{
				// no changes should be required to the collections, but check to be sure
				expectDocumentInCollections = false;
			}

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
				completeDocumentsById.remove(document.meta.id);
			}

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

		private function removeDocumentAndDescendants(document:IDocument, removeAction:String, reason:String):int
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

				deletedCount += removeOneDocument(currentDocument, removeAction, reason);
			}
			while (documents.length > 0);

			return deletedCount;
		}

		public function get completeDocumentsById():HashMap
		{
			return _completeDocumentsById;
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

		public function addNewRelationship(relationshipType:String, fromDocument:DocumentBase,
										   toDocument:DocumentBase):Relationship
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
			relationship.pendingAction = Relationship.ACTION_CREATE;
			relationship.type = relationshipType;
			relationship.relatesFrom = fromDocument;
			relationship.relatesTo = toDocument;

			fromDocument.relatesTo.addItem(relationship);
			toDocument.isRelatedFrom.addItem(relationship);

			_newRelationships.addItem(relationship);
			return relationship;
		}

		public function get newRelationships():ArrayCollection
		{
			return _newRelationships;
		}
	}
}
