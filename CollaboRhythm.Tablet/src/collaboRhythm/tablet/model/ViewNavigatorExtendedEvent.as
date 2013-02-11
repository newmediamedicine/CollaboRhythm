package collaboRhythm.tablet.model
{
	import flash.events.Event;

	public class ViewNavigatorExtendedEvent extends Event
	{
		/**
		 * Event indicating that a view is being popped. This will generally only be dispatched when a view is popped
		 * on the master (controlling) side of a collaboration interaction. On the slave (remote) side, the event
		 * should not be dispatched even though the view gets popped.
		 */
		public static const VIEW_POPPED:String = "ViewPopped";

		public function ViewNavigatorExtendedEvent(type:String)
		{
			super(type);
		}
	}
}
