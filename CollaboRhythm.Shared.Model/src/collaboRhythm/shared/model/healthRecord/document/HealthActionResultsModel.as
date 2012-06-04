package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;

	public class HealthActionResultsModel extends DocumentCollectionBase
	{
		public function HealthActionResultsModel()
		{
			super(HealthActionResult.DOCUMENT_TYPE);
		}
	}
}
