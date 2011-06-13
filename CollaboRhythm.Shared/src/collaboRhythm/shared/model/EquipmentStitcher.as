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

    public class EquipmentStitcher
    {
        private var _equipmentModel:EquipmentModel;
        private var _equipmentScheduleItemsModel:EquipmentScheduleItemsModel;

        public function EquipmentStitcher(equipmentModel:EquipmentModel, equipmentScheduleItemsModel:EquipmentScheduleItemsModel)
        {
            _equipmentModel = equipmentModel;
            _equipmentScheduleItemsModel = equipmentScheduleItemsModel;

            BindingUtils.bindSetter(equipmentModelInitializedHandler, _equipmentModel, "isInitialized");
            BindingUtils.bindSetter(equipmentScheduleItemsModelInitializedHandler, _equipmentScheduleItemsModel, "isInitialized");
        }

        private function equipmentModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _equipmentScheduleItemsModel.isInitialized)
            {
                relateEquipmentScheduleItems();
            }
        }

        private function equipmentScheduleItemsModelInitializedHandler(isInitialized:Boolean):void
        {
            if (isInitialized && _equipmentModel.isInitialized)
            {
                relateEquipmentScheduleItems();
            }
        }

        private function relateEquipmentScheduleItems():void
        {
            for each (var equipment:Equipment in _equipmentModel.equipment)
            {
                for each (var scheduleItemId:String in equipment.scheduleItems.keys)
                {
                    var equipmentScheduleItem:EquipmentScheduleItem = _equipmentScheduleItemsModel.equipmentScheduleItems[scheduleItemId];
                    equipment.scheduleItems[scheduleItemId] = equipmentScheduleItem;
                    equipmentScheduleItem.scheduledEquipment = equipment;
                }
            }
            _equipmentModel.isStitched = true;
        }
    }
}