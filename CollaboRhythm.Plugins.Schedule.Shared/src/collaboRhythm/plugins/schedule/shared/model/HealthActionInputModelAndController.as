package collaboRhythm.plugins.schedule.shared.model
{
	public class HealthActionInputModelAndController
    {
		private var _healthActionInputModel:IHealthActionInputModel;
		private var _healthActionInputController:IHealthActionInputController;

		public function HealthActionInputModelAndController(healthActionInputModel:IHealthActionInputModel,
															healthActionInputController:IHealthActionInputController)
        {
			_healthActionInputModel = healthActionInputModel;
			_healthActionInputController = healthActionInputController;
		}

		public function get healthActionInputModel():IHealthActionInputModel
		{
			return _healthActionInputModel;
		}

		public function get healthActionInputController():IHealthActionInputController
		{
			return _healthActionInputController;
		}
	}
}
