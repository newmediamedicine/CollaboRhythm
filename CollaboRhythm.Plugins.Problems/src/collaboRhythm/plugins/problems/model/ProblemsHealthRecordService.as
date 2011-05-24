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
package collaboRhythm.plugins.problems.model
{

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceBase;
	import collaboRhythm.shared.model.User;
	import collaboRhythm.shared.model.UsersModel;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
    import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

    import flash.net.URLVariables;
	
	import org.indivo.client.IndivoClientEvent;
	
	public class ProblemsHealthRecordService extends PhaHealthRecordServiceBase
	{
		public function ProblemsHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String, account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
		}

		public function loadAllProblems(remoteUserModel:UsersModel):void
		{
			for each (var user:User in remoteUserModel.remoteUsers)
			{
				loadProblems(user);
			}
			loadProblems(remoteUserModel.localUser);
		}

		public function loadProblems(user:User):void
		{
			if (user.appData[ProblemsModel.PROBLEMS_KEY] == null)
			{
				user.appData[ProblemsModel.PROBLEMS_KEY] = new ProblemsModel();
			}
			
			var params:URLVariables = new URLVariables();
			params["order_by"] = "-date_onset";
			
			// now the user already had an empty ProblemsModel when created, and a variable called initialized is used to see if it has been populated, allowing for early binding -- start with an empty ProblemsModel so that views can bind to the instance before the data is finished loading
			//			user.problemsModel = new ProblemsModel();
			if (user.recordId != null && _activeAccount.oauthAccountToken != null && _activeAccount.oauthAccountTokenSecret != null)
				_pha.reports_minimal_X_GET(params, null, null, null, user.recordId, "problems", _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, user);
		}

		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
//			var user:User;
//			if (responseXml.name() == "Reports")
//			{
//				user = event.userData as User;
//
//				var problemsModel:ProblemsModel = user.getAppData(ProblemsModel.PROBLEMS_KEY, ProblemsModel) as ProblemsModel;
//				if (problemsModel)
//					problemsModel.rawData = responseXml;
//			}
//			else
//			{
//				throw new Error("Unhandled response data: " + responseXml.name() + " " + responseXml);
//			}
		}
	}
}