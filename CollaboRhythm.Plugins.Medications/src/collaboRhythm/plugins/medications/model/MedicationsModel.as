/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.plugins.medications.model
{
	import collaboRhythm.plugins.medications.controller.MedicationsAppController;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleGroup;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	import collaboRhythm.shared.model.User;
	
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;

	[Bindable]
	public class MedicationsModel
	{
		private var _user:User;
		private var _medicationsReportXML:XML;
		private var _medicationScheduleItemsReportXML:XML;
		private var _rawData:XML;
		private var _medicationsCollection:ArrayCollection = new ArrayCollection();
		private var _medicationScheduleItemsCollection:ArrayCollection = new ArrayCollection();
		private var _shortMedicationsCollection:ArrayCollection = new ArrayCollection();
		private var _initialized:Boolean = false;
		private var _isLoading:Boolean = false;
		public static const MEDICATIONS_KEY:String = "medications";
		
		public function MedicationsModel(user:User)
		{
			_user = user;
		}
		
		public function get medicationsReportXML():XML
		{
			return _medicationsReportXML;
		}
		
		public function set medicationsReportXML(value:XML):void
		{
			_medicationsReportXML = value;
			createMedicationsCollection();
		}
		
		public function get medicationScheduleItemsReportXML():XML
		{
			return _medicationScheduleItemsReportXML;
		}

		public function set medicationScheduleItemsReportXML(value:XML):void
		{
			_medicationScheduleItemsReportXML = value;
			createMedicationScheduleItemsCollection();
			_initialized = true;
		}

		public function get isLoading():Boolean
		{
			return _isLoading;
		}

		public function set isLoading(value:Boolean):void
		{
			_isLoading = value;
		}

		public function get shortMedicationsCollection():ArrayCollection
		{
			return _shortMedicationsCollection;
		}

		public function set shortMedicationsCollection(value:ArrayCollection):void
		{
			_shortMedicationsCollection = value;
		}

		public function get rawData():XML
		{
			return _rawData;
		}
		
		public function set rawData(value:XML):void
		{
			_rawData = value;
//			createMedicationsCollection();
			initialized = true;
		}

		public function get medicationsCollection():ArrayCollection
		{
			return _medicationsCollection;
		}

		public function set medicationsCollection(value:ArrayCollection):void
		{
			_medicationsCollection = value;
		}
		
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function set initialized(value:Boolean):void
		{
			_initialized = value;
		}
		
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
		
		private function createMedicationsCollection():void
		{
			for each (var medicationReportXML:XML in _medicationsReportXML.Report)
			{
				var medication:Medication = new Medication(medicationReportXML);
				_user.registerDocument(medication, medication);
				_medicationsCollection.addItem(medication);
			}
		}
		
		private function createMedicationScheduleItemsCollection():void
		{
			for each (var medicationScheduleItemReport:XML in _medicationScheduleItemsReportXML.Report)
			{
				var medicationScheduleItem:MedicationScheduleItem = new MedicationScheduleItem(medicationScheduleItemReport);
				_user.registerDocument(medicationScheduleItem, medicationScheduleItem);
				medicationScheduleItem.scheduledAction = _user.resolveDocumentById(medicationScheduleItem.scheduledActionID, Medication) as Medication;
				var scheduleGroup:ScheduleGroup = _user.resolveDocumentById(medicationScheduleItem.scheduleGroupID, ScheduleGroup) as ScheduleGroup;
				scheduleGroup.scheduleItemsCollection.addItem(medicationScheduleItem);
				_medicationScheduleItemsCollection.addItem(medicationScheduleItem);
			}
		}
	}
}