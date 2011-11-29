package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.RecurrenceRule;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;

	import org.indivo.client.IndivoClientEvent;

	public class ScheduleItemsHealthRecordServiceBase extends DocumentStorageSingleReportServiceBase
	{

		public function ScheduleItemsHealthRecordServiceBase(consumerKey:String, consumerSecret:String, baseURL:String,
															 account:Account, debuggingToolsEnabled:Boolean,
															 targetDocumentType:String, targetClass:Class, targetDocumentSchema:Class,
															 indivoReportName:String)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, targetDocumentType, targetClass,
				  targetDocumentSchema, indivoReportName);
		}

		override protected function initializeXmlMarshaller():void
		{
			super.initializeXmlMarshaller();
			_xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "RecurrenceRule"), RecurrenceRule);
		}

		override protected function get numPendingRequests():int
		{
			return super.numPendingRequests + _pendingReplacedDocumentRequests.size();
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

			if (requestDetails.indivoApiCall == GET_REPORTS_MINIMAL)
			{
				handleReportResponse(event, responseXml, healthRecordServiceRequestDetails);
			}
			else if (requestDetails.indivoApiCall == GET_DOCUMENT)
			{
				handleGetDocument(responseXml, record, healthRecordServiceRequestDetails);
			}
			else if (requestDetails.indivoApiCall == GET_METADATA)
			{
				var document:IDocument = healthRecordServiceRequestDetails.document;
				if (document)
				{
					DocumentMetadata.parseDocumentMetadata(responseXml, document.meta);
					_relationshipXmlMarshaller.unmarshallRelationshipsFromMetadata(responseXml, document);
					unmarshallSpecialRelationships(responseXml, document);
					record.addDocument(document);
					loadReplacedDocuments(record, document);
				}
			}
		}

		override protected function documentShouldBeIncluded(document:IDocument, nowTime:Number):Boolean
		{
			var scheduleItem:ScheduleItemBase = document as ScheduleItemBase;
			return scheduleItem.dateScheduled.valueOf() <= nowTime;
		}

		override protected function unmarshallSpecialRelationships(reportXml:XML, document:IDocument):void
		{
			var scheduleItem:ScheduleItemBase = document as ScheduleItemBase;

			for each (var adherenceItemXml:XML in reportXml..relatesTo.relation.(@type == ScheduleItemBase.RELATION_TYPE_ADHERENCE_ITEM).relatedDocument)
			{
				scheduleItem.adherenceItems.put(adherenceItemXml.@id, null);
			}
		}

	}
}
