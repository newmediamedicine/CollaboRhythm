package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
	
	import flash.net.URLVariables;
	
	import org.indivo.client.IndivoClientEvent;
	
	public class MedicationsHealthRecordService extends HealthRecordServiceBase
	{
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
		
		public function loadMedications(user:User):void
		{
			if (user.appData[MedicationsModel.MEDICATIONS_KEY] == null)
			{
				user.appData[MedicationsModel.MEDICATIONS_KEY] = new MedicationsModel(scheduleModel(user));
			}
			
			var params:URLVariables = new URLVariables();
//			params["order_by"] = "-date_onset";
			
			// now the user already had an empty MedicationsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty MedicationsModel so that views can bind to the instance before the data is finished loading
			//			user.medicationsModel = new MedicationsModel();
			if (user.recordId != null && accessKey != null && accessSecret != null)
				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "medications", accessKey, accessSecret, user);
		}
		
		private function scheduleModel(user:User):ScheduleModel
		{
			if (user != null)
			{
				if (user.appData[ScheduleModel.SCHEDULE_KEY] == null)
				{
					user.appData[ScheduleModel.SCHEDULE_KEY] = new ScheduleModel();
				}
				return user.getAppData(ScheduleModel.SCHEDULE_KEY, ScheduleModel) as ScheduleModel;
			}
			return null;
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML):void
		{
			var user:User;
			if (responseXml.name() == "Reports")
			{
				user = event.userData as User;
				
				var medicationsModel:MedicationsModel = user.getAppData(MedicationsModel.MEDICATIONS_KEY, MedicationsModel) as MedicationsModel;
				if (medicationsModel)
					medicationsModel.rawData = responseXml;
			}
			else
			{
				throw new Error("Unhandled response data: " + responseXml.name() + " " + responseXml);
			}
		}
	}
}