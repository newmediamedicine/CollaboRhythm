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

    import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
    import collaboRhythm.shared.model.healthRecord.MedicationsHealthRecordService;
    import collaboRhythm.shared.model.services.ICurrentDateSource;
    import collaboRhythm.shared.model.services.WorkstationKernel;
    import collaboRhythm.shared.model.settings.Settings;

    import j2as3.collection.HashMap;

    import mx.collections.ArrayCollection;
    import mx.events.CollectionEvent;

    [Bindable]
	public class MedicationsModel
	{
        private var _activeAccount:Account;
		private var _record:Record;
        private var _medicationsHealthRecordService:MedicationsHealthRecordService;
        private var _medicationOrders:HashMap = new HashMap();
        private var _medicationScheduleItems:HashMap = new HashMap();
        private var _medicationOrdersCollection:ArrayCollection = new ArrayCollection();
        private var _medicationScheduleItemCollection:ArrayCollection = new ArrayCollection();
        private var _medicationAdministrations:HashMap = new HashMap();
        private var _medicationFills:HashMap = new HashMap();
        private var _currentDateSource:ICurrentDateSource;

		private var _shortMedicationsCollection:ArrayCollection = new ArrayCollection();
		private var _isInitialized:Boolean = false;
		private var _isLoading:Boolean = false;

		public function MedicationsModel(settings:Settings, activeAccount:Account, record:Record)
		{
            _activeAccount = activeAccount;
			_record = record;
            _medicationsHealthRecordService = new MedicationsHealthRecordService(settings.oauthChromeConsumerKey, settings.oauthChromeConsumerSecret, settings.indivoServerBaseURL, _activeAccount);
            _currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

        public function getMedications():void
        {
            _medicationsHealthRecordService.addEventListener(HealthRecordServiceEvent.COMPLETE, getMedicationsCompleteHandler);
            _medicationsHealthRecordService.getMedications(_record);
        }

		public function set medicationOrdersReportXml(value:XML):void
		{
			for each (var medicationOrderXml:XML in value.Report)
			{
				var medicationOrder:MedicationOrder = new MedicationOrder();
                medicationOrder.initFromReportXML(medicationOrderXml);
                _medicationOrders[medicationOrder.id] = medicationOrder;
                _medicationOrdersCollection.addItem(medicationOrder);
			}
		}

        public function set medicationScheduleItemsReportXml(value:XML):void
        {
            for each (var medicationScheduleItemXml:XML in value.Report)
            {
                var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem();
                medicationScheduleItem.initFromReportXML(medicationScheduleItemXml, "MedicationScheduleItem");
                _medicationScheduleItems[medicationScheduleItem.id] = medicationScheduleItem;
                _medicationScheduleItemCollection.addItem(medicationScheduleItem);
            }
        }

        public function getMedicationsCompleteHandler(event:HealthRecordServiceEvent):void
        {
            for each (var medicationOrder:MedicationOrder in _medicationOrders)
            {
                for each (var scheduleItemId:String in medicationOrder.scheduleItems)
                {
                    medicationOrder.scheduleItems[scheduleItemId] = _medicationScheduleItems[scheduleItemId];
                }
            }
            isInitialized = true;
        }

        public function set medicationAdministrationsReportXml(value:XML):void
        {
//            for each (var medicationAdministrationXml:XML in value.Report)
//            {
//                var medicationAdministration:MedicationAdministration = new MedicationAdministration();
//                medicationAdministration.initFromReportXML(medicationAdministrationXml);
//                _medicationAdministrations[medicationAdministration.id] = medicationAdministration;
//            }
        }

        public function set medicationFillsReportXml(value:XML):void
        {
//            for each (var medicationFillXml:XML in value.Report)
//            {
//                var medicationFill:MedicationFill = new MedicationFill();
//                medicationFill.initFromReportXML(medicationFillXml);
//                _medicationFills[medicationFill.id] = medicationFill;
//            }
        }

//		public function get shortMedicationsCollection():ArrayCollection
//		{
//			return _shortMedicationsCollection;
//		}
//
//		public function set shortMedicationsCollection(value:ArrayCollection):void
//		{
//			_shortMedicationsCollection = value;
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
		
//		public function addMedication(documentID:String, medicationXML:XML):void
//		{
//			var medication:Medication = new Medication(documentID, medicationXML);
//			_medicationsCollection.addItem(medication);
//		}
//		
//		public function addMedicationScheduleItem(documentID:String, medicationScheduleItemXML:XML):void
//		{
//			var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem(documentID, medicationScheduleItemXML);
//		}
//		
//		public function linkMedication(medicationScheduleItemID:String, medicationID:String):void
//		{
//			var medicationScheduleItem:MedicationsAppController = 
//			var medication:Medication = 
//			medicationScheduleItem.scheduledAction(medication);
//		}
		
//		private function createMedicationsCollection():void
//		{
//			for each (var medicationReportXML:XML in _medicationsReportXML.Report)
//			{
//				var medication:Medication = new Medication(medicationReportXML);
//				_user.registerDocument(medication, medication);
//				_medicationsCollection.addItem(medication);
//			}
//		}
//
//		private function createMedicationScheduleItemsCollection():void
//		{
//			for each (var medicationScheduleItemReport:XML in _medicationScheduleItemsReportXML.Report)
//			{
//				//TODO: Remove this hack when EquimpmentScheduleItems have been implemented
//				if (!(medicationScheduleItemReport.Item.MedicationScheduleItem.name.toString() == "Fora D15b"))
//				{
//					var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem(medicationScheduleItemReport);
//					if (_user.containsDocumentById(medicationScheduleItem.scheduledActionID))
//					{
//						medicationScheduleItem.scheduledAction = _user.resolveDocumentById(medicationScheduleItem.scheduledActionID, Medication) as Medication;
//						if (_user.containsDocumentById(medicationScheduleItem.scheduleGroupID))
//						{
//							var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(medicationScheduleItem.scheduleGroupID,
//																						ScheduleGroup) as ScheduleGroup;
//							_user.registerDocument(medicationScheduleItem, medicationScheduleItem);
//							scheduleGroup.scheduleItemsCollection.addItem(medicationScheduleItem);
//							_medicationScheduleItemsCollection.addItem(medicationScheduleItem);
//						}
//					}
//				}
//			}
//		}

        public function get medicationOrders():HashMap
        {
            return _medicationOrders;
        }

        public function set medicationOrders(value:HashMap):void
        {
            _medicationOrders = value;
        }

        public function get medicationScheduleItems():HashMap
        {
            return _medicationScheduleItems;
        }

        public function set medicationScheduleItems(value:HashMap):void
        {
            _medicationScheduleItems = value;
        }

        public function get medicationOrdersCollection():ArrayCollection
        {
            return _medicationOrdersCollection;
        }

        public function set medicationOrdersCollection(value:ArrayCollection):void
        {
            _medicationOrdersCollection = value;
        }

        public function get isInitialized():Boolean
        {
            return _isInitialized;
        }

        public function set isInitialized(value:Boolean):void
        {
            _isInitialized = value;
        }

        public function get medicationScheduleItemCollection():ArrayCollection
        {
            return _medicationScheduleItemCollection;
        }

        public function set medicationScheduleItemCollection(value:ArrayCollection):void
        {
            _medicationScheduleItemCollection = value;
        }
    }
}