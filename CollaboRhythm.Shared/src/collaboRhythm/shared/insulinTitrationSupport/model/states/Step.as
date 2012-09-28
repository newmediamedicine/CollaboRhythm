package collaboRhythm.shared.insulinTitrationSupport.model.states
{
	import mx.collections.ArrayCollection;

	public class Step
	{
		private var _stepText:String;
		private var _stepIcon:String;
		private var _stepColor:String;
		private var _subSteps:ArrayCollection; // of String objects
		
		public function Step()
		{
		}

		public function get stepText():String
		{
			return _stepText;
		}

		public function set stepText(value:String):void
		{
			_stepText = value;
		}

		public function get stepIcon():String
		{
			return _stepIcon;
		}

		public function set stepIcon(value:String):void
		{
			_stepIcon = value;
		}

		public function get stepColor():String
		{
			return _stepColor;
		}

		public function set stepColor(value:String):void
		{
			_stepColor = value;
		}

		public function get subSteps():ArrayCollection
		{
			return _subSteps;
		}

		public function set subSteps(value:ArrayCollection):void
		{
			_subSteps = value;
		}
	}
}
