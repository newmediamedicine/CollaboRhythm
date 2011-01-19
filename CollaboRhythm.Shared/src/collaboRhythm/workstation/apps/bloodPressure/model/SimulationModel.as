package collaboRhythm.workstation.apps.bloodPressure.model
{
	[Bindable]
	public class SimulationModel
	{
		private var _date:Date;
		private var _dataPointDate:Date;
		private var _systolic:Number;
		private var _diastolic:Number;
		private var _concentration:Number;
		
		public function SimulationModel()
		{
		}

		public function get dataPointDate():Date
		{
			return _dataPointDate;
		}

		public function set dataPointDate(value:Date):void
		{
			_dataPointDate = value;
		}

		public function get date():Date
		{
			return _date;
		}

		public function set date(value:Date):void
		{
			_date = value;
		}

		public function get systolic():Number
		{
			return _systolic;
		}

		public function set systolic(value:Number):void
		{
			_systolic = value;
		}

		public function get diastolic():Number
		{
			return _diastolic;
		}

		public function set diastolic(value:Number):void
		{
			_diastolic = value;
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