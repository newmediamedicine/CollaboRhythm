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
package collaboRhythm.plugins.cataractMap.model
{

	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

	import flash.net.URLVariables;

	import mx.collections.ArrayCollection;

	import org.indivo.client.IndivoClientEvent;

	public class CataractMapHealthRecordService extends PhaHealthRecordServiceBase
	{
		public function CataractMapHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}
		
		public function loadCataractMap(activeRecordAccount:Account):void
		{
			if (activeRecordAccount.primaryRecord.appData[CataractMapModel.CATARACT_MAP_KEY] == null)
			{
				activeRecordAccount.primaryRecord.appData.put(CataractMapModel.CATARACT_MAP_KEY, new CataractMapModel());
			}
			
			var params:URLVariables = new URLVariables();
			params["order_by"] = "date_measured";
			
			if (activeRecordAccount.primaryRecord.id != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
				_pha.reports_minimal_vitals_X_GET(params, null, null, null, activeRecordAccount.primaryRecord.id, "Cataract_Map", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, activeRecordAccount);
			
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (responseXml.name() == "Reports")
			{
				var activeRecordAccount:Account = event.userData as Account;

				if (activeRecordAccount == null)
					throw new Error("userData must be a User object");
				
				var cataractMapModel:CataractMapModel = activeRecordAccount.primaryRecord.getAppData(CataractMapModel.CATARACT_MAP_KEY, CataractMapModel) as CataractMapModel;
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

			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			for each (var itemXml:XML in responseXml.Report.Item.VitalSign)
			{
				var item:CataractMapDataItem = new CataractMapDataItem();
				var dateMeasuredString:String = itemXml.dateMeasured.toString();
				item.date = DateUtil.parseW3CDTF(dateMeasuredString);
				
				// TODO: parse the data properly
				parseDensityMap(itemXml.comments.toString(), item);
				
				if (item.date.time > nowTime)
				{
					break;
				}

				data.addItem(item);
			}
			return data;
		}
		
		private function parseDensityMap(densityMapString:String, item:CataractMapDataItem):void
		{
			var densityArray:Array = densityMapString.split(",");
			item.densityMap = new Vector.<Number>();
			
			var max:Number = 0;
			for (var i:int = 0; i < densityArray.length; i++)
			{
				item.densityMap[i] = densityArray[i];
				max = Math.max(max, densityArray[i]);
			}
			item.densityMapMax = max;
		}
	}
}