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
package collaboRhythm.plugins.schedule.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.shared.model.ReportRequestDetails;
	import collaboRhythm.shared.model.HealthRecordServiceBase;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
	
	import flash.net.URLVariables;
	
	import org.indivo.client.IndivoClientEvent;

	public class ScheduleHealthRecordService extends HealthRecordServiceBase
	{
		private var _numScheduleDocuments:Number;		
		private var _currentScheduleDocument:Number;
		private var _scheduleModel:ScheduleModel;
		
		public function ScheduleHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String)
		{
			super(consumerKey, consumerSecret, baseURL);
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
			if (user.appData[ScheduleModel.SCHEDULE_KEY] == null)
			{
				user.appData[ScheduleModel.SCHEDULE_KEY] = new ScheduleModel();
			}
			
			var params:URLVariables = new URLVariables();
			//			params["order_by"] = "-date_onset";
			
			// now the user already had an empty SchedulesModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty SchedulesModel so that views can bind to the instance before the data is finished loading
			//			user.medicationsModel = new SchedulesModel();
			if (user.recordId != null && accessKey != null && accessSecret != null)
//				TODO: currently this is a hack imitating the scheduleGroups report that we want to implement
//				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "scheduleGroups", accessKey, accessSecret, new DocumentRequestDetails(user, "scheduleGroups"));
				handleScheduleGroupsReport(user, getScheduleModel(user), scheduleGroupsReport);
		}
		
		private function handleScheduleGroupsReport(user:User, scheduleModel:ScheduleModel, responseXML:XML):void
		{
			scheduleModel.scheduleGroupsReportXML = responseXML;
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXML:XML):void
		{
			var user:User;
			var scheduleModel:ScheduleModel = getScheduleModel(user);
			
			if (responseXML.name() == "Reports")
			{
				if (event.userData.reportType == "scheduleGroups")
				{
					handleScheduleGroupsReport(user, scheduleModel, responseXML);
				}
			}
//			if (responseXml.name() == "Documents")
//			{			
//				user = event.userData as User;
//				if (user == null)
//					throw new Error("userData must be a User object");
//				
//				_scheduleModel = user.getAppData(ScheduleModel.SCHEDULE_KEY, ScheduleModel) as ScheduleModel;
//				
//				if (responseXml.Document.length() > 0)
//				{
//					_currentScheduleDocument = 0;
//					_numScheduleDocuments = responseXml.Document.length();
//					
//					if (responseXml.Document[0].attribute("id").length() != 1)
//						throw new Error("Document does not have expected id attribute");
//					
//					for each (var responseDocument:XML in responseXml.Document)
//					{
//						_pha.documents_XGET(null, null, null, user.recordId, responseDocument.@id.toString(), accessKey, accessSecret, new DocumentRequestDetails(user, responseDocument.@id.toString()));
//					}
//				}
//			}
//			else if (responseXml.name() == "ScheduleGroup")
//			{
//				user = event.userData.user as User;
//				if (user == null)
//					throw new Error("userData must be a User object");
//				
//				_scheduleModel.addScheduleGroup(event.userData.documentID, responseXml);
//				
//				_currentScheduleDocument += 1;
//				if (_currentScheduleDocument == _numScheduleDocuments - 1)
//				{
//					_scheduleModel.initialized = true;
//				}
//			}
			else
			{
				throw new Error("Unhandled response data: " + responseXML.name() + " " + responseXML);
			}
		}
		
		private var scheduleGroupsReport:XML = <Reports>
  <Summary total_document_count="1" limit="100" offset="0" order_by="-created_at"/>
<Report>
    <Meta>
       <Document id="b5390d4f-1f20-45fe-8be2-a4f08d4ee7ce" type="http://indivo.org/vocab/xml/documents#ScheduleGroup" size="402" digest="e02bd19dc7f65518e3f139875913815fe40a6d314bffa4dd32e1e5656fa1a075" record_id="6d4d246f-b518-4d03-a353-07b2f84f65ca">
    <createdAt>2011-02-16T22:20:09Z</createdAt>
    <creator id="gwhite@records.media.mit.edu" type="Account">
      <fullname>George White</fullname>
    </creator>
    <original id="b5390d4f-1f20-45fe-8be2-a4f08d4ee7ce"/>
    <latest id="b5390d4f-1f20-45fe-8be2-a4f08d4ee7ce" createdAt="2011-02-16T22:20:09Z" createdBy="gwhite@records.media.mit.edu"/>
    <status>active</status>
    <nevershare>false</nevershare>
    <relatesTo>
      <relation type="http://indivo.org/vocab/documentrels#scheduleItem" count="2">
<relatedDocument id="138a12fb-14b4-48bb-a71a-9db2742354ce"/>
<relatedDocument id="298323ab-e0b2-4bd6-8d1a-f964d242fb7c"/>
      </relation>
    </relatesTo>
  </Document>
  </Meta>
    <Item>
      <ScheduleGroup junk="http://indivo.org/vocab/xml/documents#">
  <scheduledBy>jking@records.media.mit.edu</scheduledBy>
  <dateTimeScheduled>2011-02-14T09:00:00-04:00</dateTimeScheduled>
  <dateTimeStart>2011-02-15T06:00:00-04:00</dateTimeStart>
  <dateTimeEnd>2011-02-15T10:00:00-04:00</dateTimeEnd>
  <recurrenceRule>
    <frequency>DAILY</frequency>
    <count>90</count>
  </recurrenceRule>
</ScheduleGroup>
</Item>
</Report>
</Reports>

	}
}