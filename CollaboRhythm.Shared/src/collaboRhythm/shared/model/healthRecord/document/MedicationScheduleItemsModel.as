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
package collaboRhythm.shared.model.healthRecord.document
{

	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class MedicationScheduleItemsModel extends DocumentCollectionBase
	{
        private var _medicationScheduleItems:HashMap = new HashMap();

		public function MedicationScheduleItemsModel()
		{
			super(MedicationScheduleItem.DOCUMENT_TYPE);
		}

        public function get medicationScheduleItems():HashMap
        {
            return _medicationScheduleItems;
        }

        public function set medicationScheduleItems(value:HashMap):void
        {
            _medicationScheduleItems = value;
        }

        public function get medicationScheduleItemCollection():ArrayCollection
        {
            return documents;
        }

		override public function addDocument(document:IDocument):void
		{
			super.addDocument(document);
			medicationScheduleItems.put(document.meta.id, document);
		}

		override public function handleUpdatedId(oldId:String, document:IDocument):void
		{
			super.removeDocument(document);
			medicationScheduleItems.remove(oldId);

			addDocument(document);
		}

		override public function removeDocument(document:IDocument):void
		{
			super.removeDocument(document);
			medicationScheduleItems.remove(document.meta.id);
		}
	}
}