package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class ActionStepResult extends ActionResult
	{
		private var _name:CollaboRhythmCodedValue;
		private var _occurrences:ArrayCollection;

		public function ActionStepResult()
		{
		}

		public function get name():CollaboRhythmCodedValue
		{
			return _name;
		}

		public function set name(value:CollaboRhythmCodedValue):void
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
