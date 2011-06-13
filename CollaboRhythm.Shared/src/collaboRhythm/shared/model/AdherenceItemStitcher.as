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
package collaboRhythm.shared.model
{

    import mx.binding.utils.BindingUtils;

    public class AdherenceItemStitcher
    {
        private var _adherenceItemsModel:AdherenceItemsModel;
        private var _medicationAdministrationsModel:MedicationAdministrationsModel;

        public function AdherenceItemStitcher(adherenceItemsModel:AdherenceItemsModel, medicationAdministrationsModel:MedicationAdministrationsModel)
        {
            _adherenceItemsModel = adherenceItemsModel;
            _medicationAdministrationsModel = medicationAdministrationsModel;

            BindingUtils.bindSetter(adherenceItemsModelInitializedHandler, _adherenceItemsModel, "isInitialized");
            BindingUtils.bindSetter(medicationAdministationsModelInitializedHandler, _medicationAdministrationsModel, "isInitialized");

        }

        private function adherenceItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _medicationAdministrationsModel.isInitialized)
            {
                relateMedicationAdministration();
            }
        }

        private function medicationAdministationsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _adherenceItemsModel.isInitialized)
            {
                relateMedicationAdministration();
            }
        }

        private function relateMedicationAdministration():void
        {
            for each (var adherenceItem:AdherenceItem in _adherenceItemsModel.adherenceItems)
            {
                adherenceItem.adherenceResult = _medicationAdministrationsModel.medicationAdministrations[adherenceItem.adherenceResultId];
            }
            _adherenceItemsModel.isStitched = true;
        }
    }
}
