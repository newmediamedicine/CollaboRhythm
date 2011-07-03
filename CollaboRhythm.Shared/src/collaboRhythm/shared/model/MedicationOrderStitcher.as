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

    public class MedicationOrderStitcher
    {
        private var _medicationOrdersModel:MedicationOrdersModel;
        private var _medicationFillsModel:MedicationFillsModel;
        private var _medicationScheduleItemsModel:MedicationScheduleItemsModel;

        public function MedicationOrderStitcher(medicationOrdersModel:MedicationOrdersModel, medicationFillsModel:MedicationFillsModel, medicationScheduleItemsModel:MedicationScheduleItemsModel)
        {
            _medicationOrdersModel = medicationOrdersModel;
            _medicationFillsModel = medicationFillsModel;
            _medicationScheduleItemsModel = medicationScheduleItemsModel;

            BindingUtils.bindSetter(medicationOrdersModelInitializedHandler, _medicationOrdersModel, "isInitialized");
            BindingUtils.bindSetter(medicationFillsModelInitializedHandler, _medicationFillsModel, "isInitialized");
            BindingUtils.bindSetter(medicationScheduleItemsModelInitializedHandler, _medicationScheduleItemsModel, "isInitialized");
        }

        private function medicationOrdersModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized)
            {
                if (_medicationFillsModel.isInitialized)
                {
                    relateMedicationFill();
                }
                if (_medicationScheduleItemsModel.isInitialized)
                {
                    relateMedicationScheduleItems();
                }
            }
        }

        private function medicationFillsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _medicationOrdersModel.isInitialized)
            {
                relateMedicationFill();
            }
        }

        private function medicationScheduleItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _medicationOrdersModel.isInitialized)
            {
                relateMedicationScheduleItems();
            }
        }

        private function relateMedicationFill():void
        {
            for each (var medicationOrder:MedicationOrder in _medicationOrdersModel.medicationOrders)
            {
                medicationOrder.medicationFill = _medicationFillsModel.medicationFills[medicationOrder.medicationFillId];
            }
        }

        private function relateMedicationScheduleItems():void
        {
            for each (var medicationOrder:MedicationOrder in _medicationOrdersModel.medicationOrders)
            {
                for each (var scheduleItemId:String in medicationOrder.scheduleItems.keys)
                {
                    var medicationScheduleItem:MedicationScheduleItem = _medicationScheduleItemsModel.medicationScheduleItems[scheduleItemId];
                    if (medicationScheduleItem)
                    {
                        medicationOrder.scheduleItems[scheduleItemId] = medicationScheduleItem;
                        medicationScheduleItem.scheduledMedicationOrder = medicationOrder;
                    }
                }
            }
            _medicationOrdersModel.isStitched = true;
        }
    }
}
