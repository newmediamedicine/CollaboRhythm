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
package collaboRhythm.shared.model
{

    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceSimpleBase;
import collaboRhythm.shared.model.healthRecord.HealthRecordServiceSimpleBase;

	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;

import flash.errors.IllegalOperationError;
	
	import j2as3.collection.HashMap;
	
	import org.indivo.client.IndivoClientEvent;

	public class UsersHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _usersModel:UsersModel;
		private var _pendingRequests:HashMap = new HashMap(); // key: recordId
		private var _uniqueRecords:Vector.<String> = new Vector.<String>();

		public function UsersHealthRecordService(usersModel:UsersModel, oauthConsumerKey:String, oauthConsumerSecret:String, indivoServerBaseURL:String, account:Account)
		{
			super(oauthConsumerKey, oauthConsumerSecret, indivoServerBaseURL, account);
			_usersModel = usersModel;
		}
		
		public function populateRemoteUsers():void
		{
//			if (!isLoginComplete)
//				throw new IllegalOperationError("login must be completed before calling populateRemoteUsers");
			
			_pha.accounts_X_records_GET(null, null, null, null, _activeAccount.accountId, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, _usersModel.localUser);
		}
		
		protected override function handleResponse(event:IndivoClientEvent, responseXml:XML, healthRecordsServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (responseXml.name() == "Records")
			{
//				var user:User = event.userData as User;
				
				for each (var recordXml:XML in responseXml.Record)
				{
					if (recordXml.attribute("id").length() == 1)
					{
						var user:User = new User(recordXml.@id.toString());
						if (user.recordId != null)
						{
							if (_uniqueRecords.indexOf(user.recordId) == -1)
							{
								// avoid duplicates (such as when a record is shared via a full record share and one or more carenets)
								_uniqueRecords.push(user.recordId);
								
								if (recordXml.attribute("shared").length() == 1 && recordXml.@shared == "true")
								{
									user.isOwnedByLocalAccount = false;
								}
								else
								{
									user.isOwnedByLocalAccount = true;
									addPendingRequest("shares_GET", user.recordId);
									_pha.shares_GET(null, null, null, null, user.recordId, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, user);
								}
								
								addPendingRequest("records_X_owner_GET", user.recordId);
								_pha.records_X_owner_GET(null, null, null, user.recordId, _activeAccount.oauthAccountToken, _activeAccount.oauthAccountTokenSecret, user);
							}
						}
					}
				}
			}
			else if (responseXml.name() == "Shares")
			{
				// the record which is shared to the accounts below (not the record owned by each account)
				var recordId:String = responseXml.attribute("record").length() == 1 ? responseXml.@record.toString() : null;
				
				for each (var shareXml:XML in responseXml.Share)
				{
					if (shareXml.attribute("account").length() == 1)
					{
						// Each account that the record is shared to may or may own a record.
						// Regardless, we don't know (and perhaps don't care) what that record id is, so use null for recordId. 
						user = new User(null);
						user.accountId = shareXml.@account.toString();
						user.isOwnedByLocalAccount = false;
						_usersModel.addRemoteUser(user);
						this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.UPDATE, user));
					}
				}
				
				removePendingRequest("shares_GET", recordId);
			}
			else if (responseXml.name() == "Account")
			{
				if (responseXml.attribute("id").length() == 1)
				{
					user = event.userData as User;
					if (user == null)
						throw new Error("event.userData must be a User object");
					
					user.accountId = responseXml.@id.toString();
					
					if (user.accountId != null)
					{
						if (!user.isOwnedByLocalAccount)
						{
							_usersModel.addRemoteUser(user);
						}
						else
						{
							_usersModel.localUser = user;
//							this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, user));
						}
						this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.UPDATE, user));
						removePendingRequest("records_X_owner_GET", user.recordId);
					}
				}
			}
			else
			{
				throw new Error("Unhandled response data: " + responseXml.name() + " " + responseXml);
			}
		}

		protected override function handleError(event:IndivoClientEvent, errorStatus:String, healthRecordsServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			super.handleError(event, errorStatus, healthRecordsServiceRequestDetails);
			
			// TODO: remove the appropriate pending request
			throw new Error("Unexpected (and currently unhandled) response from server: " + event.response);
		}

		private function addPendingRequest(requestType:String, id:String):void
		{
			var key:String = getPendingRequestKey(requestType, id);
			if (_pendingRequests.keys.contains(key))
			{
				throw new Error("request with matching key is already pending: " + key);
			}
			
			_pendingRequests.put(key, key);
		}

		private function removePendingRequest(requestType:String, id:String):void
		{
			var key:String = getPendingRequestKey(requestType, id);
			if (_pendingRequests.keys.contains(key))
			{
				_pendingRequests.remove(key);
				if (_pendingRequests.size() == 0)
					this.dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE));
			}
		}
		
		private function getPendingRequestKey(requestType:String, id:String):String
		{
			return requestType + " " + id;
		}
	}
}