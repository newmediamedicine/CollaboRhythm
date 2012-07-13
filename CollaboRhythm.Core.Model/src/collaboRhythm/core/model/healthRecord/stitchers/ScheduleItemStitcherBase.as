package collaboRhythm.core.model.healthRecord.stitchers
{

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;

	public class ScheduleItemStitcherBase extends DocumentStitcherBase
	{
		public function ScheduleItemStitcherBase(record:Record, documentTypeToStitch:String)
		{
			super(record, documentTypeToStitch);
			addRequiredDocumentType(AdherenceItem.DOCUMENT_TYPE);
		}
	}
}
