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

    import collaboRhythm.shared.model.healthRecord.MedicationFillsHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class MedicationFillsModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _medicationFillsHealthRecordService:MedicationFillsHealthRecordService;
        private var _medicationFills:HashMap = new HashMap();
        private var _medicationFillsCollection:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;

		private var _isInitialized:Boolean = false;
        private var _isStitched:Boolean = false;

		public function MedicationFillsModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _medicationFillsHealthRecordService = new MedicationFillsHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getMedicationFills():void
        {
            _medicationFillsHealthRecordService.getMedicationFills(_record);
        }

		public function set medicationFillsReportXml(value:XML):void
		{
			for each (var medicationFillXml:XML in value.Report)
			{
				var medicationFill:MedicationFill = new MedicationFill();
                medicationFill.initFromReportXML(medicationFillXml);
                _medicationFills[medicationFill.id] = medicationFill;
                _medicationFillsCollection.addItem(medicationFill);
			}
            isInitialized = true;
		}

        public function get medicationFills():HashMap
        {
            return _medicationFills;
        }

        public function set medicationFills(value:HashMap):void
        {
            _medicationFills = value;
        }

        public function get medicationFillsCollection():ArrayCollection
        {
            return _medicationFillsCollection;
        }

        public function set medicationFillsCollection(value:ArrayCollection):void
        {
            _medicationFillsCollection = value;
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
