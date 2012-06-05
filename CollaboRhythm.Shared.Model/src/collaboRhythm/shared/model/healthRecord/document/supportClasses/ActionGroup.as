package collaboRhythm.shared.model.healthRecord.document.supportClasses
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ActionGroup extends Action
	{
		private var _repeatCount:Number;
		private var _actions:ArrayCollection;

		public function ActionGroup()
		{
		}

		public function get repeatCount():Number
		{
			return _repeatCount;
		}

		public function set repeatCount(value:Number):void
		{
			_repeatCount = value;
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
