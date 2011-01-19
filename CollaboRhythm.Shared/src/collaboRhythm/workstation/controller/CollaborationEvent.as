package collaboRhythm.workstation.controller
{
	import collaboRhythm.workstation.model.User;
	
	import flash.events.Event;

	public class CollaborationEvent extends Event
	{
		public static const COLLABORATE_WITH_USER:String = "CollaborateWithUser";

		public static const OPEN_RECORD:String = "OpenRecord";
		public static const CLOSE_RECORD:String = "CloseRecord";
		public static const RECORD_CLOSED:String = "RecordClosed";
		
		public static const LOCAL_USER_JOINED_COLLABORATION_ROOM_ANIMATION_COMPLETE:String = "LocalUserJoinedCollaborationRoom";
		
		private var _remoteUser:User;
		
		public function CollaborationEvent(type:String, remoteUser:User)
		{
			super(type);
			_remoteUser = remoteUser; 
		}

		public function get remoteUser():User 
		{
			return _remoteUser;
		}
	}
}