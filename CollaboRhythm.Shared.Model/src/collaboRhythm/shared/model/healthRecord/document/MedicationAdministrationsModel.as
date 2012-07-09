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

	import collaboRhythm.shared.model.DebugUtils;
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;
	import collaboRhythm.shared.model.healthRecord.IDocument;

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;

	[Event(name="updateComplete", type="mx.events.FlexEvent")]

	[Bindable]
	public class MedicationAdministrationsModel extends DocumentCollectionBase
	{
        private var _medicationAdministrations:HashMap = new HashMap();
		private var _medicationAdministrationsCollectionsByCode:HashMap = new HashMap();
		private var _medicationConcentrationCurvesByCode:HashMap = new HashMap();
		private const _debugCollectionChanges:Boolean = false;

		public function MedicationAdministrationsModel()
		{
			super(MedicationAdministration.DOCUMENT_TYPE);
		}

        public function get medicationAdministrations():HashMap
        {
            return _medicationAdministrations;
        }

        public function set medicationAdministrations(value:HashMap):void
        {
            _medicationAdministrations = value;
        }

        public function get medicationAdministrationsCollection():ArrayCollection
        {
            return documents;
        }

		/**
		 * Key is the medication RxCUI code (the MedicationAdministration.name.value). Value is an ArrayCollection of
		 * MedicationAdministration instances with the corresponding code.
		 */
		public function get medicationAdministrationsCollectionsByCode():HashMap
		{
			return _medicationAdministrationsCollectionsByCode;
		}

		/**
		 * Key is the medication RxCUI code (the MedicationAdministration.name.value). Value is an ArrayCollection of
		 * MedicationConcentrationSample instances with the corresponding code.
		 */
		public function get medicationConcentrationCurvesByCode():HashMap
		{
			return _medicationConcentrationCurvesByCode;
		}

		override public function addDocument(document:IDocument):void
		{
			validateDocumentType(document);
			addMedicationAdministration(document as MedicationAdministration);
		}

		public function addMedicationAdministration(medicationAdministration:MedicationAdministration):void
		{
			medicationAdministrations.put(medicationAdministration.meta.id, medicationAdministration);
			medicationAdministrationsCollection.addItem(medicationAdministration);
			addToMedicationAdministrationsCollectionsByCode(medicationAdministration);
		}

		protected function addToMedicationAdministrationsCollectionsByCode(medicationAdministration:MedicationAdministration):void
		{
			var collection:ArrayCollection = _medicationAdministrationsCollectionsByCode[medicationAdministration.name.value];
			if (collection == null)
			{
				collection = new ArrayCollection();
				_medicationAdministrationsCollectionsByCode.put(medicationAdministration.name.value, collection);
			}
			if (_debugCollectionChanges)
				_logger.debug("addToMedicationAdministrationsCollectionsByCode collection(" + DebugUtils.getObjectMemoryHash(collection) + ")");
			collection.addItem(medicationAdministration);
		}

		override public function handleUpdatedId(oldId:String, document:IDocument):void
		{
			super.removeDocument(document);
			medicationAdministrations.remove(oldId);
			removeFromMedicationAdministrationsCollectionsByCode(document as MedicationAdministration);

			addDocument(document);
		}

		override public function removeDocument(document:IDocument):void
		{
			super.removeDocument(document);
			medicationAdministrations.remove(document.meta.id);
			removeFromMedicationAdministrationsCollectionsByCode(document as MedicationAdministration);
		}

		protected function removeFromMedicationAdministrationsCollectionsByCode(medicationAdministration:MedicationAdministration):void
		{
			var collection:ArrayCollection = _medicationAdministrationsCollectionsByCode[medicationAdministration.name.value];
			if (collection != null)
			{
				if (collection.contains(medicationAdministration))
				{
					if (_debugCollectionChanges)
						_logger.debug("removeFromMedicationAdministrationsCollectionsByCode collection(" + DebugUtils.getObjectMemoryHash(collection) + ")");
					collection.removeItemAt(collection.getItemIndex(medicationAdministration));
				}
			}
		}

		public function hasMedicationConcentrationCurve(code:String):Boolean
		{
			return medicationConcentrationCurvesByCode.keys.contains(code) && medicationConcentrationCurvesByCode.getItem(code).length > 0;
		}

		public function clearMedicationAdministrations():void
		{
			medicationAdministrations.clear();
			medicationAdministrationsCollection.removeAll();
			medicationAdministrationsCollectionsByCode.clear();
		}

		public function updateComplete():void
		{
			dispatchEvent(new FlexEvent(FlexEvent.UPDATE_COMPLETE));
		}
	}
}
