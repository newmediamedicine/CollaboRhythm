package collaboRhythm.workstation.model
{
	import flash.events.Event;

	/**
	 * 
	 * @author jom
	 * 
	 * Event that is dispatched when the UserDatabaseService completes querying users from the UserCredentials database.
	 * 
	 */
	public class UserDatabaseEvent extends Event
	{
		public static const COMPLETE:String = "Complete";
		
		public function UserDatabaseEvent(type:String)
		{
			super(type);
		}
	}
}