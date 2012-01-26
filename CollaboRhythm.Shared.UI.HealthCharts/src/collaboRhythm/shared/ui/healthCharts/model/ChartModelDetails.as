package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.model.Record;

	public class ChartModelDetails implements IChartModelDetails
	{
		private var _record:Record;
		private var _accountId:String;

		public function ChartModelDetails(record:Record, accountId:String)
		{
			_record = record;
			_accountId = accountId;
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}
	}
}
