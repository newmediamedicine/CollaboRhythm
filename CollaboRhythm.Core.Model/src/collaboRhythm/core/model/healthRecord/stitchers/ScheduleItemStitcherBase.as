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

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var scheduleItem:ScheduleItemBase = document as ScheduleItemBase;
			var failedStitch:Vector.<String> = new Vector.<String>();

			for each (var adherenceItemId:String in scheduleItem.adherenceItems.keys)
			{
				if (adherenceItemId)
				{
					var adherenceItem:AdherenceItem = record.adherenceItemsModel.adherenceItems[adherenceItemId];
					if (adherenceItem)
					{
						scheduleItem.adherenceItems[adherenceItemId] = adherenceItem;
					}
					else
					{
						// AdherenceItem may not be loaded into model if it was filtered out based on the demo date
						scheduleItem.adherenceItems.remove(adherenceItemId);
						failedStitch.push(adherenceItemId);
					}
				}
				else
				{
					_logger.warn("Warning: Failed to stitch. scheduleItem.adherenceItems.keys contains a null value");
				}
			}
			logSpecialFailedStitches(document, failedStitch, "adherenceItem", "AdherenceItem");
        }
	}
}
