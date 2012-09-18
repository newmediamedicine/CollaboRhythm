package collaboRhythm.tablet.model
{
	import flash.events.Event;

	public class ViewNavigatorExtendedEvent extends Event
	{
		public static const VIEW_POPPED:String = "ViewPopped";

		public function ViewNavigatorExtendedEvent(type:String)
		{
			super(type);
		}
	}
}
