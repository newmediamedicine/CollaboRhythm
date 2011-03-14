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
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.ReportRequestDetails;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
	
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.indivo.client.IndivoClientEvent;
	
	public class MedicationsHealthRecordService extends HealthRecordServiceBase
	{
		private var _numMedicationDocuments:Number;		
		private var _currentMedicationDocument:Number;
		private var _medicationsModel:MedicationsModel;
		
		public function MedicationsHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
		}
		
		public function loadAllMedications(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadMedications(user);
			}
			loadMedications(remoteUserModel.localUser);
		}
		
		private function getMedicationsModel(user:User):MedicationsModel
		{
			if (user != null)
			{
				if (user.appData[MedicationsModel.MEDICATIONS_KEY] == null)
				{
					user.appData[MedicationsModel.MEDICATIONS_KEY] = new MedicationsModel(user);
				}
				return user.getAppData(MedicationsModel.MEDICATIONS_KEY, MedicationsModel) as MedicationsModel;
			}
			return null;
		}
		
		public function loadMedications(user:User):void
		{			
			var params:URLVariables = new URLVariables();
			
			// now the user already had an empty MedicationsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty MedicationsModel so that views can bind to the instance before the data is finished loading
			if (user.recordId != null && accessKey != null && accessSecret != null)
			{
				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "medications", accessKey, accessSecret, new ReportRequestDetails(user, "medications"));
			}	
		}
		
		private function handleMedicationsReport(user:User, medicationsModel:MedicationsModel, responseXML:XML):void
		{
			var params:URLVariables = new URLVariables();
			medicationsModel.medicationsReportXML = responseXML;
					
			_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "scheduleitems", accessKey, accessSecret, new ReportRequestDetails(user, "medicationScheduleItems"));
		}
		
		private function handleMedicationScheduleItemsReport(user:User, medicationsModel:MedicationsModel, responseXML:XML):void
		{
			medicationsModel.medicationScheduleItemsReportXML = responseXML;
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXML:XML):void
		{
			var user:User = event.userData.user as User;
			var medicationsModel:MedicationsModel = getMedicationsModel(user);

			if (responseXML.name() == "Reports")
			{
				if (event.userData.reportType == "medications")
				{
					handleMedicationsReport(user, medicationsModel, responseXML);
				}
				else if (event.userData.reportType == "medicationScheduleItems")
				{
					handleMedicationScheduleItemsReport(user, medicationsModel, responseXML);
				}
			}
			else
			{
				throw new Error("Unhandled response data: " + responseXML.name() + " " + responseXML);
			}
		}
	}
}