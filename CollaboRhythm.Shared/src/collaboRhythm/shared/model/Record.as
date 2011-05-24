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

    import collaboRhythm.shared.model.healthRecord.HealthRecordHelperMethods;

    [Bindable]
    public class Record
    {

        private var _id:String;
        private var _label:String;
        private var _shared:Boolean = false;
        private var _role_label:String;
        private var _demographics:Demographics;
        private var _contact:Contact;

        public function Record(recordXml:XML)
        {
            _id = recordXml.@id;
            _label = recordXml.@label;
            if (recordXml.hasOwnProperty("@shared"))
                _shared = HealthRecordHelperMethods.booleanFromString(recordXml.@shared);
            if (recordXml.hasOwnProperty("@role_label"))
                _role_label = recordXml.@role_label;
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
    }
}
