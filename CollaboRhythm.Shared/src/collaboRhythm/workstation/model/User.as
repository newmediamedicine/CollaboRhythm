package collaboRhythm.workstation.model
{	
	import collaboRhythm.workstation.apps.bloodPressure.model.BloodPressureModel;
	import collaboRhythm.workstation.apps.medications.model.MedicationsModel;
	import collaboRhythm.workstation.apps.problems.model.ProblemsModel;
	import collaboRhythm.workstation.apps.schedule.model.ScheduleModel;
	
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.utils.flash_proxy;
	
	import j2as3.collection.HashMap;
	
	import mx.events.PropertyChangeEvent;

	/**
	 * 
	 * @author jom
	 * 
	 * Models all of the data for a user, whether that user is a local user or a remote user.
	 * 
	 */
	[Bindable]
	public class User
	{
		public static const COLLABORATION_LOBBY_NOT_CONNECTED:String = "CollaborationLobbyNotConnected";
		public static const COLLABORATION_LOBBY_AVAILABLE:String = "CollaborationLobbyAvailable";
		public static const COLLABORATION_LOBBY_AWAY:String = "CollaborationLobbyAway";
		
		public static const COLLABORATION_REQUEST_SENT:String = "CollaborationRequestSent";
		public static const COLLABORATION_REQUEST_RECEIVED:String = "CollaborationRequestReceived";
		public static const COLLABORATION_ROOM_EXITED:String = "CollaborationRoomExited";
		public static const COLLABORATION_ROOM_ENTERED:String = "CollaborationRoomEntered";
		public static const COLLABORATION_ROOM_JOINED:String = "CollaborationRoomJoined";
		
		private var _firstName:String;
		private var _lastName:String;
		private var _userName:String;
		private var _imageURI:String;
		private var _demographics:UserDemographics;
		private var _contact:Contact;
		
		private var _accountId:String;
		private var _recordId:String;
//		private var _accessKey:String;
//		private var _accessSecret:String;
		private var _isOwnedByLocalAccount:Boolean;
		
		private var _collaborationLobbyConnectionStatus:String = COLLABORATION_LOBBY_NOT_CONNECTED;
		private var _collaborationRoomConnectionStatus:String = COLLABORATION_ROOM_EXITED;
		private var _video:Video = new Video();
		private var _netStream:NetStream;
		private var _collaborationColor:String = "0xFFFFFF";
		
		private var _problemsModel:ProblemsModel = new ProblemsModel();
		private var _medicationsModel:MedicationsModel = new MedicationsModel();
		private var _scheduleModel:ScheduleModel;
		private var _bloodPressureModel:BloodPressureModel = new BloodPressureModel();
		
//		private var _appData:HashMap = new HashMap();
		
		public function User(recordId:String)
		{
			_recordId = recordId;

			// TODO: how can we eliminate this dependency so that schedule and medications can be independent plugins?
			_scheduleModel = new ScheduleModel(_medicationsModel)
		}

//		public function get firstName():String
//		{
////			return _firstName;
//			return _contact ? _contact.givenName : null;
//		}
		
//		private function set firstName(value:String):void
//		{
//			_firstName = value;
//		}
		
//		public function get lastName():String
//		{
////			return _lastName;
//			return _contact ? _contact.familyName : null;
//		}
		
//		private function set lastName(value:String):void
//		{
//			_lastName = value;
//		}
		
//		public function get userName():String
//		{
//////			return _userName;
////			if (firstName != null && lastName != null)
////				return firstName.substr(0, 1).toLowerCase() + lastName.toLowerCase();
////			else
//				return null;
//		}
//		
////		private function set userName(value:String):void
////		{
////			_userName = value;
//////			imageURI = "resources/images/users/" + _userName + ".jpg";
////		}
//		
//		public function get imageURI():String
//		{
////			return _imageURI;
//			return userName ? "resources/images/users/" + userName + ".jpg" : null;			
//		}
		
//		private function set imageURI(value:String):void
//		{
//			_imageURI = value;
//		}
		
		public function get isOwnedByLocalAccount():Boolean
		{
			return _isOwnedByLocalAccount;
		}

		public function set isOwnedByLocalAccount(value:Boolean):void
		{
			_isOwnedByLocalAccount = value;
		}

		public function get demographics():UserDemographics
		{
			return _demographics;
		}
		
		public function set demographics(value:UserDemographics):void
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
//			if (_contact != null)
//				_contact.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, contact_propertyChangeHandler);
			
//			firstName = _contact.givenName;
//			lastName = _contact.familyName;
			
			// TODO: store the images with the record (as a binary document) or use some other identifier for the file name
//			imageURI = "resources/images/users/" + firstName.substr(0, 1).toLowerCase() + lastName.toLowerCase() + ".jpg";
		}
		
		private function contact_propertyChangeHandler(event:PropertyChangeEvent):void
		{
//			if (event.property == "familyName")
//				this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "lastName", null, this.lastName));
//			if (event.property == "givenName")
//				this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "firstName", null, this.firstName));
//				this.firstName = contact.givenName; 
		}
		
		public function get accountId():String
		{
			return _accountId;
		}

		private function set accountId(value:String):void
		{
			_accountId = value;
		}
		
		public function get recordId():String
		{
			return _recordId;
		}

		private function set recordId(value:String):void
		{
			_recordId = value;
		}

//		public function get accessKey():String
//		{
//			return _accessKey;
//		}
//		
//		private function set accessKey(value:String):void
//		{
//			_accessKey = value;
//		}
//		
//		public function get accessSecret():String
//		{
//			return _accessSecret;
//		}
//		
//		private function set accessSecret(value:String):void
//		{
//			_accessSecret = value;
//		}
	
		public function get collaborationLobbyConnectionStatus():String
		{
			return _collaborationLobbyConnectionStatus;
		}
		
		private function set collaborationLobbyConnectionStatus(value:String):void
		{
			_collaborationLobbyConnectionStatus = value;
		}
		
		public function get collaborationRoomConnectionStatus():String
		{
			return _collaborationRoomConnectionStatus;
		}
		
		public function set collaborationRoomConnectionStatus(value:String):void
		{
			_collaborationRoomConnectionStatus = value;
		}
		
		public function get video():Video
		{
			return _video;
		}
		
		public function set video(value:Video):void
		{
			_video = value;
		}
		
		public function get netStream():NetStream
		{
			return _netStream;
		}
		
		public function set netStream(value:NetStream):void
		{
			_netStream = value;
		}
		
		public function get collaborationColor():String
		{
			return _collaborationColor;
		}
		
		public function set collaborationColor(value:String):void
		{
			_collaborationColor = value;
		}
		
		public function get scheduleModel():ScheduleModel
		{
			return _scheduleModel;
		}
		
		private function set scheduleModel(value:ScheduleModel):void
		{
			_scheduleModel = value;
		}
		
		public function get problemsModel():ProblemsModel
		{
			return _problemsModel;
		}
		
		private function set problemsModel(value:ProblemsModel):void
		{
			_problemsModel = value;
		}
		
		public function get medicationsModel():MedicationsModel
		{
			return _medicationsModel;
		}
		
		private function set medicationsModel(value:MedicationsModel):void
		{
			_medicationsModel = value;
		}

		public function get bloodPressureModel():BloodPressureModel
		{
			return _bloodPressureModel;
		}
		
		private function set bloodPressureModel(value:BloodPressureModel):void
		{
			_bloodPressureModel = value;
		}
		
//		public function get appData():HashMap
//		{
//			return _appData;
//		}
	}
}