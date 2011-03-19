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
package collaboRhythm.plugins.equipment.model
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.shared.model.User;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class EquipmentModel
	{
		private var _user:User;
		private var _equipmentReportXML:XML;
		private var _equipmentScheduleItemsReportXML:XML;
		private var _rawData:XML;
		private var _equipmentCollection:ArrayCollection = new ArrayCollection();
		private var _equipmentScheduleItemsCollection:ArrayCollection = new ArrayCollection();
		private var _initialized:Boolean = false;
		private var _isLoading:Boolean = false;
		
		public static const EQUIPMENT_KEY:String = "equipment";
		
		public function EquipmentModel(user:User)
		{
			_user = user;
		}
		
		public function get equipmentReportXML():XML
		{
			return _equipmentReportXML;
		}
		
		public function set equipmentReportXML(value:XML):void
		{
			_equipmentReportXML = value;
			createEquipmentCollection();
		}
		
		public function get equipmentScheduleItemsReportXML():XML
		{
			return _equipmentScheduleItemsReportXML;
		}
		
		public function set equipmentScheduleItemsReportXML(value:XML):void
		{
			_equipmentScheduleItemsReportXML = value;
			createEquipmentScheduleItemsCollection();
			_initialized = true;
		}
		
		public function get rawData():XML
		{
			return _rawData;
		}
		
		public function set rawData(value:XML):void
		{
			_rawData = value;
			//			createequipmentCollection();
			initialized = true;
		}
		
		public function get equipmentCollection():ArrayCollection
		{
			return _equipmentCollection;
		}
		
		public function set equipmentCollection(value:ArrayCollection):void
		{
			_equipmentCollection = value;
		}
			
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function set initialized(value:Boolean):void
		{
			_initialized = value;
		}
		
		public function get isLoading():Boolean
		{
			return _isLoading;
		}
		
		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
		}
		
		private function createEquipmentCollection():void
		{
			for each (var currentEquipmentReportXML:XML in _equipmentReportXML.Report)
			{
				var equipment:Equipment = new Equipment(currentEquipmentReportXML);
				_user.registerDocument(equipment, equipment);
				_equipmentCollection.addItem(equipment);
			}
		}
		
		private function createEquipmentScheduleItemsCollection():void
		{
			for each (var equipmentScheduleItemReport:XML in _equipmentScheduleItemsReportXML.Report)
			{
				//TODO: Remove this hack when EquimpmentScheduleItems have been implemented
				if (equipmentScheduleItemReport.Item.MedicationScheduleItem.name.toString() == "Fora D15b")
				{
					var equipmentScheduleItem:EquipmentScheduleItem = new EquipmentScheduleItem(equipmentScheduleItemReport);
					_user.registerDocument(equipmentScheduleItem, equipmentScheduleItem);
					equipmentScheduleItem.scheduledAction = _user.resolveDocumentById(equipmentScheduleItem.scheduledActionID, Equipment) as Equipment;
					var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(equipmentScheduleItem.scheduleGroupID, ScheduleGroup) as ScheduleGroup;
					scheduleGroup.scheduleItemsCollection.addItem(equipmentScheduleItem);
					_equipmentScheduleItemsCollection.addItem(equipmentScheduleItem);
				}
			}
		}
	}
}