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
package collaboRhythm.plugins.schedule.model
{

    import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.ReportRequestDetails;
    import collaboRhythm.shared.model.User;
    import collaboRhythm.shared.model.UsersModel;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
    import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

    import flash.net.URLVariables;

    import org.indivo.client.IndivoClientEvent;

    public class ScheduleHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _numScheduleDocuments:Number;		
		private var _currentScheduleDocument:Number;
		private var _scheduleModel:ScheduleModel;
		
		public function ScheduleHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}
		
		public function loadAllSchedules(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadScheduleGroups(user);
			}
			loadScheduleGroups(remoteUserModel.localUser);
		}
		
		private function getScheduleModel(user:User):ScheduleModel
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
		
		public function loadScheduleGroups(user:User):void
		{			
			var params:URLVariables = new URLVariables();
			
			// now the user already had an empty SchedulesModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty SchedulesModel so that views can bind to the instance before the data is finished loading
			if (user.recordId != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "schedulegroups", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, new ReportRequestDetails(user, "scheduleGroups"));
		}
		
		public function archiveScheduleGroup(user:User, documentID:String):void
		{
			if (user.recordId != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
				_pha.documents_X_setStatusPOST(null, null, null, user.recordId, documentID, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, "reason=schedulechanged&status=archived");
		}
		
		public function createScheduleGroup(user:User, document:XML, relatedDocumentIDs:Vector.<String>):void
		{
			if (user.recordId != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
				_pha.documents_POST(null, null, null, user.recordId, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, document, new CreateScheduleGroupDetails(user, relatedDocumentIDs));
		}
		
		private function handleScheduleGroupsReport(user:User, scheduleModel:ScheduleModel, responseXML:XML):void
		{
			scheduleModel.scheduleGroupsReportXML = responseXML;
		}
		
		private function handleScheduleGroupCreated(user:User, responseXML:XML, relatedDocumentIDs:Vector.<String>):void
		{
			for each (var relatedDocumentID:String in relatedDocumentIDs)
			{
				_pha.documents_X_rels_X_XPUT(null, null, null, user.recordId, responseXML.@id, "ScheduleItem", relatedDocumentID, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret);
			}
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXML:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
//			if (event.userData)
//			{
//				var user:User = event.userData.user as User;
//			}
//			var scheduleModel:ScheduleModel = getScheduleModel(user);
//
//			if (responseXML.name() == "Reports")
//			{
//				if (event.userData.reportType == "scheduleGroups")
//				{
//					handleScheduleGroupsReport(user, scheduleModel, responseXML);
//				}
//			}
//			else if (responseXML.name() == "Document")
//			{
//				handleScheduleGroupCreated(user, responseXML, event.userData.scheduleItemIDs);
//			}
//			else if (responseXML.name() == "ok")
//			{
//				//currently no further action
//			}
//			else
//			{
//				throw new Error("Unhandled response data: " + responseXML.name() + " " + responseXML);
//			}
		}
	}
}