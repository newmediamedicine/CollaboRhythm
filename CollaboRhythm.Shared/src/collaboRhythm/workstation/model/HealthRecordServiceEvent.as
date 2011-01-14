package collaboRhythm.workstation.model
{
	import flash.events.Event;
	
	public class HealthRecordServiceEvent extends Event
	{
		/**
		 * Indicates that the login operation has completed successfully.  
		 */
		public static const LOGIN_COMPLETE:String = "loginComplete";

		/**
		 * Indicates that the primary operation of the service has completed successfully.  
		 */
		public static const COMPLETE:String = "complete";
		
		/**
		 * Indicates that an operation of the service has completed successfully.  
		 */
		public static const UPDATE:String = "update";
		
		private var _user:User;
		
		public function HealthRecordServiceEvent(type:String, user:User=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_user = user;
		}

		/**
		 * The user associated with the event, if applicable. (Optional)
		 * @return the User object, or null if not applicable
		 * 
		 */
		public function get user():User
		{
			return _user;
		}

		public function set user(value:User):void
		{
			_user = value;
		}

	}
}