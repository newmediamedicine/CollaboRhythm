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