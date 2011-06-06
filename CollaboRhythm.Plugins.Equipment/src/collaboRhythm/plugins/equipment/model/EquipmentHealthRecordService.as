package collaboRhythm.plugins.equipment.model
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.ReportRequestDetails;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.UsersModel;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
    import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

    import flash.net.URLVariables;

    import org.indivo.client.IndivoClientEvent;

    public class EquipmentHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _equipmentModel:EquipmentModel;
		
		public function EquipmentHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}
		
		public function loadAllEquipment(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadEquipment(user);
			}
			loadEquipment(remoteUserModel.localUser);
		}
		
		private function getEquipmentModel(user:User):EquipmentModel
		{
			if (user != null)
			{
				if (user.appData[EquipmentModel.EQUIPMENT_KEY] == null)
				{
					user.appData[EquipmentModel.EQUIPMENT_KEY] = new EquipmentModel(user);
				}
				return user.getAppData(EquipmentModel.EQUIPMENT_KEY, EquipmentModel) as EquipmentModel;
			}
			return null;
		}
		
		public function loadEquipment(user:User):void
		{			
			var params:URLVariables = new URLVariables();
			
			// now the user already had an empty EquipmentModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty EquipmentModel so that views can bind to the instance before the data is finished loading
			if (user.recordId != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
			{
				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "equipment", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, new ReportRequestDetails(user, "equipment"));
			}	
		}
		
		private function handleEquipmentReport(user:User, equipmentModel:EquipmentModel, responseXML:XML):void
		{
			var params:URLVariables = new URLVariables();
			equipmentModel.equipmentReportXML = responseXML;
			
			_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "scheduleitems", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, new ReportRequestDetails(user, "equipmentScheduleItems"));
		}
		
		private function handleMedicationScheduleItemsReport(user:User, equipmentModel:EquipmentModel, responseXML:XML):void
		{
			equipmentModel.equipmentScheduleItemsReportXML = responseXML;
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXML:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
//			var user:User = event.userData.user as User;
//			var equipmentModel:EquipmentModel = getEquipmentModel(user);
//
//			if (responseXML.name() == "Reports")
//			{
//				if (event.userData.reportType == "equipment")
//				{
//					handleEquipmentReport(user, equipmentModel, responseXML);
//				}
//				else if (event.userData.reportType == "equipmentScheduleItems")
//				{
//					handleMedicationScheduleItemsReport(user, equipmentModel, responseXML);
//				}
//			}
//			else
//			{
//				throw new Error("Unhandled response data: " + responseXML.name() + " " + responseXML);
//			}
		}
	}
}