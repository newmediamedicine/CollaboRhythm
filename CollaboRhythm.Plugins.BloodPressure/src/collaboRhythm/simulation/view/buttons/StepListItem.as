package collaboRhythm.simulation.view.buttons
{
	/**
	 * Model class for an item to be rendered by the StepListItemRenderer, used in the list of the SimulationDetailButton.
	 */
	[Bindable]
	public class StepListItem
	{
		public var text:String;
		public var color:uint;

		public function StepListItem(text:String, color:uint)
		{
			this.text = text;
			this.color = color;
		}
	}
}
