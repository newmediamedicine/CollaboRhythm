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
package collaboRhythm.plugins.bloodPressure.model
{
	import collaboRhythm.shared.apps.bloodPressure.model.AdherenceItem;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureDataItem;
    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.CodedValue;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceBase;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
    import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

    import flash.net.URLVariables;
	import flash.xml.XMLDocument;

	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLDecoder;

	import org.indivo.client.IndivoClientEvent;

	public class BloodPressureHealthRecordService extends PhaHealthRecordServiceBase
	{
		private const systolicCategory:String = "Blood Pressure Systolic";
		private const diastolicCategory:String = "Blood Pressure Diastolic";

		private static const VITALS_REPORT:String = "vitals";
		private static const ADHERENCE_ITEMS_REPORT:String = "adherenceitems";

		private static const millisecondsPerHour:int = 1000 * 60 * 60;

		public function BloodPressureHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		public function loadBloodPressure(user:User):void
		{
			// clear any existing data
			user.bloodPressureModel.data = null;
			user.bloodPressureModel.isSystolicReportLoaded = false;
			user.bloodPressureModel.isDiastolicReportLoaded = false;

			var params:URLVariables = new URLVariables();
			params["order_by"] = "date_measured";

			if (user.recordId != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
			{
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, user.recordId, systolicCategory, _activeAccount.oauthAccountToken,
												   _activeAccount.oauthAccountTokenSecret,
												  new BloodPressureReportUserData(user, VITALS_REPORT, systolicCategory));
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, user.recordId, diastolicCategory, _activeAccount.oauthAccountToken,
												   _activeAccount.oauthAccountTokenSecret,
												  new BloodPressureReportUserData(user, VITALS_REPORT, diastolicCategory));

				// TODO: figure out what is wrong with order_by for this report; it is currently causing an error
//				var adherenceParams:URLVariables = new URLVariables();
//				adherenceParams["order_by"] = "date_time_reported";
				_pha.reports_minimal_X_GET(null, null, null, null, user.recordId, ADHERENCE_ITEMS_REPORT,  _activeAccount.oauthAccountToken,  _activeAccount.oauthAccountTokenSecret, new BloodPressureReportUserData(user, ADHERENCE_ITEMS_REPORT))
			}
		}

		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (responseXml.localName() == "Reports")
			{
				var bloodPressureReportUserData:BloodPressureReportUserData = event.userData as BloodPressureReportUserData;
				if (bloodPressureReportUserData == null)
					throw new Error("userData must be a BloodPressureReportUserData object");

				var user:User = bloodPressureReportUserData.user;
				if (user == null)
					throw new Error("userData.user must be a User object");

				if (bloodPressureReportUserData.report == VITALS_REPORT)
				{
					if (responseXml.Report.Item.VitalSign.length() > 0)
					{
						user.bloodPressureModel.data = parseVitalSignReportData(responseXml,
																	   getFieldNameFromCategory(bloodPressureReportUserData.category),
																	   user.bloodPressureModel.data);

						if (bloodPressureReportUserData.category == systolicCategory)
							user.bloodPressureModel.isSystolicReportLoaded = true;
						else if (bloodPressureReportUserData.category == diastolicCategory)
							user.bloodPressureModel.isDiastolicReportLoaded = true;
					}
				}
				else if (bloodPressureReportUserData.report == ADHERENCE_ITEMS_REPORT)
				{
					user.bloodPressureModel.adherenceData = parseAdherenceItemReportData(responseXml);
				}
			}
			else
			{
				throw new Error("Unexpected response: " + responseXml);
			}
		}

		private function getFieldNameFromCategory(category:String):String
		{
			if (category == systolicCategory)
				return "systolic";
			else if (category == diastolicCategory)
				return "diastolic";
			else
				throw new Error("Unhandled category value " + category)
		}

		private function parseVitalSignReportData(responseXml:XML, valueFieldName:String,
										 data:ArrayCollection=null):ArrayCollection
		{
			var searchForExistingData:Boolean;
			if (data == null || data.length == 0)
				data = new ArrayCollection();
			else
				searchForExistingData = true;

			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			var i:int = 0;

			for each (var itemXml:XML in responseXml.Report.Item.VitalSign)
			{
				var dateMeasuredString:String = itemXml.dateMeasured.toString();
				var dateMeasured:Date = DateUtil.parseW3CDTF(dateMeasuredString);

				// TODO: should we do anything with unit, site, or position?
				if (dateMeasured.valueOf() > nowTime)
				{
					break;
				}
				else
				{
					var item:BloodPressureDataItem;
					if (searchForExistingData)
					{
						if (data.length > i && datesAreClose(data[i].date, dateMeasured))
						{
							item = data[i];
							i++;
						}
						else
						{
							// TODO: implement searching; implement creating a new instance if not found
							throw new Error("Date does not match for index " + i.toString() +
													". Expected: " + dateMeasured.toString() +
													" Found: " + ((data.length > i) ? data[i].date.toString() : "(data.length = " + data.length + ")"));
						}
					}
					else
					{
						item = new BloodPressureDataItem();
						data.addItem(item);
					}

					item.date = dateMeasured;

					item[valueFieldName] = itemXml.value.toString();
				}
			}
			return data;
		}

		private function parseAdherenceItemReportData(responseXml:XML):ArrayCollection
		{
			var data:ArrayCollection = new ArrayCollection();

			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;

			for each (var itemXml:XML in responseXml.Report.Item.AdherenceItem)
			{
				var dateTimeReportedString:String = itemXml.dateTimeReported.toString();
				var dateTimeReported:Date = DateUtil.parseW3CDTF(dateTimeReportedString);

				if (dateTimeReported.valueOf() > nowTime)
				{
					// TODO: get order_by working and then we can optimize by breaking here instead of continuing to parse all data
//					break;
				}
				else
				{
					var item:AdherenceItem;
					item = new AdherenceItem();

					if (itemXml.name.length() == 1)
						item.name = HealthRecordHelperMethods.codedValueFromXml(itemXml.name[0]);
					if (itemXml.reportedBy.length() == 1)
						item.reportedBy = itemXml.reportedBy.toString();
					if (itemXml.dateTimeReported.length() == 1)
						item.dateTimeReported = dateTimeReported;
					if (itemXml.administered.length() == 1)
						item.administered = itemXml.administered.toString() == true.toString();
					if (itemXml.nonadherenceReason.length() == 1)
						item.nonAdherenceReason = itemXml.nonadherenceReason.toString() == true.toString();

					data.addItem(item);
				}
			}

			// TODO: get order_by working and remove this sorting
			data = new ArrayCollection(data.toArray().sortOn("dateValue", Array.NUMERIC));

			return data;
		}

		private function datesAreClose(date1:Date, date2:Date):Boolean
		{
			return (Math.abs(date1.time - date2.time) < millisecondsPerHour * 12);
		}

		private function xmlToArrayCollection(xml:XML):ArrayCollection
		{
			var xmlDoc:XMLDocument = new XMLDocument(xml.toString());
			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
			var resultObj:Object = decoder.decodeXML(xmlDoc);
			//			var ac:ArrayCollection = new ArrayCollection(new Array(resultObj.root.list.source.item));
			var ac:ArrayCollection = resultObj.BloodPressureData.data;
			return ac;
			//			var temp:String = '<items>' + xml.toString() + '</items>';
			//			xml = XML(temp);
			//			var xmlDoc:XMLDocument = new XMLDocument(xml.toString());
			//			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
			//			var resultObj:Object = decoder.decodeXML(xmlDoc);
			//			var ac:ArrayCollection;
			//			ac = new ArrayCollection();
			//			ac.addItem(resultObj.items);
			//			return ac;
		}
	}
}