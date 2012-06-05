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
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.document.Equipment;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;

	public class EquipmentStitcher extends DocumentStitcherBase
    {
        public function EquipmentStitcher(record:Record)
		{
			super(record, Equipment.DOCUMENT_TYPE);
			addRequiredDocumentType(HealthActionSchedule.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var equipment:Equipment = document as Equipment;
			for each (var scheduleItemId:String in equipment.scheduleItems.keys)
			{
				var healthActionSchedule:HealthActionSchedule = record.healthActionSchedulesModel.healthActionSchedules[scheduleItemId];
				if (healthActionSchedule)
				{
					equipment.scheduleItems.put(scheduleItemId, healthActionSchedule);
					healthActionSchedule.scheduledEquipment = equipment;
				}
				else
				{
					// HealthActionSchedule may not be loaded into model if it was filtered out based on the demo date
					equipment.scheduleItems.remove(scheduleItemId);
					_logger.warn("Warning: Failed to stitch; scheduleItem relationship ignored. HealthActionSchedule not found with id " + scheduleItemId);
				}
			}
        }
    }
}