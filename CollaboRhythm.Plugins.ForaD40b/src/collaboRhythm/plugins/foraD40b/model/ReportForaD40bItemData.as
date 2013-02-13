package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.foraD40b.controller.ForaD40bHealthActionInputController;
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;

	[Bindable]
	public class ReportForaD40bItemData
	{
		private var _dataInputModel:ForaD40bHealthActionInputModelBase;
		private var _dataInputController:ForaD40bHealthActionInputController;

		public function ReportForaD40bItemData(dataInputModel:ForaD40bHealthActionInputModelBase,
							  dataInputController:ForaD40bHealthActionInputController)
		{
			_dataInputModel = dataInputModel;
			_dataInputController = dataInputController;
		}

		public function get dataInputModel():ForaD40bHealthActionInputModelBase
		{
			return _dataInputModel;
		}

		public function set dataInputModel(value:ForaD40bHealthActionInputModelBase):void
		{
			_dataInputModel = value;
		}

		public function get dataInputController():ForaD40bHealthActionInputController
		{
			return _dataInputController;
		}

		public function set dataInputController(value:ForaD40bHealthActionInputController):void
		{
			_dataInputController = value;
		}
	}
}
