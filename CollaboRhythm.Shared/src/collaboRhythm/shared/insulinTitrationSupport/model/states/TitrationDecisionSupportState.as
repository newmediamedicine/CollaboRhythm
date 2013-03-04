package collaboRhythm.shared.insulinTitrationSupport.model.states
{
	import mx.collections.ArrayCollection;

	public class TitrationDecisionSupportState
	{
		private var _selectors:ArrayCollection; // Vector.<String>;
		private var _steps:ArrayCollection; // Vector.<Step>;
		private var _stepNumber:Number;

		public function TitrationDecisionSupportState()
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

		public function get stepNumber():Number
		{
			return _stepNumber;
		}

		public function set stepNumber(value:Number):void
		{
			_stepNumber = value;
		}
	}
}
