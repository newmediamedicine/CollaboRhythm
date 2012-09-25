package collaboRhythm.shared.insulinTitrationSupport.model.states
{
	import mx.collections.ArrayCollection;

	public class InsulinTitrationDecisionSupportState
	{
		private var _selectors:ArrayCollection; // Vector.<String>;
		private var _steps:ArrayCollection; // Vector.<Step>;

		public function InsulinTitrationDecisionSupportState()
		{
		}

		public function get selectors():ArrayCollection
		{
			return _selectors;
		}

		public function set selectors(value:ArrayCollection):void
		{
			_selectors = value;
		}

		public function get steps():ArrayCollection
		{
			return _steps;
		}

		public function set steps(value:ArrayCollection):void
		{
			_steps = value;
		}
	}
}
