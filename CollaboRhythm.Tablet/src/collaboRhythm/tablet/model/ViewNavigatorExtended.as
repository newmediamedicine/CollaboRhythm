package collaboRhythm.tablet.model
{
	import spark.components.ViewNavigator;
	import spark.transitions.ViewTransitionBase;
	import mx.core.mx_internal;

	/**
	 * Extends ViewNavigator to add dispatching of an event when a view is popped via the normal popView method.
	 * Exposes a method (popViewRemote) for preventing the dispatching of this event.
	 */
	public class ViewNavigatorExtended extends ViewNavigator
	{
		public function ViewNavigatorExtended()
		{
			super();
		}

		override public function popView(transition:ViewTransitionBase = null):void
		{
			super.popView(transition);

			if (!(mx_internal::navigationStack.length == 0 || !mx_internal::canRemoveCurrentView()))
			{
				dispatchEvent(new ViewNavigatorExtendedEvent(ViewNavigatorExtendedEvent.VIEW_POPPED));
			}
		}

		/**
		 * Pops a view without dispatching ViewNavigatorExtendedEvent.VIEW_POPPED. This is generally only called on
		 * the remote (slave) side of an collaboration so that the slave does not send a message back to the master
		 * to perform another (redundant) pop.
		 * @param transition The view transition to play while switching views.
		 */
		public function popViewRemote(transition:ViewTransitionBase = null):void
		{
			super.popView(transition);
		}
	}
}
