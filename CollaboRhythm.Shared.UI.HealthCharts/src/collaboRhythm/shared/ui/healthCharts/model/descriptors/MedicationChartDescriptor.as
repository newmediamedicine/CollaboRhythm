package collaboRhythm.shared.ui.healthCharts.model.descriptors
{
	public class MedicationChartDescriptor implements IChartDescriptor
	{
		private var _medicationCode:String;
		private var _ndcCode:String;
		
		public function MedicationChartDescriptor()
		{
		}

		public function get descriptorKey():String
		{
			return "medication_" + medicationCode;
		}

		public function get medicationCode():String
		{
			return _medicationCode;
		}

		public function set medicationCode(value:String):void
		{
			_medicationCode = value;
		}

		public function get ndcCode():String
		{
			return _ndcCode;
		}

		public function set ndcCode(value:String):void
		{
			_ndcCode = value;
		}
	}
}
