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

    import collaboRhythm.shared.model.healthRecord.EquipmentHealthRecordService;
    import collaboRhythm.shared.model.healthRecord.EquipmentScheduleItemsHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class EquipmentScheduleItemsModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _equipmentScheduleItemsHealthRecordService:EquipmentScheduleItemsHealthRecordService;
        private var _equipmentScheduleItems:HashMap = new HashMap();
        private var _equipmentScheduleItemColleciton:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;

		private var _isInitialized:Boolean = false;
        private var _isStitched:Boolean;

		public function EquipmentScheduleItemsModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _equipmentScheduleItemsHealthRecordService = new EquipmentScheduleItemsHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getEquipmentScheduleItems():void
        {
            _equipmentScheduleItemsHealthRecordService.getEquipmentScheduleItems(_record);
        }

        public function set equipmentScheduleItemsReportXml(value:XML):void
        {
            for each (var equipmentScheduleItemXml:XML in value.Report)
            {
                var equipmentScheduleItem:EquipmentScheduleItem = new EquipmentScheduleItem();
                equipmentScheduleItem.initFromReportXML(equipmentScheduleItemXml, "EquipmentScheduleItem");
                _equipmentScheduleItems[equipmentScheduleItem.id] = equipmentScheduleItem;
                _equipmentScheduleItemColleciton.addItem(equipmentScheduleItem);
            }
            isInitialized = true;
        }

        public function get equipmentScheduleItems():HashMap
        {
            return _equipmentScheduleItems;
        }

        public function set equipmentScheduleItems(value:HashMap):void
        {
            _equipmentScheduleItems = value;
        }

        public function get equipmentScheduleItemColleciton():ArrayCollection
        {
            return _equipmentScheduleItemColleciton;
        }

        public function set equipmentScheduleItemColleciton(value:ArrayCollection):void
        {
            _equipmentScheduleItemColleciton = value;
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
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