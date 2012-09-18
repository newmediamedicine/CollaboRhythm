package collaboRhythm.tablet.model
{
	import spark.components.ViewNavigator;
	import spark.transitions.ViewTransitionBase;
	import mx.core.mx_internal;

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

		public function popViewRemote(transition:ViewTransitionBase = null):void
		{
			super.popView(transition);
		}
	}
}
