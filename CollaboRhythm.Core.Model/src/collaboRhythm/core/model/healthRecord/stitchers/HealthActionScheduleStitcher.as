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
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;

	public class HealthActionScheduleStitcher extends ScheduleItemStitcherBase
    {
        public function HealthActionScheduleStitcher(record:Record)
		{
			super(record, HealthActionSchedule.DOCUMENT_TYPE);
			addRequiredDocumentType(HealthActionOccurrence.DOCUMENT_TYPE);
			addRequiredDocumentType(AdherenceItem.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			super.stitchSpecialReferencesOnDocument(document);

			var healthActionSchedule:HealthActionSchedule = document as HealthActionSchedule;
			for each (var healthActionOccurrenceRelationship:Relationship in healthActionSchedule.relatesTo)
			{
				var healthActionOccurrence:HealthActionOccurrence = healthActionOccurrenceRelationship.relatesTo as HealthActionOccurrence;
				if (healthActionOccurrence)
				{
					healthActionSchedule.occurrences.addItem(healthActionOccurrence);
//					healthActionOccurrence.schedule = healthActionSchedule;
				}
			}
	    }
    }
}
