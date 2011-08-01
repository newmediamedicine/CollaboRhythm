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
	public class MedicationOrdersModel extends DocumentCollectionBase
	{
        private var _medicationOrders:HashMap = new HashMap();

		public function MedicationOrdersModel()
		{
			super(MedicationOrder.DOCUMENT_TYPE);
		}

        public function get medicationOrders():HashMap
        {
            return _medicationOrders;
        }

        public function set medicationOrders(value:HashMap):void
        {
            _medicationOrders = value;
        }

        public function get medicationOrdersCollection():ArrayCollection
        {
            return documents;
        }

		override public function addDocument(document:IDocument):void
		{
			super.addDocument(document);
			var medicationOrder:MedicationOrder = document as MedicationOrder;
			medicationOrders.put(medicationOrder.meta.id, medicationOrder);
		}

		override public function handleUpdatedId(oldId:String, document:IDocument):void
		{
			super.removeDocument(document);
			medicationOrders.remove(oldId);

			addDocument(document);
		}

		override public function removeDocument(document:IDocument):void
		{
			super.removeDocument(document);
			medicationOrders.remove(document.meta.id);
		}
	}
}
