package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import flash.net.URLVariables;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	import spark.collections.Sort;
	import spark.collections.SortField;

	/**
	 * Service class for simple scenarios where a single report is used to load all of the documents of a given type.
	 */
	public class DocumentStorageSingleReportServiceBase extends DocumentStorageServiceBase
	{
		protected var _indivoReportName:String;
		protected var _orderByField:String;
		protected var _limit:int;
		protected var _sortField:String;

		/**
		 * Constructor for DocumentStorageSingleReportServiceBase
		 * @param consumerKey
		 * @param consumerSecret
		 * @param baseURL
		 * @param account
		 * @param debuggingToolsEnabled
		 * @param targetDocumentType
		 * @param targetClass
		 * @param targetDocumentSchema
		 * @param indivoReportName
		 * @param orderByField
		 * @param limit Maximum number of documents to retrieve. Note that paging is not (yet) being used so all
		 * documents must be returned in one large report. 
		 * @param sortField If there is a server-side problem with sorting using the orderByField, the sortField can
		 * be specified and the collection of documents will be sorted by this field after the data is parsed.
		 */
		public function DocumentStorageSingleReportServiceBase(consumerKey:String, consumerSecret:String, baseURL:String,
															   account:Account, debuggingToolsEnabled:Boolean,
															   targetDocumentType:String, targetClass:Class, targetDocumentSchema:Class,
															   indivoReportName:String,
															   orderByField:String = null,
															   limit:int = 1000,
															   sortField:String = null)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, targetDocumentType, targetClass,
				  targetDocumentSchema);
			_indivoReportName = indivoReportName;
			_orderByField = orderByField;
			_limit = limit;
			_sortField = sortField;
		}

		override public function loadDocuments(record:Record):void
		{
			super.loadDocuments(record);

			var params:URLVariables = new URLVariables();
			if (_orderByField)
				params["order_by"] = _orderByField;
			if (_limit >= 0)
				params["limit"] = _limit;
			
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_REPORTS_MINIMAL, null, record, indivoReportName);
			_pha.reports_minimal_X_GET(params, null, null, null, record.id, indivoReportName, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
			_pendingReportRequests.put(PRIMARY_REPORT_REQUEST, PRIMARY_REPORT_REQUEST);
		}

		/**
		 * The name of the report, such as "equipment", for making a request to Indivo for a minimal report,
		 * GET /records/{record_id}/reports/minimal/{report}/
		 */
		protected function get indivoReportName():String
		{
			return _indivoReportName;
		}

		override protected function handleReportResponse(event:IndivoClientEvent, responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var requestDetails:HealthRecordServiceRequestDetails = event.userData as HealthRecordServiceRequestDetails;
			if (requestDetails == null)
				throw new Error("userData must be a HealthRecordServiceRequestDetails object");

			var record:Record = requestDetails.record;
			if (record == null)
				throw new Error("userData.record must be a Record object");

			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			
			if (responseXml.Summary.length() != 1)
				throw new Error("Expected Summary element not found in " + _indivoReportName + " Indivo report.");
			
			var summaryXml:XML = responseXml.Summary[0];
			var totalDocumentCount:int = int(summaryXml.@total_document_count);
			var documentLimit:int = int(summaryXml.@limit);
			if (totalDocumentCount > documentLimit)
				_logger.warn("Some " + targetDocumentType + " documents from the " + indivoReportName +
						" Indivo report were not limit. Increase the limit in the service or add support for paging to ensure that all document are loaded.");

			var numDocuments:int = responseXml.Report.Item.elements(targetDocumentQName).length();
			if (numDocuments > 0)
			{
				var collection:ArrayCollection = parseReportsXml(record, responseXml);
				if (_sortField)
				{
					var sort:Sort = new Sort();
					sort.fields = [new SortField(_sortField)];
					collection.sort = sort;
					collection.refresh();
				}
	
				for each (var document:IDocument in collection)
				{
					record.addDocument(document);
				}
			}

			_pendingReportRequests.remove(PRIMARY_REPORT_REQUEST);
		}

	}
}
