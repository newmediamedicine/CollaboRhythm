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
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemBase;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleModel;
	
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;

	[Bindable]
	public class MedicationsModel
	{
		private var _scheduleModel:ScheduleModel;
		private var _rawData:XML;
		private var _medicationsCollection:ArrayCollection;
		private var _shortMedicationsCollection:ArrayCollection;
		private var _initialized:Boolean = false;
		private var _isLoading:Boolean = false;
		public static const MEDICATIONS_KEY:String = "medications";
		
		public function MedicationsModel(scheduleModel:ScheduleModel)
		{
			_scheduleModel = scheduleModel;
			_medicationsCollection = new ArrayCollection();
			_shortMedicationsCollection = new ArrayCollection();
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
			createMedicationsCollection();
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
		
		private function createMedicationsCollection():void
		{
			for each (var medicationReportXML:XML in _rawData.Report)
			{
				var medication:Medication = new Medication(medicationReportXML);
				if (medication.dateStopped == null)
				{
					_medicationsCollection.addItem(medication);
					_shortMedicationsCollection.addItem(medication);
	
					_scheduleModel.addScheduleItem(medication.documentID, medication);
				}
			}
		}
	}
}