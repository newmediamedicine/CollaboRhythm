package collaboRhythm.core.model.healthRecord.service
{

	import collaboRhythm.core.model.XmlMarshaller;
	import collaboRhythm.core.model.healthRecord.*;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignsModel;

	import flash.net.URLVariables;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	public class VitalSignHealthRecordService extends DocumentStorageServiceBase
	{
		private static const VITALS_REPORT:String = "vitals";

		private static const VITALS_CATEGORIES_TO_LOAD:Vector.<String> = new <String>[
			VitalSignsModel.SYSTOLIC_CATEGORY,
			VitalSignsModel.DIASTOLIC_CATEGORY
		];
		private var _pendingVitalsCategories:HashMap = new HashMap();

		public function VitalSignHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													 account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		override public function loadDocuments(record:Record):void
		{
			super.loadDocuments(record);

			// clear any existing data
			record.vitalSignsModel.vitalSignsByCategory.clear();
			record.vitalSignsModel.isInitialized = false;

			var params:URLVariables = new URLVariables();
			params["order_by"] = "date_measured_start";

			if (record != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
			{
				for each (var category:String in VITALS_CATEGORIES_TO_LOAD)
				{
					_pendingVitalsCategories.put(category, category);
					_pha.reports_minimal_vitals_X_GET(params, null, null, null, record.id, category,
													  _activeAccount.oauthAccountToken,
													  _activeAccount.oauthAccountTokenSecret,
													  new HealthRecordServiceRequestDetails("reports_minimal_vitals_X_GET",
																							null, record,
																							VITALS_REPORT, category));
				}
			}
		}

		override protected function handleResponse(event:IndivoClientEvent, responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var requestDetails:HealthRecordServiceRequestDetails = event.userData as HealthRecordServiceRequestDetails;
			if (requestDetails == null)
				throw new Error("userData must be a BloodPressureReportUserData object");

			var record:Record = requestDetails.record;
			if (record == null)
				throw new Error("userData.record must be a Record object");

			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			if (responseXml.Report.Item.VitalSign.length() > 0)
			{
				record.vitalSignsModel.vitalSignsByCategory.put(requestDetails.category,
															   parseVitalSignReportData(responseXml));

				_pendingVitalsCategories.remove(requestDetails.category);
				if (_pendingVitalsCategories.size() == 0)
				{
					record.vitalSignsModel.isInitialized = true;
					isLoading = false;
				}

				_logger.info("VitalSign " + requestDetails.indivoApiCall + " report loaded");
			}

			// Note that we don't use super.handleResponse because loading is not complete until requests for all pendingVitalsCategories are complete
		}

		private function parseVitalSignReportData(responseXml:XML):ArrayCollection
		{
			var collection:ArrayCollection = new ArrayCollection();
			var xmlMarshaller:XmlMarshaller = new XmlMarshaller();
			xmlMarshaller.addSchema(Schemas.CodedValuesSchema);
			xmlMarshaller.addSchema(Schemas.ValuesSchema);
			xmlMarshaller.addSchema(Schemas.VitalSignSchema);
			var vitalSignQName:QName = new QName("http://indivo.org/vocab/xml/documents#", "VitalSign");
			xmlMarshaller.registerClass(vitalSignQName, VitalSign);
			xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "CodedValue"), CodedValue);
			xmlMarshaller.registerClass(new QName("http://indivo.org/vocab/xml/documents#", "ValueAndUnit"), ValueAndUnit);

			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			for each (var reportXml:XML in responseXml.Report)
			{
				var vitalSign:VitalSign = xmlMarshaller.unmarshallXml(reportXml.Item.VitalSign[0], vitalSignQName) as VitalSign;
				if (vitalSign && vitalSign.dateMeasuredStart.valueOf() <= nowTime)
				{
					_relationshipXmlMarshaller.unmarshallRelationships(reportXml, vitalSign);
					collection.addItem(vitalSign);
				}
			}

			return collection;
		}
	}
}
