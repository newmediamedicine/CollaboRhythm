package collaboRhythm.workstation.apps.medications.model
{
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	import mx.graphics.ImageSnapshot;

	[Bindable]
	public class MedicationsModel
	{
		private var _rawData:XML;
		private var _medicationsCollection:ArrayCollection;
		private var _shortMedicationsCollection:ArrayCollection;
		private var _initialized:Boolean = false;
		private var _isLoading:Boolean = false;
		
		public function MedicationsModel()
		{
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
//					if (medication.name != "Hydrochlorothiazide")
//					{
						_shortMedicationsCollection.addItem(medication);
//					}
				}
			}
		}
	}
}