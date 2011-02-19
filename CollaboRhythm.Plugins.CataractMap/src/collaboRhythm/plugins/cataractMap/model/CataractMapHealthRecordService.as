/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.plugins.cataractMap.model
{
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.healthRecord.DocumentMetadata;
	
	import com.brooksandrus.utils.ISO8601Util;
	
	import flash.net.URLVariables;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.indivo.client.IndivoClientEvent;

	public class CataractMapHealthRecordService extends HealthRecordServiceBase
	{
		public function CataractMapHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}
		
		public function loadCataractMap(user:User):void
		{
			if (user.appData[CataractMapModel.CATARACT_MAP_KEY] == null)
			{
				user.appData[CataractMapModel.CATARACT_MAP_KEY] = new CataractMapModel();
			}
			
			var params:URLVariables = new URLVariables();
			params["order_by"] = "-date_measured";
			
			if (user.recordId != null && accessKey != null && accessSecret != null)
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, user.recordId, "Cataract_Map", accessKey, accessSecret, user);
			
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			if (responseXml.name() == "Reports")
			{
				var user:User = event.userData as User;

				if (user == null)
					throw new Error("userData must be a User object");
				
				var cataractMapModel:CataractMapModel = user.getAppData(CataractMapModel.CATARACT_MAP_KEY, CataractMapModel) as CataractMapModel;
				if (cataractMapModel)
				{
					cataractMapModel.rawData = responseXml;
					cataractMapModel.data = parseReportData(responseXml);
				}
			}
			else
			{
				throw new Error("Unhandled response data: " + responseXml.name() + " " + responseXml);
			}
		}
		
		private function parseReportData(responseXml:XML):ArrayCollection
		{
			var data:ArrayCollection = new ArrayCollection();
			
			// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
			var nowTime:Number = _currentDateSource.now().time;
			var dateUtil:ISO8601Util = new ISO8601Util();
			
			for each (var itemXml:XML in responseXml.Report.Item.VitalSign)
			{
				var cataractMapDataItem:CataractMapDataItem = new CataractMapDataItem();
				var dateMeasuredString:String = itemXml.dateMeasured.toString();
				cataractMapDataItem.date = dateUtil.parseDateTimeString(dateMeasuredString);
				
				// TODO: parse the data properly
				cataractMapDataItem.densityMapAverage = new Number(itemXml.value.toString());
				
				if (cataractMapDataItem.date.time > nowTime)
				{
					break;
				}

				data.addItem(cataractMapDataItem);
			}
			return data;
		}

		private function xmlToArrayCollection(xml:XML):ArrayCollection
		{                 
			var xmlDoc:XMLDocument = new XMLDocument(xml.toString());
			var decoder:SimpleXMLDecoder = new SimpleXMLDecoder(true);
			var resultObj:Object = decoder.decodeXML(xmlDoc);
			//			var ac:ArrayCollection = new ArrayCollection(new Array(resultObj.root.list.source.item));
			var ac:ArrayCollection = resultObj.CataractMapData.data;
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
		
		protected override function handleError(event:IndivoClientEvent):void
		{
			
		}
	}
}