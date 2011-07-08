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

    import collaboRhythm.shared.model.healthRecord.EquipmentHealthRecordService;
    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.binding.utils.BindingUtils;

    import mx.collections.ArrayCollection;

    [Bindable]
	public class EquipmentModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _equipmentHealthRecordService:EquipmentHealthRecordService;
        private var _equipment:HashMap = new HashMap();
        private var _equipmentCollection:ArrayCollection = new ArrayCollection();
        private var _currentDateSource:ICurrentDateSource;

		private var _shortEquipmentCollection:ArrayCollection = new ArrayCollection();
		private var _isInitialized:Boolean = false;
        private var _isStitched:Boolean;

		public function EquipmentModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _equipmentHealthRecordService = new EquipmentHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getEquipment():void
        {
             _equipmentHealthRecordService.getEquipment(_record);
        }

		public function set equipmentReportXml(value:XML):void
		{
			default xml namespace = "http://indivo.org/vocab/xml/documents#";
			for each (var equipmentOrderXml:XML in value.Report)
			{
				var equipment:Equipment = new Equipment();
                equipment.initFromReportXML(equipmentOrderXml);
                _equipment[equipment.id] = equipment;
                _equipmentCollection.addItem(equipment);
			}
            isInitialized = true;
		}

//        private function relateDocuments():void
//        {
//            for each (var equipment:Equipment in _equipment)
//            {
//                for each (var scheduleItemId:String in equipment.scheduleItems.keys)
//                {
//                    var equipmentScheduleItem:EquipmentScheduleItem = _equipmentScheduleItems[scheduleItemId];
//                    equipment.scheduleItems[scheduleItemId] = equipmentScheduleItem;
//                    equipmentScheduleItem.scheduledEquipment = equipment;
//
//                    for each (var adherenceItemId:String in equipmentScheduleItem.adherenceItems.keys)
//                    {
//                        var adherenceItem:AdherenceItem = _record.adherenceItemsModel.adherenceItems[adherenceItemId];
//                        equipmentScheduleItem.adherenceItems[adherenceItemId] = adherenceItem;
//
//                        for each (var medicationAdministrationId:String in adherenceItem.adherenceResultId)
//                        {
////                            adherenceItem.adherenceResult = _medicationAdministrations[medicationAdministrationId];
//                        }
//                    }
//                }
//            }
//            isInitialized = true;
//        }

//		public function get equipmentCollection():ArrayCollection
//		{
//			return _equipmentCollection;
//		}
//
//		public function set equipmentCollection(value:ArrayCollection):void
//		{
//			_equipmentCollection = value;
//		}
//
//		public function get initialized():Boolean
//		{
//			return _initialized;
//		}
//
//		public function set initialized(value:Boolean):void
//		{
//			_initialized = value;
//		}
//
//		public function get isLoading():Boolean
//		{
//			return _isLoading;
//		}
//
//		public function set isLoading(value:Boolean):void
//		{
//			_isLoading = value;
//		}
//
//		private function createEquipmentCollection():void
//		{
//			for each (var currentEquipmentReportXML:XML in _equipmentReportXML.Report)
//			{
//				var equipment:Equipment = new Equipment(currentEquipmentReportXML);
//				_user.registerDocument(equipment, equipment);
//				_equipmentCollection.addItem(equipment);
//			}
//		}
//
//		private function createEquipmentScheduleItemsCollection():void
//		{
//			for each (var equipmentScheduleItemReport:XML in _equipmentScheduleItemsReportXML.Report)
//			{
//				//TODO: Remove this hack when EquimpmentScheduleItems have been implemented
//				if (equipmentScheduleItemReport.Item.EquipmentScheduleItem.name.toString() == "Fora D15b")
//				{
//					var equipmentScheduleItem:EquipmentScheduleItem = new EquipmentScheduleItem(equipmentScheduleItemReport);
//					if (_user.containsDocumentById(equipmentScheduleItem.scheduledActionID))
//					{
//						equipmentScheduleItem.scheduledAction = _user.resolveDocumentById(equipmentScheduleItem.scheduledActionID,
//																						  Equipment) as Equipment;
//						if (_user.containsDocumentById(equipmentScheduleItem.scheduleGroupID))
//						{
//							var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(equipmentScheduleItem.scheduleGroupID,
//																						ScheduleGroup) as ScheduleGroup;
//							_user.registerDocument(equipmentScheduleItem, equipmentScheduleItem);
//							scheduleGroup.scheduleItemsCollection.addItem(equipmentScheduleItem);
//							_equipmentScheduleItemsCollection.addItem(equipmentScheduleItem);
//						}
//					}
//				}
//			}
//		}
        public function get equipment():HashMap
        {
            return _equipment;
        }

        public function set equipment(value:HashMap):void
        {
            _equipment = value;
        }

        public function get equipmentCollection():ArrayCollection
        {
            return _equipmentCollection;
        }

        public function set equipmentCollection(value:ArrayCollection):void
        {
            _equipmentCollection = value;
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
        }

        public function get isStitched():Boolean
        {
            return _isStitched;
        }

        public function set isStitched(value:Boolean):void
        {
            _isStitched = value;
        }
    }
}