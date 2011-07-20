package collaboRhythm.core.model.healthRecord
{

	import collaboRhythm.core.model.healthRecord.service.AdherenceItemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.core.model.healthRecord.service.EquipmentHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.EquipmentScheduleItemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationAdministrationsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationFillsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationOrdersHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.MedicationScheduleItemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.ProblemsHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.SaveChangesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.VideoMessagesHealthRecordService;
	import collaboRhythm.core.model.healthRecord.service.VitalSignHealthRecordService;
	import collaboRhythm.core.model.healthRecord.stitchers.MedicationOrderStitcher;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.core.model.healthRecord.stitchers.AdherenceItemStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.EquipmentScheduleItemStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.EquipmentStitcher;
	import collaboRhythm.core.model.healthRecord.stitchers.MedicationScheduleItemStitcher;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.IDocumentStitcher;

	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class HealthRecordServiceFacade
	{
		protected var _logger:ILogger;
		private var _services:Vector.<DocumentStorageServiceBase>;
		private var _stitchers:Vector.<IDocumentStitcher>;
		private var _pendingServices:ArrayCollection = new ArrayCollection();
		private var _adherenceItemsHealthRecordService:AdherenceItemsHealthRecordService;
		private var _saveChangesHealthRecordService:SaveChangesHealthRecordService;
		private var _isLoading:Boolean;

		public function HealthRecordServiceFacade(consumerKey:String, consumerSecret:String, baseURL:String,
												  account:Account)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));
			_saveChangesHealthRecordService = new SaveChangesHealthRecordService(consumerKey, consumerSecret, baseURL,
																				 account);
			_adherenceItemsHealthRecordService = new AdherenceItemsHealthRecordService(consumerKey, consumerSecret,
																					   baseURL, account);

			_services = new Vector.<DocumentStorageServiceBase>();
			addService(new MedicationAdministrationsHealthRecordService(consumerKey, consumerSecret, baseURL,
																			account));
			addService(new MedicationOrdersHealthRecordService(consumerKey, consumerSecret, baseURL,
																			account));
			addService(new EquipmentHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(new EquipmentScheduleItemsHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(new MedicationScheduleItemsHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(new VitalSignHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(new ProblemsHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(new VideoMessagesHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(new MedicationFillsHealthRecordService(consumerKey, consumerSecret, baseURL, account));
			addService(_adherenceItemsHealthRecordService);

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

		private function createStitchers(record:Record):void
		{
			_stitchers = new Vector.<IDocumentStitcher>();
			_stitchers.push(new MedicationOrderStitcher(record));
			_stitchers.push(new MedicationScheduleItemStitcher(record));
			_stitchers.push(new EquipmentStitcher(record));
			_stitchers.push(new EquipmentScheduleItemStitcher(record));
			_stitchers.push(new AdherenceItemStitcher(record));

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
				// TODO: loading is complete, but we are not distinguishing between failed/complete results for each service; some may have failed
				_logger.info("Loading documents COMPLETE " + loadingMessageSuffix);
				isLoading = false;
			}
			else
			{
				_logger.info("Loading documents in progress. " + _pendingServices.length + " service(s) pending: " + getServiceNamesFromCollection(_pendingServices));

			}
		}

		private function get loadingMessageSuffix():String
		{
			return "using " + _services.length + " document storage " + (_services.length == 1 ? "service" : "services") + " (" + getServiceNames(_services) + ")";
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

		public function saveChanges(record:Record):void
		{
			_saveChangesHealthRecordService.saveChanges(record);
		}
	}
}
