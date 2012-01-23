package collaboRhythm.plugins.schedule.shared.model
{
	public class EquipmentHealthAction extends HealthActionBase
	{
		public static const TYPE:String = "Equipment";

		private var _equipmentName:String;

		public function EquipmentHealthAction(name:String, equipmentName:String)
		{
			super(TYPE, name);
			_equipmentName = equipmentName;
		}

		public function get equipmentName():String
		{
			return _equipmentName;
		}
	}
}
