package collaboRhythm.core.model
{
	import collaboRhythm.core.model.healthRecord.HealthRecordServiceFacade;
	import collaboRhythm.core.model.healthRecord.service.DocumentStorageServiceBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	public class HealthRecordServiceModel
	{
		private var _document:IDocument;
		private var _healthRecordServiceFacade:HealthRecordServiceFacade;

		public function HealthRecordServiceModel(document:IDocument,
															   healthRecordServiceFacade:HealthRecordServiceFacade)
		{
			_document = document;
			_healthRecordServiceFacade = healthRecordServiceFacade;
		}

		public function get documentXml():String
		{
			if (_healthRecordServiceFacade && _document && _document.meta.type)
			{
				var service:DocumentStorageServiceBase = _healthRecordServiceFacade.getService(_document.meta.type);
				if (service)
				{
					return service.marshallToXml(_document);
				}
			}
			return "";
		}
	}
}
