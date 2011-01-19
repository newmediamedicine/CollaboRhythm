package collaboRhythm.workstation.view
{
	import flash.events.Event;
	
	public class WorkstationViewEvent extends Event
	{
		public static const HIDE:String = "hide";
		public static const SHOW:String = "show";
		
		public function WorkstationViewEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}