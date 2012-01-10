package collaboRhythm.simulation.view.buttons
{
	import mx.core.mx_internal;

	import spark.components.List;
	use namespace mx_internal;

	/**
	 * List component which does not allow item selection.
	 */
	public class SelectionlessList extends List
	{
		public function SelectionlessList()
		{
		}

		/**
		 * Override the setSelectedIndex() mx_internal method to not select any items.
		 */
		override mx_internal function setSelectedIndex(value:int, dispatchChangeEvent:Boolean = false, changeCaret:Boolean = true):void
		{
		}

		/**
		 * Override the setSelectedIndex() mx_internal method to not select any items.
		 */
		override mx_internal function setSelectedIndices(value:Vector.<int>, dispatchChangeEvent:Boolean = false, changeCaret:Boolean = true):void
		{
		}
	}
}
