package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;

	public class HealthActionPlansModel extends DocumentCollectionBase
	{
		public function HealthActionPlansModel()
		{
			super(HealthActionPlan.DOCUMENT_TYPE);
		}
	}
}
