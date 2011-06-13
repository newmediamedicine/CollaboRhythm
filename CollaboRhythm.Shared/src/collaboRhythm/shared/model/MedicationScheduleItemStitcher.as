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

    public class MedicationScheduleItemStitcher
    {
        private var _medicationScheduleItemsModel:MedicationScheduleItemsModel;
        private var _adherenceItemsModel:AdherenceItemsModel;

        public function MedicationScheduleItemStitcher(medicationScheduleItemsModel:MedicationScheduleItemsModel, adherenceItemsModel:AdherenceItemsModel)
        {
            _medicationScheduleItemsModel = medicationScheduleItemsModel;
            _adherenceItemsModel = adherenceItemsModel;

            BindingUtils.bindSetter(medicationScheduleItemsModelInitializedHandler, _medicationScheduleItemsModel, "isInitialized");
            BindingUtils.bindSetter(adherenceItemsModelInitializedHandler, _adherenceItemsModel, "isInitialized");

        }

        private function medicationScheduleItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _adherenceItemsModel.isInitialized)
            {
                relateAdherenceItems();
            }
        }

        private function adherenceItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _medicationScheduleItemsModel.isInitialized)
            {
                relateAdherenceItems();
            }
        }

        private function relateAdherenceItems():void
        {
            for each (var medicationScheduleItem:MedicationScheduleItem in _medicationScheduleItemsModel.medicationScheduleItems)
            {
                for each (var adherenceItemId:String in medicationScheduleItem.adherenceItems.keys)
                {
                    medicationScheduleItem.adherenceItems[adherenceItemId] = _adherenceItemsModel.adherenceItems[adherenceItemId];
                }
            }
            _medicationScheduleItemsModel.isStitched = true;
        }
    }
}
