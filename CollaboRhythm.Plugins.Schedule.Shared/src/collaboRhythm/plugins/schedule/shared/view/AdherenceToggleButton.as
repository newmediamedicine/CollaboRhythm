package collaboRhythm.plugins.schedule.shared.view
{

	import flash.events.Event;

	import spark.components.ToggleButton;

	public class AdherenceToggleButton extends ToggleButton
	{
		public function AdherenceToggleButton()
		{
			super();
		}

		override protected function buttonReleased():void
		{
			// Normally, the button would be toggled here. Instead, the adherence toggle button is selected based on
			// data binding depending on whether a corresponding adherenceItem is associated with it.
		}
	}
}
