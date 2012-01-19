package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.HealthActionInputControllerBase;

	public class HealthActionInputModelAndController
    {
		private var _healthActionInputModel:HealthActionInputModelBase;
		private var _healthActionInputController:HealthActionInputControllerBase;

		public function HealthActionInputModelAndController(dataInputModel:HealthActionInputModelBase, dataInputController:HealthActionInputControllerBase)
        {
			_healthActionInputModel = dataInputModel;
			_healthActionInputController = dataInputController;
		}

		public function get healthActionInputModel():HealthActionInputModelBase
		{
			return _healthActionInputModel;
		}

		public function get healthActionInputController():HealthActionInputControllerBase
		{
			return _healthActionInputController;
		}
	}
}
