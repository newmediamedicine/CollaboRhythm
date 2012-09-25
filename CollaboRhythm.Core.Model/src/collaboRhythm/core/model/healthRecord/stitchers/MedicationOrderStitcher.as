/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.core.model.healthRecord.stitchers
{

	import collaboRhythm.shared.model.*;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.MedicationFill;
	import collaboRhythm.shared.model.healthRecord.document.MedicationOrder;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;

	import mx.collections.ArrayCollection;

	import spark.collections.Sort;
	import spark.collections.SortField;

	public class MedicationOrderStitcher extends DocumentStitcherBase
	{
		public function MedicationOrderStitcher(record:Record)
		{
			super(record, MedicationOrder.DOCUMENT_TYPE);
			addRequiredDocumentType(MedicationFill.DOCUMENT_TYPE);
			addRequiredDocumentType(MedicationScheduleItem.DOCUMENT_TYPE);
			addRequiredDocumentType(HealthActionResult.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var medicationOrder:MedicationOrder = document as MedicationOrder;
			relateMedicationFill(medicationOrder);
			relateMedicationScheduleItems(medicationOrder);
		}

		private function relateMedicationFill(medicationOrder:MedicationOrder):void
		{
			var medicationFills:ArrayCollection = new ArrayCollection();

			for each (var relationship:Relationship in medicationOrder.relatesTo)
			{
				// relatesTo may be null if the related document is replaced or voided or fails to be loaded for some other reason
				if (relationship.type == MedicationOrder.RELATION_TYPE_MEDICATION_FILL &&
						relationship.relatesTo != null)
				{
					medicationFills.addItem(relationship.relatesTo);
				}
			}

			var sort:Sort = new Sort();
			sort.fields = [new SortField("dateFilled")];
			sort.reverse();
			medicationFills.sort = sort;
			medicationFills.refresh();

			medicationOrder.medicationFill = medicationFills.getItemAt(0) as MedicationFill;
		}

		private function relateMedicationScheduleItems(medicationOrder:MedicationOrder):void
		{
			var failedStitch:Vector.<String> = new Vector.<String>();
			for each (var scheduleItemId:String in medicationOrder.scheduleItems.keys)
			{
				var medicationScheduleItem:MedicationScheduleItem = record.medicationScheduleItemsModel.medicationScheduleItems[scheduleItemId];
				if (medicationScheduleItem)
				{
					medicationOrder.scheduleItems.put(scheduleItemId, medicationScheduleItem);
					medicationScheduleItem.scheduledMedicationOrder = medicationOrder;
				}
				else
				{
					// MedicationScheduleItem may not be loaded into model if it was filtered out based on the demo date
					medicationOrder.scheduleItems.remove(scheduleItemId);
					failedStitch.push(scheduleItemId);
				}
			}
			logSpecialFailedStitches(medicationOrder, failedStitch, "scheduleItem", "MedicationScheduleItem");
		}
	}
}
