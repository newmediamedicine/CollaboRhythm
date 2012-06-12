package collaboRhythm.core.model.healthRecord
{

	import collaboRhythm.core.model.healthRecord.service.AdherenceItemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.core.model.healthRecord.service.EquipmentHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.HealthActionOccurrencesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.HealthActionPlansHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.HealthActionResultsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.HealthActionSchedulesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.HealthChartsInitializationService;
	import collaboRhythm.core.model.healthRecord.service.MedicationAdministrationsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationFillsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationOrdersHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationScheduleItemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MessagesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.ProblemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.SaveChangesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.VideoMessagesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.VitalSignHealthRecordService;
	import collaboRhythm.core.model.healthRecord.stitchers.AdherenceItemStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.EquipmentStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.HealthActionOccurrenceStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.HealthActionPlanStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.HealthActionScheduleStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.MedicationOrderStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.MedicationScheduleItemStitcher;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.IRecordStorageService;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.IDocumentStitcher;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import com.adobe.utils.DateUtil;

	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Bindable]
	public class HealthRecordServiceFacade implements IRecordStorageService
	{
		private const IS_DUPLICATE_DETECTION_ENABLED:Boolean = true;
		private const VOID_ALL_DUPLICATES:Boolean = false;
		protected var _logger:ILogger;
		private var _services:Vector.<DocumentStorageServiceBase>;
		private var _stitchers:Vector.<IDocumentStitcher>;
		private var _pendingServices:ArrayCollection = new ArrayCollection();
		private var _adherenceItemsHealthRecordService:AdherenceItemsHealthRecordService;
		private var _saveChangesHealthRecordService:SaveChangesHealthRecordService;
		private var _isLoading:Boolean;
		private var _currentRecord:Record;
		private var _isSaving:Boolean;
		private var _hasConnectionErrorsSaving:Boolean;
		private var _hasUnexpectedErrorsSaving:Boolean;
		protected var _currentDateSource:ICurrentDateSource;

		public function HealthRecordServiceFacade(consumerKey:String, consumerSecret:String, baseURL:String,
												  activeAccount:Account, activeRecordAccount:Account,
												  debuggingToolsEnabled:Boolean)
		{
			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_saveChangesHealthRecordService = new SaveChangesHealthRecordService(consumerKey, consumerSecret, baseURL,
					activeAccount, this);
			_adherenceItemsHealthRecordService = new AdherenceItemsHealthRecordService(consumerKey, consumerSecret,
					baseURL, activeAccount,
					debuggingToolsEnabled);

			_services = new Vector.<DocumentStorageServiceBase>();
			addService(new ProblemsHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new MedicationAdministrationsHealthRecordService(consumerKey, consumerSecret, baseURL,
					activeAccount,
					debuggingToolsEnabled));
			addService(new MedicationOrdersHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new EquipmentHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new HealthActionSchedulesHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new MedicationScheduleItemsHealthRecordService(consumerKey, consumerSecret, baseURL,
					activeAccount,
					debuggingToolsEnabled));
			addService(new VitalSignHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new VideoMessagesHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new MedicationFillsHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new HealthActionPlansHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));
			addService(new HealthActionResultsHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
																		  debuggingToolsEnabled));
			addService(new HealthActionOccurrencesHealthRecordService(consumerKey, consumerSecret, baseURL, activeAccount,
																		  debuggingToolsEnabled));
			var messagesHealthRecordService:MessagesHealthRecordService = new MessagesHealthRecordService(consumerKey,
					consumerSecret, baseURL,
					activeAccount, debuggingToolsEnabled,
					Message.DOCUMENT_TYPE, Message, Schemas.MessageSchema);
			messagesHealthRecordService.activeRecordAccount = activeRecordAccount;
			addService(messagesHealthRecordService);
			addService(_adherenceItemsHealthRecordService);
			addService(new HealthChartsInitializationService(consumerKey, consumerSecret, baseURL, activeAccount,
					debuggingToolsEnabled));

			for each (var service:DocumentStorageServiceBase in _services)
			{
				service.addEventListener(DocumentStorageServiceBase.IS_LOADING_CHANGE_EVENT,
						service_isLoadingChangeHandler, false, 0, true);
			}
		}

		private function addService(service:DocumentStorageServiceBase):void
		{
			_services.push(service);
		}

		public function getService(documentType:String):DocumentStorageServiceBase
		{
			for each (var service:DocumentStorageServiceBase in _services)
			{
				if (service.targetDocumentType == documentType)
					return service;
			}
			throw new Error("Failed to find a service for document type " + documentType);
		}

		private function createStitchers(record:Record):void
		{
			_stitchers = new Vector.<IDocumentStitcher>();
			_stitchers.push(new MedicationOrderStitcher(record));
			_stitchers.push(new MedicationScheduleItemStitcher(record));
			_stitchers.push(new EquipmentStitcher(record));
			_stitchers.push(new HealthActionScheduleStitcher(record));
			_stitchers.push(new AdherenceItemStitcher(record));
			_stitchers.push(new HealthActionPlanStitcher(record));
			_stitchers.push(new HealthActionScheduleStitcher(record));
			_stitchers.push(new HealthActionOccurrenceStitcher(record));

			for each (var stitcher:IDocumentStitcher in _stitchers)
			{
				stitcher.listenForPrerequisites();
			}
		}

		public function get isLoading():Boolean
		{
			return _isLoading;
		}

		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
			if (currentRecord)
				currentRecord.isLoading = value;
		}

		/**
		 * Loads all supported documents for the Record and initializes any XML marshallers on the associated models.
		 * @param record
		 */
		public function loadDocuments(record:Record):void
		{
			if (!record)
				throw new ArgumentError("record is null");

			if (isLoading)
			{
				// TODO: how to prevent this or at least provide feedback to the user?
				_logger.warn("Attempted to load documents while loading was already in progress (or failed to complete). Loading canceled.");
				return;
			}

			_currentRecord = record;
			record.storageService = this;

			isLoading = true;
			_logger.info("Loading documents " + loadingMessageSuffix + "...");

			record.adherenceItemsModel.adherenceItemXmlMarshaller = _adherenceItemsHealthRecordService;

			createStitchers(record);

			for each (var service:DocumentStorageServiceBase in _services)
			{
				// TODO: what if the service is already in the middle of loading? Error? Cancel/stop loading that was in progress?
				service.loadDocuments(record);
				if (service.isLoading)
					_pendingServices.addItem(service);
			}

			updateIsLoading();
		}

		private function service_isLoadingChangeHandler(event:Event):void
		{
			var service:DocumentStorageServiceBase = event.currentTarget as DocumentStorageServiceBase;
			if (!service)
				throw new Error("PropertyChangeEvent currentTarget must be a DocumentStorageService");

			if (!service.isLoading)
			{
				if (_pendingServices.contains(service))
				{
					_pendingServices.removeItemAt(_pendingServices.getItemIndex(service));
				}
				updateIsLoading();
			}
		}

		private function updateIsLoading():void
		{
			if (_pendingServices.length == 0)
			{
				checkForDuplicates();

				// TODO: loading is complete, but we are not distinguishing between failed/complete results for each service; some may have failed
				_logger.info("Loading documents COMPLETE. " + _currentRecord.currentDocumentsById.size() +
						" documents loaded " + loadingMessageSuffix);
				_currentRecord.dateLoaded = _currentDateSource.now();
				isLoading = false;
			}
			else
			{
				_logger.info("Loading documents in progress. " + _pendingServices.length + " service(s) pending: " +
						getServiceNamesFromCollection(_pendingServices));
			}
		}

		private function checkForDuplicates():void
		{
			if (IS_DUPLICATE_DETECTION_ENABLED)
			{
				var documentsToDelete:ArrayCollection = new ArrayCollection();
				var documentsCount:int = 0;
				var startTime:Number = (new Date()).valueOf();

				for each (var service:DocumentStorageServiceBase in _services)
				{
					var documentType:String = service.targetDocumentType;
					if (documentType)
					{
						var documentCollection:DocumentCollectionBase = currentRecord.documentCollections.getItem(documentType);

						// assume that duplicates will be consecutive
						var previousDocument:DocumentBase = null;
						var previousDocumentXmlString:String = null;
						for each (var document:DocumentBase in documentCollection.documents)
						{
							documentsCount++;
							var documentXmlString:String = service.marshallToXml(document);
							if (previousDocument)
							{
								if (documentXmlString == previousDocumentXmlString)
								{
									// duplicate detected; delete oldest
									documentsToDelete.addItem(deleteOlderDocument(document, previousDocument));
								}
							}
							previousDocument = document;
							previousDocumentXmlString = documentXmlString;
						}
					}
				}

				var elapsedTime:Number = (new Date()).valueOf() - startTime;
				var messageSuffix:String = " Checked " + documentsCount + " documents in " + elapsedTime + " ms.";
				if (documentsToDelete.length > 0)
					_logger.warn("DUPLICATES --- Detected " + documentsToDelete.length + " duplicate documents" +
							(VOID_ALL_DUPLICATES ? " and marked them for deletion (void)" : " but left them untouched") +
							"." + messageSuffix);
				else
					_logger.info("No duplicates detected." + messageSuffix);
			}
		}

		private function deleteOlderDocument(document1:DocumentBase, document2:DocumentBase):DocumentBase
		{
			var documentToDelete:DocumentBase;
			var documentToKeep:DocumentBase;

			//TODO: determine if messages should not be treated as documents and therefore this check can be removed
			//messages don't have meta data, so check to see if there is meta data first
			if (document1.meta.createdAt && document2.meta.createdAt)
			{
				if (document1.meta.createdAt.valueOf() < document2.meta.createdAt.valueOf())
				{
					documentToDelete = document1;
					documentToKeep = document2;
				}
				else
				{
					documentToDelete = document2;
					documentToKeep = document1;
				}

				_logger.warn("  Duplicate detected: " + documentToDelete.meta.type + " " +
						documentToDelete.meta.id + " created " + DateUtil.toW3CDTF(documentToDelete.meta.createdAt) +
						" is older than " +
						documentToKeep.meta.id + " created " + DateUtil.toW3CDTF(documentToKeep.meta.createdAt));

				if (VOID_ALL_DUPLICATES)
					currentRecord.removeDocument(documentToDelete, DocumentBase.ACTION_VOID,
							"automatic duplicate detection", true);
			}

			return documentToDelete;
		}

		private function get loadingMessageSuffix():String
		{
			return "using " + _services.length + " document storage " +
					(_services.length == 1 ? "service" : "services") + " (" + getServiceNames(_services) + ")";
		}

		private function getServiceNames(services:Vector.<DocumentStorageServiceBase>):String
		{
			var names:Array = new Array();
			for each (var service:DocumentStorageServiceBase in services)
			{
				var parts:Array = getQualifiedClassName(service).split("::");
				names.push(parts[parts.length - 1]);
			}
			return names.join(", ");
		}

		private function getServiceNamesFromCollection(services:ArrayCollection):String
		{
			var names:Array = new Array();
			for each (var service:DocumentStorageServiceBase in services)
			{
				var parts:Array = getQualifiedClassName(service).split("::");
				names.push(parts[parts.length - 1]);
			}
			return names.join(", ");
		}

		/**
		 * Resets the connection error change set. This should generally be called after isSaving becomes false and the
		 * user chooses to retry the saving operation.
		 */
		public function resetConnectionErrorChangeSet():void
		{
			_saveChangesHealthRecordService.resetConnectionErrorsChangeSet();
		}

		/**
		 * Resets the unexpected error change set. This should generally be called after isSaving becomes false and the
		 * user chooses to ignore the saving operation.
		 */
		public function resetUnexpectedErrorChangeSet():void
		{
			_saveChangesHealthRecordService.resetUnexpectedErrorChangeSet();
		}

		public function saveChanges(record:Record, documents:ArrayCollection, relationships:ArrayCollection = null):void
		{
			_saveChangesHealthRecordService.saveChanges(record, documents, relationships);
		}

		public function saveAllChanges(record:Record):void
		{
			_saveChangesHealthRecordService.saveAllChanges(record);
		}

		public function get currentRecord():Record
		{
			return _currentRecord;
		}

		public function get isSaving():Boolean
		{
			return _isSaving;
		}

		public function set isSaving(value:Boolean):void
		{
			_isSaving = value;
			if (currentRecord)
				currentRecord.isSaving = value;
		}

		public function get hasConnectionErrorsSaving():Boolean
		{
			return _hasConnectionErrorsSaving;
		}

		public function set hasConnectionErrorsSaving(value:Boolean):void
		{
			_hasConnectionErrorsSaving = value;
			if (currentRecord)
				currentRecord.hasConnectionErrorsSaving = value;
		}

		public function get hasUnexpectedErrorsSaving():Boolean
		{
			return _hasUnexpectedErrorsSaving;
		}

		public function set hasUnexpectedErrorsSaving(value:Boolean):void
		{
			_hasUnexpectedErrorsSaving = value;
			if (currentRecord)
				currentRecord.hasUnexpectedErrorsSaving = value;
		}

		public function resetErrorChangeSets():void
		{
			resetConnectionErrorChangeSet();
			resetUnexpectedErrorChangeSet();
		}

		public function get connectionErrorsSavingSummary():String
		{
			return _saveChangesHealthRecordService.connectionErrorsSummary;
		}

		public function get unexpectedErrorsSavingSummary():String
		{
			return _saveChangesHealthRecordService.unexpectedErrorsSummary;
		}

		public function get errorsSavingSummary():String
		{
			return _saveChangesHealthRecordService.errorsSavingSummary;
		}

		public function closeRecord():void
		{
			_currentRecord = null;
			for each (var service:DocumentStorageServiceBase in _services)
			{
				service.closeRecord();
			}
		}
	}
}
