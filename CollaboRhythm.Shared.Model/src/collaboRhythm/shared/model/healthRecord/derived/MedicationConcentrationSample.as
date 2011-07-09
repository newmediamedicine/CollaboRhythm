package collaboRhythm.shared.model.healthRecord.derived
{
	[Bindable]
	public class MedicationConcentrationSample
	{
		private var _date:Date;
		private var _concentration:Number;

		public function MedicationConcentrationSample()
		{
		}

		public function get date():Date
		{
			return _date;
		}

		public function set date(value:Date):void
		{
			_date = value;
		}

		public function get concentration():Number
		{
			return _concentration;
		}

		public function set concentration(value:Number):void
		{
			_concentration = value;
		}
	}
}
