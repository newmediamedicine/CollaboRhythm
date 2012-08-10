package collaboRhythm.shared.collaboration.view
{
	import flash.events.Event;

	public class CollaborationInvitationPopUpEvent extends Event
	{
		public static const ACCEPT:String = "Accept";
		public static const REJECT:String = "Reject";
		public static const CANCEL:String = "Cancel";

		public function CollaborationInvitationPopUpEvent(type:String)
		{
			super(type)
		}
	}
}
