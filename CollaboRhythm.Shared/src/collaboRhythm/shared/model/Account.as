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

	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	import flash.net.NetStream;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	import spark.collections.Sort;

	[Bindable]
	public class Account
	{
		public static const COLLABORATION_LOBBY_NOT_CONNECTED:String = "CollaborationLobbyNotConnected";
		public static const COLLABORATION_LOBBY_AVAILABLE:String = "CollaborationLobbyAvailable";
		public static const COLLABORATION_LOBBY_AWAY:String = "CollaborationLobbyAway";

		public static const COLLABORATION_INVITATION_SENT:String = "CollaborationInvitationSent";
		public static const COLLABORATION_INVITATION_RECEIVED:String = "CollaborationInvitationReceived";
		public static const COLLABORATION_ROOM_EXITED:String = "CollaborationRoomExited";
		public static const COLLABORATION_ROOM_ENTERED:String = "CollaborationRoomEntered";
		public static const COLLABORATION_ROOM_JOINED:String = "CollaborationRoomJoined";

		public static const ACCOUNT_IMAGES_API_URL_BASE:String = "http://www.mit.edu/~jom/temp/accountImages/";

		private var _accountId:String;
		private var _messagesModel:MessagesModel = new MessagesModel();
		private var _oauthAccountToken:String;
		private var _oauthAccountTokenSecret:String;
		private var _primaryRecord:Record;
		// TODO: Figure out why Collection.CHANGE_EVENT is not working for the HashMap so this ArrayCollection can be eliminated
		private var _sharedRecordAccountsCollection:ArrayCollection = new ArrayCollection();
		private var _sharedRecordAccounts:HashMap = new HashMap(); // accountId as key
		private var _recordShareAccounts:HashMap = new HashMap(); // accountId as key
		private var _allSharingAccounts:HashMap = new HashMap(); // accountId as key
		private var _collaborationLobbyConnectionStatus:String = COLLABORATION_LOBBY_NOT_CONNECTED;
		private var _collaborationRoomConnectionStatus:String = COLLABORATION_ROOM_EXITED;
		private var _isInitialized:Boolean;
		private var _netStream:NetStream;
		private var _peerId:String;

		public function Account()
		{
			var sort:Sort = new Sort();
			sort.compareFunction = sortCompare;
			_sharedRecordAccountsCollection.sort = sort;
		}

		/**
		 * Sort method for Account which orders accounts alphabetically by familyName, givenName of the associated
		 * contact info in the primary record.
		 *
		 * @param objA
		 * @param objB
		 * @param fields
		 * @return
		 */
		protected function sortCompare(objA:Object, objB:Object, fields:Array = null):int
		{
			var accountA:Account = objA as Account;
			var accountB:Account = objB as Account;
			if (accountA && accountA.primaryRecord.contact &&
					accountB && accountB.primaryRecord.contact)
			{
				var accountFullNameA:String = accountA.primaryRecord.contact.familyName + ", " +
						accountA.primaryRecord.contact.givenName;
				var accountFullNameB:String = accountB.primaryRecord.contact.familyName + ", " +
						accountB.primaryRecord.contact.givenName;

				if (accountFullNameA < accountFullNameB)
				{
					return -1;
				}
				else if (accountFullNameA == accountFullNameB)
				{
					return 0;
				}
				return 1;
			}
			return 0;
		}

		public function addSharedRecordAccount(sharedRecordAccount:Account):void
		{
			_sharedRecordAccounts.put(sharedRecordAccount.accountId, sharedRecordAccount);
			_allSharingAccounts.put(sharedRecordAccount.accountId, sharedRecordAccount);
			_sharedRecordAccountsCollection.addItem(sharedRecordAccount);
		}

		public function addRecordShareAccount(recordShareAccount:Account):void
		{
			_recordShareAccounts.put(recordShareAccount.accountId, recordShareAccount);
			_allSharingAccounts.put(recordShareAccount.accountId, recordShareAccount);
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function set accountId(value:String):void
		{
			_accountId = value;
		}

		public function get messagesModel():MessagesModel
		{
			return _messagesModel;
		}

		public function set messagesModel(value:MessagesModel):void
		{
			_messagesModel = value;
		}

		public function get oauthAccountToken():String
		{
			return _oauthAccountToken;
		}

		public function set oauthAccountToken(value:String):void
		{
			_oauthAccountToken = value;
		}

		public function get oauthAccountTokenSecret():String
		{
			return _oauthAccountTokenSecret;
		}

		public function set oauthAccountTokenSecret(value:String):void
		{
			_oauthAccountTokenSecret = value;
		}

		public function get primaryRecord():Record
		{
			return _primaryRecord;
		}

		public function set primaryRecord(value:Record):void
		{
			_primaryRecord = value;
		}

		public function get sharedRecordAccounts():HashMap
		{
			return _sharedRecordAccounts;
		}

		public function set sharedRecordAccounts(value:HashMap):void
		{
			_sharedRecordAccounts = value;
		}

		public function get recordShareAccounts():HashMap
		{
			return _recordShareAccounts;
		}

		public function set recordShareAccounts(value:HashMap):void
		{
			_recordShareAccounts = value;
		}

		public function get sharedRecordAccountsCollection():ArrayCollection
		{
			return _sharedRecordAccountsCollection;
		}

		public function set sharedRecordAccountsCollection(value:ArrayCollection):void
		{
			_sharedRecordAccountsCollection = value;
		}

		public function get allSharingAccounts():HashMap
		{
			return _allSharingAccounts;
		}

		public function set allSharingAccounts(value:HashMap):void
		{
			_allSharingAccounts = value;
		}

		public function get collaborationLobbyConnectionStatus():String
		{
			return _collaborationLobbyConnectionStatus;
		}

		public function set collaborationLobbyConnectionStatus(value:String):void
		{
			_collaborationLobbyConnectionStatus = value;
		}

		/**
		 * Flag to indicate that the sharedRecordAccountsCollection has been populated and that contact and
		 * demographics data (if available) for the primary record of each account has been loaded.
		 */
		public function get isInitialized():Boolean
		{
			return _isInitialized;
		}

		public function set isInitialized(value:Boolean):void
		{
			_isInitialized = value;
		}

		public function get imageURI():String
		{
			return accountIdPrefix ? ACCOUNT_IMAGES_API_URL_BASE + accountIdPrefix + ".jpg" : null;
		}

		private function get accountIdPrefix():String
		{
			return _accountId ? _accountId.split("@")[0] : null;
		}

		public function get collaborationRoomConnectionStatus():String
		{
			return _collaborationRoomConnectionStatus;
		}

		public function set collaborationRoomConnectionStatus(value:String):void
		{
			_collaborationRoomConnectionStatus = value;
		}

		public function get netStream():NetStream
		{
			return _netStream;
		}

		public function set netStream(value:NetStream):void
		{
			_netStream = value;
		}

		public function get peerId():String
		{
			return _peerId;
		}

		public function set peerId(value:String):void
		{
			_peerId = value;
		}
	}
}
