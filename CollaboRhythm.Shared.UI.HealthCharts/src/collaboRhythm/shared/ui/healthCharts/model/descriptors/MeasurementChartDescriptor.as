package collaboRhythm.shared.ui.healthCharts.model.descriptors
{
	public class MeasurementChartDescriptor implements IChartDescriptor
	{
		private var _measurementCode:String;
		
		public function MeasurementChartDescriptor()
		{
		}

		public function get descriptorKey():String
		{
			return "measurement_" + measurementCode;
		}

		public function get measurementCode():String
		{
			return _measurementCode;
		}

		public function set measurementCode(value:String):void
		{
			_measurementCode = value;
		}
	}
}
