package collaboRhythm.shared.ui.healthCharts.model
{
	import collaboRhythm.shared.apps.healthCharts.model.HealthChartsModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.services.ICurrentDateSource;

	import flash.display.DisplayObjectContainer;

	public class ChartModelDetails implements IChartModelDetails
	{
		private var _record:Record;
		private var _accountId:String;
		private var _currentDateSource:ICurrentDateSource;
		private var _healthChartsModel:HealthChartsModel;
		private var _owner:DisplayObjectContainer;
		private var _componentContainer:IComponentContainer;

		public function ChartModelDetails(record:Record, accountId:String,
										  currentDateSource:ICurrentDateSource,
										  healthChartsModel:HealthChartsModel,
										  owner:DisplayObjectContainer,
										  componentContainer:IComponentContainer)
		{
			_record = record;
			_accountId = accountId;
			_currentDateSource = currentDateSource;
			_healthChartsModel = healthChartsModel;
			_owner = owner;
			_componentContainer = componentContainer;
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

		public function get owner():DisplayObjectContainer
		{
			return _owner;
		}

		public function get componentContainer():IComponentContainer
		{
			return _componentContainer;
		}

		public function set componentContainer(value:IComponentContainer):void
		{
			_componentContainer = value;
		}
	}
}
