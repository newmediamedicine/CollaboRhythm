package collaboRhythm.core.model.healthRecord.stitchers
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class VitalSignStitcher extends DocumentStitcherBase
	{
		public function VitalSignStitcher(record:Record)
		{
			super(record, VitalSign.DOCUMENT_TYPE);
			addRequiredDocumentType(HealthActionResult.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var vitalSign:VitalSign = document as VitalSign;
			for each (var triggeredHealthActionResultRelationship:Relationship in vitalSign.relatesTo)
			{
				var triggeredHealthActionResult:HealthActionResult = triggeredHealthActionResultRelationship.relatesTo as HealthActionResult;
				if (triggeredHealthActionResult)
				{
					vitalSign.triggeredHealthActionResults.push(triggeredHealthActionResult);
				}
			}
		}
	}
}
