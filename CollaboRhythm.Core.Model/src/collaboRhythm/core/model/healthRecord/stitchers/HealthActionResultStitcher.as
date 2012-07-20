package collaboRhythm.core.model.healthRecord.stitchers
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class HealthActionResultStitcher extends DocumentStitcherBase
	{
		public function HealthActionResultStitcher(record:Record)
		{
			super(record, HealthActionResult.DOCUMENT_TYPE);
			addRequiredDocumentType(VitalSign.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var healthActionResult:HealthActionResult = document as HealthActionResult;
			for each (var measurementRelationship:Relationship in healthActionResult.relatesTo)
			{
				var measurement:VitalSign = measurementRelationship.relatesTo as VitalSign;
				if (measurement)
				{
					healthActionResult.measurements.push(measurement);
				}
			}
		}
	}
}
