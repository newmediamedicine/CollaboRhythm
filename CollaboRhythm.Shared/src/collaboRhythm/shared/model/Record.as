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

	import collaboRhythm.shared.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
	import collaboRhythm.shared.model.healthRecord.IRecord;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItemsModel;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministrationsModel;
	import collaboRhythm.shared.model.healthRecord.document.VitalSignModel;
	import collaboRhythm.shared.model.settings.Settings;

	import j2as3.collection.HashMap;

	[Bindable]
    public class Record implements IRecord
    {
        private var _id:String;
        private var _label:String;
        private var _shared:Boolean = false;
        private var _role_label:String;
        private var _demographics:Demographics;
        private var _contact:Contact;
        private var _medicationOrdersModel:MedicationOrdersModel;
        private var _medicationFillsModel:MedicationFillsModel;
        private var _medicationScheduleItemsModel:MedicationScheduleItemsModel;
        private var _medicationAdministrationsModel:MedicationAdministrationsModel;
        private var _equipmentModel:EquipmentModel;
        private var _equipmentScheduleItemsModel:EquipmentScheduleItemsModel;
        private var _adherenceItemsModel:AdherenceItemsModel;
        private var _videoMessagesModel:VideoMessagesModel1;
        private var _problemsModel:ProblemsModel;
        private var _appData:HashMap = new HashMap();
        private var _settings:Settings;
        private var _activeAccount:Account;
		private var _vitalSignModel:VitalSignModel;
		private var _bloodPressureModel:BloodPressureModel;

        public function Record(settings:Settings, activeAccount:Account, recordXml:XML)
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            _settings = settings;
            _activeAccount = activeAccount;
            _id = recordXml.@id;
            _label = recordXml.@label;
            if (recordXml.hasOwnProperty("@shared"))
                _shared = HealthRecordHelperMethods.stringToBoolean(recordXml.@shared);
            if (recordXml.hasOwnProperty("@role_label"))
                _role_label = recordXml.@role_label;
            initDocumentModels();
        }

        private function initDocumentModels():void
        {
            medicationOrdersModel = new MedicationOrdersModel(_settings, _activeAccount, this);
            medicationFillsModel = new MedicationFillsModel(_settings, _activeAccount, this);
            medicationScheduleItemsModel = new MedicationScheduleItemsModel(_settings, _activeAccount, this);
            medicationAdministrationsModel = new MedicationAdministrationsModel();
            equipmentModel = new EquipmentModel(_settings, _activeAccount, this);
            equipmentScheduleItemsModel = new EquipmentScheduleItemsModel(_settings, _activeAccount, this);
            adherenceItemsModel = new AdherenceItemsModel();
            videoMessagesModel = new VideoMessagesModel1(_settings, _activeAccount, this);
            problemsModel = new ProblemsModel(_settings, _activeAccount, this);
			vitalSignModel = new VitalSignModel();
			bloodPressureModel = new BloodPressureModel();
			bloodPressureModel.record = this;

            new MedicationOrderStitcher(_medicationOrdersModel, _medicationFillsModel, _medicationScheduleItemsModel);
            new MedicationScheduleItemStitcher(_medicationScheduleItemsModel, _adherenceItemsModel);
            new EquipmentStitcher(_equipmentModel, _equipmentScheduleItemsModel);
            new EquipmentScheduleItemStitcher(_equipmentScheduleItemsModel, _adherenceItemsModel);
            new AdherenceItemStitcher(_adherenceItemsModel, _medicationAdministrationsModel);
        }

        public function getDocuments():void
        {
            _medicationOrdersModel.getMedicationOrders();
            _medicationFillsModel.getMedicationFills();
            _medicationScheduleItemsModel.getMedicationScheduleItems();
            _equipmentModel.getEquipment();
            _equipmentScheduleItemsModel.getEquipmentScheduleItems();
            _videoMessagesModel.getVideoMessages();
            _problemsModel.getProblems();
        }

		public function get id():String
		{
			return _id;
		}

		public function set id(value:String):void
		{
			_id = value;
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}

		public function get shared():Boolean
		{
			return _shared;
		}

		public function set shared(value:Boolean):void
		{
			_shared = value;
		}

		public function get role_label():String
		{
			return _role_label;
		}

		public function set role_label(value:String):void
		{
			_role_label = value;
		}

		public function get demographics():Demographics
        {
            return _demographics;
        }

        public function set demographics(value:Demographics):void
        {
            _demographics = value;
        }

        public function get contact():Contact
        {
            return _contact;
        }

        public function set contact(value:Contact):void
        {
            _contact = value;

            // TODO: store the images with the record (as a binary document) or use some other identifier for the file name
        }

        public function get equipmentModel():EquipmentModel
        {
            return _equipmentModel;
        }

        public function set equipmentModel(value:EquipmentModel):void
        {
            _equipmentModel = value;
        }

        public function get adherenceItemsModel():AdherenceItemsModel
        {
            return _adherenceItemsModel;
        }

        public function set adherenceItemsModel(value:AdherenceItemsModel):void
        {
            _adherenceItemsModel = value;
        }

        public function get videoMessagesModel():VideoMessagesModel1
        {
            return _videoMessagesModel;
        }

        public function set videoMessagesModel(value:VideoMessagesModel1):void
        {
            _videoMessagesModel = value;
        }

        public function get appData():HashMap
		{
			return _appData;
		}

		public function getAppData(key:String, type:Class):Object
		{
			var data:Object = appData[key] as type;
			if (data)
				return data;
			else
				throw new Error("appData on Record does not contain a " + (type as Class).toString() + " for key " + key);
		}

        public function clearDocuments():void
        {
            initDocumentModels();
        }

        public function get problemsModel():ProblemsModel
        {
            return _problemsModel;
        }

        public function set problemsModel(value:ProblemsModel):void
        {
            _problemsModel = value;
        }

        public function get medicationOrdersModel():MedicationOrdersModel
        {
            return _medicationOrdersModel;
        }

        public function set medicationOrdersModel(value:MedicationOrdersModel):void
        {
            _medicationOrdersModel = value;
        }

        public function get medicationFillsModel():MedicationFillsModel
        {
            return _medicationFillsModel;
        }

        public function set medicationFillsModel(value:MedicationFillsModel):void
        {
            _medicationFillsModel = value;
        }

        public function get medicationScheduleItemsModel():MedicationScheduleItemsModel
        {
            return _medicationScheduleItemsModel;
        }

        public function set medicationScheduleItemsModel(value:MedicationScheduleItemsModel):void
        {
            _medicationScheduleItemsModel = value;
        }

        public function get medicationAdministrationsModel():MedicationAdministrationsModel
        {
            return _medicationAdministrationsModel;
        }

        public function set medicationAdministrationsModel(value:MedicationAdministrationsModel):void
        {
            _medicationAdministrationsModel = value;
        }

        public function get equipmentScheduleItemsModel():EquipmentScheduleItemsModel
        {
            return _equipmentScheduleItemsModel;
        }

        public function set equipmentScheduleItemsModel(value:EquipmentScheduleItemsModel):void
        {
            _equipmentScheduleItemsModel = value;
        }

		public function get vitalSignModel():VitalSignModel
		{
			return _vitalSignModel;
		}

		public function set vitalSignModel(value:VitalSignModel):void
		{
			_vitalSignModel = value;
		}

		public function get bloodPressureModel():BloodPressureModel
		{
			return _bloodPressureModel;
		}

		public function set bloodPressureModel(value:BloodPressureModel):void
		{
			_bloodPressureModel = value;
		}

		public function get settings():Settings
		{
			return _settings;
		}

		public function set settings(value:Settings):void
		{
			_settings = value;
		}
	}
}
