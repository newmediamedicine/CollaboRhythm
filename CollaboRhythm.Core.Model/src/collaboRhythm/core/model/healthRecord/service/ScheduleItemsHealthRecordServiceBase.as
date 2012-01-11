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
