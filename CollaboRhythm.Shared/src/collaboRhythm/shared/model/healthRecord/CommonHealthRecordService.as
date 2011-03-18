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
package collaboRhythm.shared.model.healthRecord
{
	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	
	import com.brooksandrus.utils.ISO8601Util;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ArrayUtil;
	import mx.utils.URLUtil;
	
	import org.indivo.client.Admin;
	import org.indivo.client.IndivoClientEvent;
	import org.indivo.client.Pha;

	public class CommonHealthRecordService extends HealthRecordServiceBase
	{
		public function CommonHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}
		
		public function loadAllDemographics(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadDemographics(user);
			}
			loadDemographics(remoteUserModel.localUser);
		}
		
		public function loadAllContact(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadContact(user);
			}
			loadContact(remoteUserModel.localUser);
		}
		
		public function loadDemographics(user:User):void
		{
			user.demographics = new UserDemographics();
			if (user.recordId != null && accessKey != null && accessSecret != null)
				_pha.special_demographicsGET(null, null, null, user.recordId, accessKey, accessSecret, user);
		}
		
		public function loadContact(user:User):void
		{
			user.contact = new Contact();
			if (user.recordId != null && accessKey != null && accessSecret != null)
				_pha.special_contactGET(null, null, null, user.recordId, accessKey, accessSecret, user);
		}
		
//		public function loadMedications(user:User):void
//		{
//			user.medicationsModel.isLoading = true;
//			var params:URLVariables = new URLVariables();
//			params["order_by"] = "-date_started";
//			
//			// now the user already had an empty MedicationsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty MedicationsModel so that views can bind to the instance before the data is finished loading
//			//			user.medicationsModel = new MedicationsModel();
//			if (user.recordId != null && accessKey != null && accessSecret != null)
//				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "medications", accessKey, accessSecret, user);
//		}
		
		//		/**
		//		 * Called when HTTPService call completes the data load of the XML chart info.
		//		 */
		//		private function bloodPressureHttpService_result(event:ResultEvent):void
		//		{
		//			user.bloodPressureModel.rawData = event.result;
		//			
		////			// TODO: use ICurrentDateSource
		////			var today:Date = new Date();
		////			offsetDataToToday(tmpData, today);
		////			
		////			mcCuneChart1.data = tmpData;
		////			mcCuneChart2.data = tmpData;
		//		}
		//		
		//		
		//		/**
		//		 * If an error occurs loading the XML chart info
		//		 */
		//		private function bloodPressureHttpService_fault(event:FaultEvent):void
		//		{
		//			Alert.show("Error retrieving XML data", "Error");
		//		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			var user:User;
			if (responseXml.name() == "Demographics")
			{
				user = event.userData as User;
				user.demographics.rawData = responseXml;
			}
			else if (responseXml.name() == "Record" && responseXml.Contact.length() == 1)
			{
				user = event.userData as User;
				user.contact.rawData = responseXml.Contact[0];
				
				if (user.contact.userName != null)
					this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
			}
//			else if (responseXml.name() == "Reports")
//			{
//				user = event.userData as User;
//				
//				//						if (responseXml.Report.Item.Medication
//				
//				if (event.urlRequest.url.indexOf("/medications") > -1)
//				{
//					user.medicationsModel.rawData = responseXml;
//					user.medicationsModel.isLoading = false;
//				}
//				else
//					throw new Error("Unhandled request: " + event.urlRequest.url);
//			}
			else
			{
				throw new Error("Unhandled response data: " + responseXml.name() + " " + responseXml);
			}
		}
	}
}