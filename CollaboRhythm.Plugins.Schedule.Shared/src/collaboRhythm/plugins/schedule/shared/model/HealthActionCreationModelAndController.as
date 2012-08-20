package collaboRhythm.plugins.schedule.shared.model
{
	public class HealthActionCreationModelAndController
	{
		private var _healthActionCreationModel:IHealthActionCreationModel;
		private var _medicationHealthActionCreationController:IHealthActionCreationController;

		public function HealthActionCreationModelAndController(healthActionCreationModel:IHealthActionCreationModel, healthActionCreationController:IHealthActionCreationController)
		{
			_healthActionCreationModel = healthActionCreationModel;
			_medicationHealthActionCreationController = healthActionCreationController;
		}

		public function get healthActionCreationModel():IHealthActionCreationModel
		{
			return _healthActionCreationModel;
		}

		public function set healthActionCreationModel(value:IHealthActionCreationModel):void
		{
			_healthActionCreationModel = value;
		}

		public function get healthActionCreationController():IHealthActionCreationController
		{
			return _medicationHealthActionCreationController;
		}

		public function set healthActionCreationController(value:IHealthActionCreationController):void
		{
			_medicationHealthActionCreationController = value;
		}
	}
}
