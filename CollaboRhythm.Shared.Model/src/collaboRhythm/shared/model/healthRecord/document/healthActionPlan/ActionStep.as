package collaboRhythm.shared.model.healthRecord.document.healthActionPlan
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	[Bindable]
	public class ActionStep extends Action
	{
		private var _name:CodedValue;
		private var _type:CodedValue;
		private var _additionalDetails:String;
		private var _instructions:String;

		public function ActionStep()
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

		public function get type():CodedValue
		{
			return _type;
		}

		public function set type(value:CodedValue):void
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
