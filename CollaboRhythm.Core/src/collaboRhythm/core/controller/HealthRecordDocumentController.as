package collaboRhythm.core.controller
{
	import collaboRhythm.core.model.HealthRecordServiceModel;
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	public class HealthRecordDocumentController
	{
		private var _model:HealthRecordServiceModel;

		public function HealthRecordDocumentController(model:HealthRecordServiceModel)
		{
			_model = model;
		}

		public function get model():HealthRecordServiceModel
		{
			return _model;
		}
	}
}
