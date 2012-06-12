package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	public class ChartModelDetails implements IChartModelDetails
	{
		private var _record:Record;
		private var _accountId:String;
		private var _currentDateSource:ICurrentDateSource;
		private var _healthChartsModel:HealthChartsModel;

		public function ChartModelDetails(record:Record, accountId:String,
										  currentDateSource:ICurrentDateSource, healthChartsModel:HealthChartsModel)
		{
			_record = record;
			_accountId = accountId;
			_currentDateSource = currentDateSource;
			_healthChartsModel = healthChartsModel;
		}

		public function get record():Record
		{
			return _record;
		}

		public function get accountId():String
		{
			return _accountId;
		}

		public function get currentDateSource():ICurrentDateSource
		{
			return _currentDateSource;
		}

		public function get healthChartsModel():HealthChartsModel
		{
			return _healthChartsModel;
		}
	}
}
