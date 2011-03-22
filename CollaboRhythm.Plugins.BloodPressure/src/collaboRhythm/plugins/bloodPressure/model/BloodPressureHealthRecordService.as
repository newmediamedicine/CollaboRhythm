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
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceBase;

	import flash.net.URLVariables;
	import flash.xml.XMLDocument;

	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLDecoder;

	import org.indivo.client.IndivoClientEvent;

	public class BloodPressureHealthRecordService extends HealthRecordServiceBase
	{
		private const systolicCategory:String = "Blood Pressure Systolic";
		private const diastolicCategory:String = "Blood Pressure Diastolic";

		public function BloodPressureHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}
		
		public function loadBloodPressure(user:User):void
		{
			// clear any existing data
			user.bloodPressureModel.data = null;
			user.bloodPressureModel.isSystolicReportLoaded = false;
			user.bloodPressureModel.isDiastolicReportLoaded = false;

			var params:URLVariables = new URLVariables();
			params["order_by"] = "date_measured";

			if (user.recordId != null && accessKey != null && accessSecret != null)
			{
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, user.recordId, systolicCategory, accessKey,
												  accessSecret,
												  new BloodPressureReportUserData(user, systolicCategory));
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, user.recordId, diastolicCategory, accessKey,
												  accessSecret,
												  new BloodPressureReportUserData(user, diastolicCategory));
			}
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			if (responseXml.localName() == "Reports")
			{
				var bloodPressureReportUserData:BloodPressureReportUserData = event.userData as BloodPressureReportUserData;
				if (bloodPressureReportUserData == null)
					throw new Error("userData must be a BloodPressureReportUserData object");

				var user:User = bloodPressureReportUserData.user;
				if (user == null)
					throw new Error("userData.user must be a User object");

				if (responseXml.Report.Item.VitalSign.length() > 0)
				{
					user.bloodPressureModel.data = parseReportData(responseXml,
																   getFieldNameFromCategory(bloodPressureReportUserData.category),
																   user.bloodPressureModel.data);
					
					if (bloodPressureReportUserData.category == systolicCategory)
						user.bloodPressureModel.isSystolicReportLoaded = true;
					else if (bloodPressureReportUserData.category == diastolicCategory)
						user.bloodPressureModel.isDiastolicReportLoaded = true;
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

		private function parseReportData(responseXml:XML, valueFieldName:String,
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

				// TODO: should we do anything with unit, site, or position?
				if (item.date.time > nowTime)
				{
					break;
				}
			}
			return data;
		}

		private static const millisecondsPerHour:int = 1000 * 60 * 60;

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