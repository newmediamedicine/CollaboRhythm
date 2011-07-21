package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.IDocumentCollection;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	/**
	 * Service class for simple scenarios where a single report is used to load all of the documents of a given type.
	 */
	public class DocumentStorageSingleReportServiceBase extends DocumentStorageServiceBase
	{
		protected var _indivoReportName:String;

		public function DocumentStorageSingleReportServiceBase(consumerKey:String, consumerSecret:String, baseURL:String,
												   account:Account, targetDocumentType:String,
												   targetClass:Class, targetDocumentSchema:Class, indivoReportName:String)
		{
			super(consumerKey, consumerSecret, baseURL, account, targetDocumentType, targetClass, targetDocumentSchema);
			_indivoReportName = indivoReportName;
		}

		override public function loadDocuments(record:Record):void
		{
			super.loadDocuments(record);

			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails("reports_minimal_X_GET", null, record, indivoReportName);
			_pha.reports_minimal_X_GET(null, null, null, null, record.id, indivoReportName, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
		}

		/**
		 * The name of the report, such as "equipment", for making a request to Indivo for a minimal report,
		 * GET /records/{record_id}/reports/minimal/{report}/
		 */
		protected function get indivoReportName():String
		{
			return _indivoReportName;
		}

		override protected function handleResponse(event:IndivoClientEvent, responseXml:XML,
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
				var collection:ArrayCollection = parseReportsXml(responseXml);
				for each (var document:IDocument in collection)
				{
					record.addDocument(document);
				}
			}

			var documentCollection:IDocumentCollection = record.documentCollections.getItem(targetDocumentType);
			if (documentCollection == null)
				throw new Error("Failed to get the document collection for document type " + targetDocumentType);

			documentCollection.isInitialized = true;

			isLoading = false;
		}
	}
}
