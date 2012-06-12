package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;

	public class HealthActionOccurrencesModel extends DocumentCollectionBase
	{
		public function HealthActionOccurrencesModel()
		{
			super(HealthActionOccurrence.DOCUMENT_TYPE);
		}
	}
}
