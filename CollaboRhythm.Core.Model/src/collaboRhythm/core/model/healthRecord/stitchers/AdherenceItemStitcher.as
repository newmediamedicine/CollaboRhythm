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

	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;
	import collaboRhythm.shared.model.healthRecord.Relationship;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionResult;
	import collaboRhythm.shared.model.healthRecord.document.MedicationAdministration;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class AdherenceItemStitcher extends DocumentStitcherBase
    {
        public function AdherenceItemStitcher(record:Record)
        {
			super(record, AdherenceItem.DOCUMENT_TYPE);
			addRequiredDocumentType(MedicationAdministration.DOCUMENT_TYPE);
			addRequiredDocumentType(VitalSign.DOCUMENT_TYPE);
			addRequiredDocumentType(HealthActionResult.DOCUMENT_TYPE);
		}

		override protected function stitchSpecialReferencesOnDocument(document:IDocument):void
		{
			var adherenceItem:AdherenceItem = document as AdherenceItem;
			for each (var relationship:Relationship in document.relatesTo)
			{
				// relatesTo may be null if the related document is replaced or voided or fails to be loaded for some other reason
				if (relationship.type == AdherenceItem.RELATION_TYPE_ADHERENCE_RESULT && relationship.relatesTo != null)
				{
					adherenceItem.adherenceResults.push(relationship.relatesTo);
				}
			}
		}
    }
}
