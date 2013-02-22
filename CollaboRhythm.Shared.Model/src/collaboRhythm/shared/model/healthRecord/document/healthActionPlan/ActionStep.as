package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;

	[Bindable]
	public class ActionStep extends Action
	{
		private var _name:CollaboRhythmCodedValue;
		private var _type:CollaboRhythmCodedValue;
		private var _additionalDetails:String;
		private var _instructions:String;

		public function ActionStep()
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

		public function get type():CollaboRhythmCodedValue
		{
			return _type;
		}

		public function set type(value:CollaboRhythmCodedValue):void
		{
			_type = value;
		}

		public function get additionalDetails():String
		{
			return _additionalDetails;
		}

		public function set additionalDetails(value:String):void
		{
			_additionalDetails = value;
		}

		public function get instructions():String
		{
			return _instructions;
		}

		public function set instructions(value:String):void
		{
			_instructions = value;
		}
	}
}
