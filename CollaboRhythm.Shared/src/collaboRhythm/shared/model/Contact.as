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
        private var _rawData:XML;
		private var _fullName:String;
        private var _givenName:String;
        private var _familyName:String;

		public function Contact(contactXml:XML)
		{
            initFromXml(contactXml);
		}

        public function initFromXml(contactXml:XML):void
        {
            if (contactXml.name.hasOwnProperty("fullName"))
				fullName = contactXml.name.fullName;
            if (contactXml.name.hasOwnProperty("givenName"))
				givenName = contactXml.name.givenName;
            if (contactXml.name.hasOwnProperty("familyName"))
				familyName = contactXml.name.familyName;

            this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "userName", null, this.userName));
			this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "imageURI", null, this.imageURI));
        }
//
// 		public function get rawData():XML
//		{
//			return _rawData;
//		}
//
//		public function set rawData(value:XML):void
//		{
//			_rawData = value;
//
//			if (rawData.name.length() == 1)
//			{
//				var nameXml:XML = rawData.name[0];
//				if (nameXml.givenName.length() == 1)
//				{
//					this.givenName = nameXml.givenName.toString();
//				}
//
//				if (nameXml.familyName.length() == 1)
//				{
//					this.familyName = nameXml.familyName.toString();
//				}
//
//
//			}
//		}

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
		
		public function get userName():String
		{
			//			return _userName;
			if (givenName != null && familyName != null)
				return givenName.substr(0, 1).toLowerCase() + familyName.toLowerCase();
			else
				return null;
		}
		
		public function set userName(value:String):void
		{
			throw new IllegalOperationError("userName is read-only");
		}
		
		//		private function set userName(value:String):void
		//		{
		//			_userName = value;
		////			imageURI = "resources/images/users/" + _userName + ".jpg";
		//		}
		
		public function get imageURI():String
		{
			//			return _imageURI;
			return userName ? "resources/images/users/" + userName + ".jpg" : null;			
		}
		
		public function set imageURI(value:String):void
		{
			throw new IllegalOperationError("imageURI is read-only");
		}
    }
}