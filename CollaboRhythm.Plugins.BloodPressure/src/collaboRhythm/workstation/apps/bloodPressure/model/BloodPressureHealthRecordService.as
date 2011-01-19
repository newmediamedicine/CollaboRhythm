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
package collaboRhythm.workstation.apps.bloodPressure.model
{
	import collaboRhythm.workstation.model.HealthRecordServiceBase;
	import collaboRhythm.workstation.model.HealthRecordServiceEvent;
	import collaboRhythm.workstation.model.User;
	
	import com.brooksandrus.utils.ISO8601Util;
	
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import org.indivo.client.IndivoClientEvent;
	
	public class BloodPressureHealthRecordService extends HealthRecordServiceBase
	{
		public function BloodPressureHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}
		
		public function loadBloodPressure(user:User):void
		{
//			// Note that the file path is based on the userName
//			//			// TODO: use the Indivo server instead of a file
//			var dataFile:File = File.applicationDirectory.resolvePath("data").resolvePath(user.contact.userName).resolvePath("blood_pressure_data.xml");
//			if (dataFile.exists)
//			{
//				var stream:FileStream = new FileStream();
//				stream.open(dataFile, FileMode.READ);
//				
//				var data:ArrayCollection = xmlToArrayCollection(XML(stream.readUTFBytes(stream.bytesAvailable)));
//				
//				// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
//				var nowTime:Number = _currentDateSource.now().time;
//				var dateUtil:ISO8601Util = new ISO8601Util();
//				
//				for (var i:int = 0; i < data.length; i++)
//				{
//					var dataItem:Object = data[i];
//					
//					// convert each date from a string to a Date object
//					dataItem.date = dateUtil.parseDateTimeString(dataItem.date);
//					
//					if (dataItem.date.time > nowTime)
//					{
//						if (i > 1)
//							data.source = data.source.slice(0, i - 1);
//						else
//							data.source = [];
//						break;
//					}
//				}
//				
//				//				user.bloodPressureModel.rawData = XML(stream.readUTFBytes(stream.bytesAvailable));
//				//				user.bloodPressureModel.data = new ArrayCollection(ArrayUtil.toArray(XML(stream.readUTFBytes(stream.bytesAvailable))));
//				user.bloodPressureModel.data = data;
//				stream.close();
//				
//				//				var httpService:HTTPService = new HTTPService(dataFile.nativePath);
//				//				//			httpService.resultFormat = "e4x";
//				//				
//				//				//			result="dataResult(event)" fault="faultResult(event)" resultFormat="object" />
//				//				
//				//				httpService.addEventListener(ResultEvent.RESULT, bloodPressureHttpService_result);
//				//				httpService.addEventListener(FaultEvent.FAULT, bloodPressureHttpService_fault);
//				//				
//				//				httpService.send();
//			}
//			else
//			{
//				trace("File not found:", dataFile.nativePath);
//			}
			
//			var params:URLVariables = new URLVariables();
//			params["order_by"] = "-date_started";
			
			// now the user already had an empty MedicationsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty MedicationsModel so that views can bind to the instance before the data is finished loading
			//			user.medicationsModel = new MedicationsModel();
			if (user.recordId != null && accessKey != null && accessSecret != null)
				_pha.documents_type_X_GET(null, null, null, null, user.recordId, "BloodPressureData", accessKey, accessSecret, user);
			
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			if (responseXml.name() == "Documents")
			{
				if (responseXml.Document.length() > 1 )
					throw new Error("There must be only 1 (or 0) BloodPressureData documents. Unexpected number of documents in response: " + responseXml.Document.length() + " " + responseXml);
				
				var user:User = event.userData as User;
				if (user == null)
					throw new Error("userData must be a User object");
				
				if (responseXml.Document.length() > 0)
				{
					if (responseXml.Document[0].attribute("id").length() != 1)
						throw new Error("Document does not have expected id attribute");
					
					_pha.documents_XGET(null, null, null, user.recordId, responseXml.Document[0].@id.toString(), accessKey, accessSecret, user); 
				}
			}
			else if (responseXml.name() == "BloodPressureData")
			{
				user = event.userData as User;
				if (user == null)
					throw new Error("userData must be a User object");
				
				var data:ArrayCollection = xmlToArrayCollection(responseXml);
				
				// trim off any data that is from the future (according to ICurrentDateSource); note that we assume the data is in ascending order by date
				var nowTime:Number = _currentDateSource.now().time;
				var dateUtil:ISO8601Util = new ISO8601Util();
				
				for (var i:int = 0; i < data.length; i++)
				{
					var dataItem:Object = data[i];
					
					// convert each date from a string to a Date object
					dataItem.date = dateUtil.parseDateTimeString(dataItem.date);
					
					if (dataItem.date.time > nowTime)
					{
						if (i > 1)
							data.source = data.source.slice(0, i - 1);
						else
							data.source = [];
						break;
					}
				}
				
				//				user.bloodPressureModel.rawData = XML(stream.readUTFBytes(stream.bytesAvailable));
				//				user.bloodPressureModel.data = new ArrayCollection(ArrayUtil.toArray(XML(stream.readUTFBytes(stream.bytesAvailable))));
				user.bloodPressureModel.data = data;
			}
			else
			{
				throw new Error("Unexpected response: " + responseXml);
			}
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
		
		protected override function handleError(event:IndivoClientEvent):void
		{
			
		}
	}
}