package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.core.model.healthRecord.Schemas;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	import com.adobe.utils.DateUtil;

	public class VitalSignHealthRecordService extends DocumentStorageSingleReportServiceBase
	{
		private const USE_CREATED_AT_FOR_DATE_MEASURED_START:Boolean = false;

		public function VitalSignHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													 account:Account, debuggingToolsEnabled:Boolean)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, VitalSign.DOCUMENT_TYPE,
					VitalSign, Schemas.VitalSignSchema, "CollaboRhythmVitalSign", "date_measured_start", 1000, "dateMeasuredStart");
		}

		override public function unmarshallReportXml(reportXml:XML):IDocument
		{
			var document:VitalSign = super.unmarshallReportXml(reportXml) as VitalSign;

			// TODO: Eliminate this workaround. Indivo code needs to be fixed so that dateMeasuredStart value comes through in report.
			if (USE_CREATED_AT_FOR_DATE_MEASURED_START)
			{
				var createdAt:Date = DateUtil.parseW3CDTF(reportXml.Meta.Document[0].createdAt.toString());
				if (Math.abs(document.dateMeasuredStart.valueOf() - createdAt.valueOf()) < 1000 * 60 * 60 * 24)
				{
					document.dateMeasuredStart = createdAt;
				}
			}

			return document;
		}

		override protected function documentShouldBeIncluded(document:IDocument, nowTime:Number):Boolean
		{
			var vitalSign:VitalSign = document as VitalSign;
			return vitalSign.dateMeasuredStart.valueOf() <= nowTime;
		}
	}
}
