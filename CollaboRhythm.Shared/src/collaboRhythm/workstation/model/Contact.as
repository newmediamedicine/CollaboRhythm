/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.workstation.model
{
	import flash.errors.IllegalOperationError;
	
	import mx.events.PropertyChangeEvent;

	[Bindable]
	public class Contact
	{
		private var _rawData:XML;
		private var _firstName:String;
		private var _lastName:String;

		public function Contact()
		{
		}

		public function get givenName():String
		{
			return _firstName;
		}

		public function set givenName(value:String):void
		{
			_firstName = value;
		}

		public function get familyName():String
		{
			return _lastName;
		}

		public function set familyName(value:String):void
		{
			_lastName = value;
		}

		public function get rawData():XML
		{
			return _rawData;
		}
		
		public function set rawData(value:XML):void
		{
			_rawData = value;
			
			if (rawData.name.length() == 1)
			{
				var nameXml:XML = rawData.name[0];
				if (nameXml.givenName.length() == 1)
				{
					this.givenName = nameXml.givenName.toString();
				}
				
				if (nameXml.familyName.length() == 1)
				{
					this.familyName = nameXml.familyName.toString();
				}
				
				this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "userName", null, this.userName));
				this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "imageURI", null, this.imageURI));
			}
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