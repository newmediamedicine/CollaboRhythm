package collaboRhythm.shared.ui.healthCharts.model
{
	public class MedicationChartDescriptor implements IChartDescriptor
	{
		private var _medicationName:String;
		
		public function MedicationChartDescriptor()
		{
		}

		public function get chartKey():String
		{
			return "medication_" + medicationName;
		}

		public function get medicationName():String
		{
			return _medicationName;
		}

		public function set medicationName(value:String):void
		{
			_medicationName = value;
		}
	}
}
