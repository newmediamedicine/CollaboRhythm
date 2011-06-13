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

    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
    import collaboRhythm.shared.model.healthRecord.AdherenceItemsHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

	[Bindable]
	public class AdherenceItemsModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _adherenceItemsHealthRecordService:AdherenceItemsHealthRecordService;
        private var _adherenceItems:HashMap = new HashMap();
        private var _adherenceItemsCollection:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;
        private var _isInitialized:Boolean = false;
        private var _isStitched:Boolean;
		
		public function AdherenceItemsModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _adherenceItemsHealthRecordService = new AdherenceItemsHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getAdherenceItems():void
        {
            _adherenceItemsHealthRecordService.getAdherenceItems(_record);
        }

		public function set adherenceItemsReportXml(value:XML):void
		{
			for each (var adherenceItemXml:XML in value.Report)
			{
				var adherenceItem:AdherenceItem = new AdherenceItem();
                adherenceItem.initFromReportXML(adherenceItemXml);
                _adherenceItems[adherenceItem.id] = adherenceItem;
                _adherenceItemsCollection.addItem(adherenceItem);
			}
            isInitialized = true;
		}

        public function get activeAccount():Account
        {
            return _activeAccount;
        }

        public function set activeAccount(value:Account):void
        {
            _activeAccount = value;
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
        }

        public function get adherenceItemsHealthRecordService():AdherenceItemsHealthRecordService
        {
            return _adherenceItemsHealthRecordService;
        }

        public function set adherenceItemsHealthRecordService(value:AdherenceItemsHealthRecordService):void
        {
            _adherenceItemsHealthRecordService = value;
        }

        public function get adherenceItems():HashMap
        {
            return _adherenceItems;
        }

        public function set adherenceItems(value:HashMap):void
        {
            _adherenceItems = value;
        }

        public function get isStitched():Boolean
        {
            return _isStitched;
        }

        public function set isStitched(value:Boolean):void
        {
            _isStitched = value;
        }
    }
}