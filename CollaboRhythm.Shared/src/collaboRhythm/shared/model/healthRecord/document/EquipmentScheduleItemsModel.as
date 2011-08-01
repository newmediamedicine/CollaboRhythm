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
	public class EquipmentScheduleItemsModel extends DocumentCollectionBase
	{
        private var _equipmentScheduleItems:HashMap = new HashMap();

		public function EquipmentScheduleItemsModel()
		{
			super(EquipmentScheduleItem.DOCUMENT_TYPE);
		}

        public function get equipmentScheduleItems():HashMap
        {
            return _equipmentScheduleItems;
        }

        public function set equipmentScheduleItems(value:HashMap):void
        {
            _equipmentScheduleItems = value;
        }

        public function get equipmentScheduleItemColleciton():ArrayCollection
        {
            return documents;
        }

		override public function addDocument(document:IDocument):void
		{
			super.addDocument(document);
			equipmentScheduleItems.put(document.meta.id, document);
		}

		override public function handleUpdatedId(oldId:String, document:IDocument):void
		{
			super.removeDocument(document);
			equipmentScheduleItems.remove(oldId);

			addDocument(document);
		}

		override public function removeDocument(document:IDocument):void
		{
			super.removeDocument(document);
			equipmentScheduleItems.remove(document.meta.id);
		}
	}
}