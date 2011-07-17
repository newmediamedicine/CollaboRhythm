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

	import collaboRhythm.shared.model.healthRecord.IDocumentCollection;
	import collaboRhythm.shared.model.healthRecord.MedicationScheduleItemsHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class MedicationScheduleItemsModel implements IDocumentCollection
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _medicationScheduleItemsHealthRecordService:MedicationScheduleItemsHealthRecordService;
        private var _medicationScheduleItems:HashMap = new HashMap();
        private var _medicationScheduleItemsCollection:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;

		private var _isInitialized:Boolean = false;
        private var _isStitched:Boolean = false;

		public function MedicationScheduleItemsModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _medicationScheduleItemsHealthRecordService = new MedicationScheduleItemsHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getMedicationScheduleItems():void
        {
            _medicationScheduleItemsHealthRecordService.getMedicationScheduleItems(_record);
        }

		public function set medicationScheduleItemsReportXml(value:XML):void
		{
			for each (var medicationScheduleItemXml:XML in value.Report)
            {
                var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
                medicationScheduleItem.initFromReportXML(medicationScheduleItemXml, "MedicationScheduleItem");
                _medicationScheduleItems[medicationScheduleItem.id] = medicationScheduleItem;
                _medicationScheduleItemsCollection.addItem(medicationScheduleItem);
            }
            isInitialized = true;
		}

        public function get medicationScheduleItems():HashMap
        {
            return _medicationScheduleItems;
        }

        public function set medicationScheduleItems(value:HashMap):void
        {
            _medicationScheduleItems = value;
        }

        public function get medicationScheduleItemsCollection():ArrayCollection
        {
            return _medicationScheduleItemsCollection;
        }

        public function set medicationScheduleItemsCollection(value:ArrayCollection):void
        {
            _medicationScheduleItemsCollection = value;
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

		public function get documents():ArrayCollection
		{
			return medicationScheduleItemsCollection;
		}

		public function get documentType():String
		{
			return MedicationScheduleItem.DOCUMENT_TYPE;
		}
	}
}
