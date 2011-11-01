package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	/**
	 * Service class for simple scenarios where a single report is used to load all of the documents of a given type.
	 */
	public class DocumentStorageSingleReportServiceBase extends DocumentStorageServiceBase
	{
		protected var _indivoReportName:String;

		public function DocumentStorageSingleReportServiceBase(consumerKey:String, consumerSecret:String, baseURL:String,
															   account:Account, debuggingToolsEnabled:Boolean,
															   targetDocumentType:String, targetClass:Class, targetDocumentSchema:Class,
															   indivoReportName:String)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, targetDocumentType, targetClass,
				  targetDocumentSchema);
			_indivoReportName = indivoReportName;
		}

		override public function loadDocuments(record:Record):void
		{
			super.loadDocuments(record);

			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_REPORTS_MINIMAL, null, record, indivoReportName);
			_pha.reports_minimal_X_GET(null, null, null, null, record.id, indivoReportName, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
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
			if (responseXml.Report.Item.elements(targetDocumentQName).length() > 0)
			{
				var collection:ArrayCollection = parseReportsXml(record, responseXml);
				for each (var document:IDocument in collection)
				{
					record.addDocument(document);
				}
			}

			_pendingReportRequests.remove(PRIMARY_REPORT_REQUEST);
			checkPendingRequests(record);
		}

	}
}
