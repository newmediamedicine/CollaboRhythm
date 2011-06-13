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

    import collaboRhythm.shared.model.healthRecord.MedicationOrdersHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class MedicationOrdersModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _medicationOrdersHealthRecordService:MedicationOrdersHealthRecordService;
        private var _medicationOrders:HashMap = new HashMap();
        private var _medicationOrdersCollection:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;

		private var _isInitialized:Boolean = false;
        private var _isStitched:Boolean = false;

		public function MedicationOrdersModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _medicationOrdersHealthRecordService = new MedicationOrdersHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getMedicationOrders():void
        {
            _medicationOrdersHealthRecordService.getMedicationOrders(_record);
        }

		public function set medicationOrdersReportXml(value:XML):void
		{
			for each (var medicationOrderXml:XML in value.Report)
			{
				var medicationOrder:MedicationOrder = new MedicationOrder();
                medicationOrder.initFromReportXML(medicationOrderXml);
                _medicationOrders[medicationOrder.id] = medicationOrder;
                _medicationOrdersCollection.addItem(medicationOrder);
			}
            isInitialized = true;
		}

        public function get medicationOrders():HashMap
        {
            return _medicationOrders;
        }

        public function set medicationOrders(value:HashMap):void
        {
            _medicationOrders = value;
        }

        public function get medicationOrdersCollection():ArrayCollection
        {
            return _medicationOrdersCollection;
        }

        public function set medicationOrdersCollection(value:ArrayCollection):void
        {
            _medicationOrdersCollection = value;
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
