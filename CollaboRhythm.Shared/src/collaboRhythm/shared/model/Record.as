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

    import collaboRhythm.shared.model.Account;
    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    [Bindable]
    public class Record
    {
        private var _id:String;
        private var _label:String;
        private var _shared:Boolean = false;
        private var _role_label:String;
        private var _demographics:Demographics;
        private var _contact:Contact;
        private var _problemsModel:ProblemsModel;
        private var _medicationsModel:MedicationsModel;
        private var _equipmentModel:EquipmentModel;
        private var _videoMessagesModel:VideoMessagesModel1;
        private var _appData:HashMap = new HashMap();
        private var _settings:Settings;
        private var _activeAccount:Account;

        public function Record(settings:Settings, activeAccount:Account, recordXml:XML)
        {
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
            _problemsModel = new ProblemsModel(_settings, _activeAccount, this);
            _medicationsModel = new MedicationsModel(_settings, _activeAccount, this);
            _equipmentModel = new EquipmentModel(_settings, _activeAccount, this);
            _videoMessagesModel = new VideoMessagesModel1(_settings, _activeAccount, this);
        }

        public function getDocuments():void
        {
            _problemsModel.getProblems();
            _medicationsModel.getMedications();
            _equipmentModel.getEquipment();
            _videoMessagesModel.getVideoMessages();
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

        public function get medicationsModel():MedicationsModel
        {
            return _medicationsModel;
        }

        public function set medicationsModel(value:MedicationsModel):void
        {
            _medicationsModel = value;
        }

        public function get equipmentModel():EquipmentModel
        {
            return _equipmentModel;
        }

        public function set equipmentModel(value:EquipmentModel):void
        {
            _equipmentModel = value;
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
    }
}
