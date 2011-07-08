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

	import j2as3.collection.HashMap;

	import mx.collections.ArrayCollection;

	[Bindable]
	public class MedicationAdministrationsModel
	{
        private var _medicationAdministrations:HashMap = new HashMap();
        private var _medicationAdministrationsCollection:ArrayCollection = new ArrayCollection();
		private var _medicationAdministrationsCollectionsByCode:HashMap = new HashMap();
		private var _medicationConcentrationCurvesByCode:HashMap = new HashMap();

		private var _isInitialized:Boolean = false;

		public function MedicationAdministrationsModel()
		{
		}

		protected function addToMedicationAdministrationsCollectionsByCode(medicationAdministration:MedicationAdministration):void
		{
			var collection:ArrayCollection = _medicationAdministrationsCollectionsByCode[medicationAdministration.name.value];
			if (collection == null)
			{
				collection = new ArrayCollection();
				_medicationAdministrationsCollectionsByCode[medicationAdministration.name.value] = collection;
			}
			collection.addItem(medicationAdministration);
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
            return _medicationAdministrationsCollection;
        }

        public function set medicationAdministrationsCollection(value:ArrayCollection):void
        {
            _medicationAdministrationsCollection = value;
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
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

		public function addMedicationAdministration(medicationAdministration:MedicationAdministration):void
		{
			medicationAdministrations[medicationAdministration.id] = medicationAdministration;
			medicationAdministrationsCollection.addItem(medicationAdministration);
			addToMedicationAdministrationsCollectionsByCode(medicationAdministration);
		}

		public function hasMedicationConcentrationCurve(code:String):Boolean
		{
			return medicationConcentrationCurvesByCode.keys.contains(code) && medicationConcentrationCurvesByCode.length > 0;
		}
	}
}
