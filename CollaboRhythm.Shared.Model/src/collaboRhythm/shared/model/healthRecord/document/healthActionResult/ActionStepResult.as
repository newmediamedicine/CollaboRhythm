package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class ActionStepResult extends ActionResult
	{
		private var _name:CodedValue;
		private var _occurrences:ArrayCollection;

		public function ActionStepResult()
		{
		}

		public function get name():CodedValue
		{
			return _name;
		}

		public function set name(value:CodedValue):void
		{
			_name = value;
		}

		public function get occurrences():ArrayCollection
		{
			return _occurrences;
		}

		public function set occurrences(value:ArrayCollection):void
		{
			_occurrences = value;
		}
	}
}
