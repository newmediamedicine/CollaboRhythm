package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ActionGroupResult extends ActionResult
	{
		private var _actions:ArrayCollection;

		public function ActionGroupResult()
		{
		}

		public function get actions():ArrayCollection
		{
			return _actions;
		}

		public function set actions(value:ArrayCollection):void
		{
			_actions = value;
		}
	}
}
