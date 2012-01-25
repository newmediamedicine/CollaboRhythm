package collaboRhythm.shared.ui.healthCharts.model.descriptors
{
	public class VitalSignChartDescriptor implements IChartDescriptor
	{
		private var _vitalSignCategory:String;

		public function VitalSignChartDescriptor()
		{
		}

		public function get descriptorKey():String
		{
			return "vitalSign_" + vitalSignCategory;
		}

		public function get vitalSignCategory():String
		{
			return _vitalSignCategory;
		}

		public function set vitalSignCategory(value:String):void
		{
			_vitalSignCategory = value;
		}
	}
}
