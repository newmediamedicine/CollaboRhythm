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

    import collaboRhythm.shared.model.healthRecord.MedicationAdministrationsHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class MedicationAdministrationsModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _medicationAdministrationsHealthRecordService:MedicationAdministrationsHealthRecordService;
        private var _medicationAdministrations:HashMap = new HashMap();
        private var _medicationAdministrationsCollection:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;

		private var _isInitialized:Boolean = false;

		public function MedicationAdministrationsModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _medicationAdministrationsHealthRecordService = new MedicationAdministrationsHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getMedicationAdministrations():void
        {
            _medicationAdministrationsHealthRecordService.getMedicationAdministrations(_record);
        }

		public function set medicationAdministrationsReportXml(value:XML):void
		{
            for each (var medicationAdministrationXml:XML in value.Report)
            {
                var medicationAdministration:MedicationAdministration = new MedicationAdministration();
                medicationAdministration.initFromReportXML(medicationAdministrationXml);
                _medicationAdministrations[medicationAdministration.id] = medicationAdministration;
                _medicationAdministrationsCollection.addItem(medicationAdministration);
            }
            isInitialized = true;
		}

        public function get medicationAdministrations():HashMap
        {
            return _medicationAdministrations;
        }

        public function set medicationAdministrations(value:HashMap):void
        {
            _medicationAdministrations = value;
        }

        public function get medicationAdministrationsCollection():ArrayCollection
        {
            return _medicationAdministrationsCollection;
        }

        public function set medicationAdministrationsCollection(value:ArrayCollection):void
        {
            _medicationAdministrationsCollection = value;
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
        }
    }
}
