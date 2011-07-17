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
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;
	import collaboRhythm.shared.model.settings.Settings;

	import j2as3.collection.HashMap;

	import mx.utils.UIDUtil;

	[Bindable]
    public class Record implements IRecord
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
        private var _settings:Settings;
        private var _activeAccount:Account;
		private var _vitalSignsModel:VitalSignsModel;

		// TODO: move BloodPressureModel to blood pressure plugin; eliminate bloodPressureModel property and field; use appData instead
		private var _bloodPressureModel:BloodPressureModel;

        public function Record(settings:Settings, activeAccount:Account, recordXml:XML)
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            _settings = settings;
            _activeAccount = activeAccount;
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
			medicationOrdersModel = new MedicationOrdersModel(_settings, _activeAccount, this);
            medicationFillsModel = new MedicationFillsModel(_settings, _activeAccount, this);
            medicationScheduleItemsModel = new MedicationScheduleItemsModel(_settings, _activeAccount, this);
            medicationAdministrationsModel = new MedicationAdministrationsModel();
            equipmentModel = new EquipmentModel(_settings, _activeAccount, this);
            equipmentScheduleItemsModel = new EquipmentScheduleItemsModel(_settings, _activeAccount, this);
            adherenceItemsModel = new AdherenceItemsModel();
            videoMessagesModel = new VideoMessagesModel(_settings, _activeAccount, this);
            problemsModel = new ProblemsModel(_settings, _activeAccount, this);
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
			documentCollections[documentCollection.documentType] = documentCollection;
		}

        public function getDocuments():void
        {
            _medicationOrdersModel.getMedicationOrders();
            _medicationFillsModel.getMedicationFills();
            _medicationScheduleItemsModel.getMedicationScheduleItems();
            _equipmentModel.getEquipment();
            _equipmentScheduleItemsModel.getEquipmentScheduleItems();
            _videoMessagesModel.getVideoMessages();
            _problemsModel.getProblems();
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
			_documentCollections["Equipment"] = value;
        }

        public function get adherenceItemsModel():AdherenceItemsModel
        {
            return _adherenceItemsModel;
        }

        public function set adherenceItemsModel(value:AdherenceItemsModel):void
        {
            _adherenceItemsModel = value;
			_documentCollections["AdherenceItem"] = value;
        }

        public function get videoMessagesModel():VideoMessagesModel
        {
            return _videoMessagesModel;
        }

        public function set videoMessagesModel(value:VideoMessagesModel):void
        {
            _videoMessagesModel = value;
			_documentCollections["VideoMessage"] = value;
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
			_documentCollections["Problem"] = value;
        }

        public function get medicationOrdersModel():MedicationOrdersModel
        {
            return _medicationOrdersModel;
        }

        public function set medicationOrdersModel(value:MedicationOrdersModel):void
        {
            _medicationOrdersModel = value;
			_documentCollections["MedicationOrder"] = value;
        }

        public function get medicationFillsModel():MedicationFillsModel
        {
            return _medicationFillsModel;
        }

        public function set medicationFillsModel(value:MedicationFillsModel):void
        {
            _medicationFillsModel = value;
			_documentCollections["MedicationFill"] = value;
        }

        public function get medicationScheduleItemsModel():MedicationScheduleItemsModel
        {
            return _medicationScheduleItemsModel;
        }

        public function set medicationScheduleItemsModel(value:MedicationScheduleItemsModel):void
        {
            _medicationScheduleItemsModel = value;
			_documentCollections["MedicationScheduleItem"] = value;
        }

        public function get medicationAdministrationsModel():MedicationAdministrationsModel
        {
            return _medicationAdministrationsModel;
        }

        public function set medicationAdministrationsModel(value:MedicationAdministrationsModel):void
        {
            _medicationAdministrationsModel = value;
			_documentCollections[value.documentType] = value;
        }

        public function get equipmentScheduleItemsModel():EquipmentScheduleItemsModel
        {
            return _equipmentScheduleItemsModel;
        }

        public function set equipmentScheduleItemsModel(value:EquipmentScheduleItemsModel):void
        {
            _equipmentScheduleItemsModel = value;
			_documentCollections["EquipmentScheduleItem"] = value;
        }

		public function get vitalSignsModel():VitalSignsModel
		{
			return _vitalSignsModel;
		}

		public function set vitalSignsModel(value:VitalSignsModel):void
		{
			_vitalSignsModel = value;
			_documentCollections["VitalSign"] = value;
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

		public function get settings():Settings
		{
			return _settings;
		}

		public function set settings(value:Settings):void
		{
			_settings = value;
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
		 *
		 * @param document The document to add to the record
		 * @param isLoading If true, the document will be considered a persisted part of the record (a subsequent
		 * deletion/void/archive operation will remove the document from the "current" but not the "original" list of
		 * documents, so that the operation can be persisted or reverted at a later time). If false, the document will
		 * be considered part of the "current" list of documents, but if subsequently deleted (before being persisted)
		 * it will be completely gone.
		 */
		public function addDocument(document:IDocument, isLoading:Boolean=false):void
		{
			// TODO: perhaps we should rely on the document.pendingAction flag instead of isLoading
			if (document.pendingAction == null)
			{
				originalDocumentsById[document.id] = document;
			}
			else if (document.pendingAction = DocumentBase.ACTION_CREATE)
			{
				if (document.id == null)
				{
					document.id = UIDUtil.createUID();
				}
			}
			else
			{
				throw new Error("Attempted to add a document with an invalid value for pendingAction: " + document.pendingAction);
			}

			completeDocumentsById[document.id] = document;
			currentDocumentsById[document.id] = document;

			var documentCollection:DocumentCollectionBase = documentCollections.getItem(document.type);
			if (!documentCollection)
				throw new Error("Failed to get document collection for document type " + document.type);

			documentCollection.addDocument(document);
		}

		public function deleteDocument(document:IDocument, deleteAction:String=DocumentBase.ACTION_DELETE, reason:String=null, recursive:Boolean=false):int
		{
			if (recursive)
				return deleteDocumentAndDescendants(document, deleteAction, reason);
			else
				return deleteOneDocument(document, deleteAction, reason);
		}

		private function deleteOneDocument(document:IDocument, deleteAction:String, reason:String):int
		{
			if (document.pendingAction == DocumentBase.ACTION_DELETE || document.pendingAction == DocumentBase.ACTION_ARCHIVE || document.pendingAction == DocumentBase.ACTION_VOID)
			{
				// do nothing
			}
			else if (document.pendingAction == DocumentBase.ACTION_CREATE)
			{
				currentDocumentsById.remove(document.id);
			}
			document.pendingAction = deleteAction;
			document.pendingActionReason = reason;
			return 1;
		}

		private function deleteDocumentAndDescendants(document:IDocument, deleteAction:String, reason:String):int
		{
			var deletedCount:int = 0;
			var documents:Vector.<IDocument> = new <IDocument>[document];
			do
			{
				var currentDocument:IDocument = documents.pop();
				for each (var relationship:Relationship in currentDocument.relatesTo)
				{
					documents.push(relationship.relatesTo);
				}

				deletedCount += deleteOneDocument(currentDocument, deleteAction, reason);
			}
			while (documents.length > 0);

			return deletedCount;
		}

		public function get completeDocumentsById():HashMap
		{
			return _completeDocumentsById;
		}
	}
}
