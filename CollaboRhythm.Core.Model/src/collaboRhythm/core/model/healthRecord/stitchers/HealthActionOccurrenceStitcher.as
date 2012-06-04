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
	import collaboRhythm.shared.model.healthRecord.document.HealthActionOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;

	public class HealthActionOccurrenceStitcher extends DocumentStitcherBase
    {
        public function HealthActionOccurrenceStitcher(record:Record)
		{
			super(record, HealthActionOccurrence.DOCUMENT_TYPE);
			addRequiredDocumentType(HealthActionResult.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var healthActionOccurrence:HealthActionOccurrence = document as HealthActionOccurrence;
			for each (var healthActionResultRelationship:Relationship in healthActionOccurrence.relatesTo)
			{
				var healthActionResult:HealthActionResult = healthActionResultRelationship.relatesTo as HealthActionResult;
				if (healthActionResult)
				{
					healthActionOccurrence.results.addItem(healthActionResult);
					healthActionResult.healthActionOccurrence = healthActionOccurrence;
				}
			}
        }
    }
}