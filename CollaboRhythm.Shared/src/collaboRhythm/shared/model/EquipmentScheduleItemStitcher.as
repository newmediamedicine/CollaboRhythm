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

	import collaboRhythm.shared.model.healthRecord.document.AdherenceItemsModel;

	import mx.binding.utils.BindingUtils;

    public class EquipmentScheduleItemStitcher
    {
        private var _equipmentScheduleItemsModel:EquipmentScheduleItemsModel;
        private var _adherenceItemsModel:AdherenceItemsModel;

        public function EquipmentScheduleItemStitcher(equipmentScheduleItemsModel:EquipmentScheduleItemsModel, adherenceItemsModel:AdherenceItemsModel)
        {
            _equipmentScheduleItemsModel = equipmentScheduleItemsModel;
            _adherenceItemsModel = adherenceItemsModel;

            BindingUtils.bindSetter(equipmentScheduleItemsModelInitializedHandler, _equipmentScheduleItemsModel, "isInitialized");
            BindingUtils.bindSetter(adherenceItemsModelInitializedHandler, _adherenceItemsModel, "isInitialized");

        }

        private function equipmentScheduleItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _adherenceItemsModel.isInitialized)
            {
                relateAdherenceItems();
            }
        }

        private function adherenceItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _equipmentScheduleItemsModel.isInitialized)
            {
                relateAdherenceItems();
            }
        }

        private function relateAdherenceItems():void
        {
            for each (var equipmentScheduleItem:EquipmentScheduleItem in _equipmentScheduleItemsModel.equipmentScheduleItems)
            {
                for each (var adherenceItemId:String in equipmentScheduleItem.adherenceItems.keys)
                {
                    equipmentScheduleItem.adherenceItems[adherenceItemId] = _adherenceItemsModel.adherenceItems[adherenceItemId];
                }
            }
            _equipmentScheduleItemsModel.isStitched = true;
        }
    }
}
