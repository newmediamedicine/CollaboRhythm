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
	import flash.errors.IllegalOperationError;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class Contact
	{
		private var _fullName:String;
        private var _givenName:String;
        private var _familyName:String;

		public function Contact(contactXml:XML)
		{
            initFromXml(contactXml);
		}

        public function initFromXml(contactXml:XML):void
        {
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
            if (contactXml.name.hasOwnProperty("fullName"))
				fullName = contactXml.name.fullName;
            if (contactXml.name.hasOwnProperty("givenName"))
				givenName = contactXml.name.givenName;
            if (contactXml.name.hasOwnProperty("familyName"))
				familyName = contactXml.name.familyName;
        }

        public function get fullName():String
        {
            return _fullName;
        }

        public function set fullName(value:String):void
        {
            _fullName = value;
        }

        public function get givenName():String
        {
            return _givenName;
        }

        public function set givenName(value:String):void
        {
            _givenName = value;
        }

        public function get familyName():String
        {
            return _familyName;
        }

        public function set familyName(value:String):void
        {
            _familyName = value;
        }
		
		private function get userName():String
		{
			// TODO: eliminate this hack for guessing the username from the first and last name
			if (givenName != null && familyName != null)
				return givenName.substr(0, 1).toLowerCase() + familyName.toLowerCase();
			else
				return null;
		}
		
		public function get imageURI():String
		{
			return userName ? Account.ACCOUNT_IMAGES_API_URL_BASE + userName + ".jpg" : null;
		}
    }
}