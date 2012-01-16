package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;

	public class DataInputModelAndController
    {
		private var _dataInputModel:DataInputModelBase;
		private var _dataInputController:DataInputControllerBase;

		public function DataInputModelAndController(dataInputModel:DataInputModelBase, dataInputController:DataInputControllerBase)
        {
			_dataInputModel = dataInputModel;
			_dataInputController = dataInputController;
		}

		public function get dataInputModel():DataInputModelBase
		{
			return _dataInputModel;
		}

		public function get dataInputController():DataInputControllerBase
		{
			return _dataInputController;
		}
	}
}
