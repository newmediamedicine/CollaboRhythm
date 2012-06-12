package collaboRhythm.shared.model.healthRecord.document.healthActionResult
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;

	[Bindable]
	public class StopCondition
	{
		private var _name:CodedValue;
		private var _value:ValueAndUnit;

		public function StopCondition()
		{
		}
	}
}
