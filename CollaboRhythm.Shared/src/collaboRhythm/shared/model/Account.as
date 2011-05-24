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

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

    [Bindable]
    public class Account
    {

        private var _accountId:String;
        private var _oauthAccountToken:String;
        private var _oauthAccountTokenSecret:String;
        private var _records:Vector.<Record> = new Vector.<Record>();
        private var _primaryRecord:Record;
        // TODO: Figure out why Collection.CHANGE_EVENT is not working for the HashMap so this ArrayCollection can be eliminated
        private var _sharedRecordAccountsCollection:ArrayCollection = new ArrayCollection();
        private var _sharedRecordAccounts:HashMap = new HashMap(); // accountId as key
        private var _recordShareAccounts:HashMap = new HashMap(); // accountId as key

        public function Account()
        {

        }

        public function get accountId():String
        {
            return _accountId;
        }

        public function set accountId(value:String):void
        {
            _accountId = value;
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

        public function get records():Vector.<Record>
        {
            return _records;
        }

        public function set records(value:Vector.<Record>):void
        {
            _records = value;
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

        public function addSharedRecordAccount(sharedRecordAccount:Account):void
        {
            _sharedRecordAccounts[sharedRecordAccount.accountId] = sharedRecordAccount;
            _sharedRecordAccountsCollection.addItem(sharedRecordAccount);
        }

        public function addRecordShareAccount(recordShareAccount:Account):void
        {
            _recordShareAccounts[recordShareAccount.accountId] = recordShareAccount;
        }

        public function get sharedRecordAccountsCollection():ArrayCollection
        {
            return _sharedRecordAccountsCollection;
        }

        public function set sharedRecordAccountsCollection(value:ArrayCollection):void
        {
            _sharedRecordAccountsCollection = value;
        }

        public function get collaborationAccountIdsArray():Array
        {
            var collaborationAccountIdsArray:Array = _sharedRecordAccounts.keys.toArray();
            for each (var collaborationAccountId:String in _recordShareAccounts.keys)
            {
                if (collaborationAccountIdsArray.indexOf(collaborationAccountId) == -1)
                {
                    collaborationAccountIdsArray.push(collaborationAccountId);
                }
            }
            return collaborationAccountIdsArray;
        }
    }
}
