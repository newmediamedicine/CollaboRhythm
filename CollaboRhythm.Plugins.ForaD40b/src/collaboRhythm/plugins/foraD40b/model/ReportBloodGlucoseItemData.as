package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.BloodGlucoseHealthActionInputController;

	[Bindable]
	public class ReportBloodGlucoseItemData
	{
		private var _dataInputModel:BloodGlucoseHealthActionInputModel;
		private var _dataInputController:BloodGlucoseHealthActionInputController;

		public function ReportBloodGlucoseItemData(dataInputModel:BloodGlucoseHealthActionInputModel,
							  dataInputController:BloodGlucoseHealthActionInputController)
		{
			_dataInputModel = dataInputModel;
			_dataInputController = dataInputController;
		}

		public function get dataInputModel():BloodGlucoseHealthActionInputModel
		{
			return _dataInputModel;
		}

		public function set dataInputModel(value:BloodGlucoseHealthActionInputModel):void
		{
			_dataInputModel = value;
		}

		public function get dataInputController():BloodGlucoseHealthActionInputController
		{
			return _dataInputController;
		}

		public function set dataInputController(value:BloodGlucoseHealthActionInputController):void
		{
			_dataInputController = value;
		}
	}
}
