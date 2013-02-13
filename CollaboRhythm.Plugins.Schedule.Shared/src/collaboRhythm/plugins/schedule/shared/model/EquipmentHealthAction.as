package collaboRhythm.plugins.schedule.shared.model
{
	public class EquipmentHealthAction extends HealthActionBase
	{
		public static const TYPE:String = "Equipment";

		private var _equipmentName:String;
		private var _instructions:String;

		public function EquipmentHealthAction(name:String, equipmentName:String, instructions:String)
		{
			super(TYPE, name);
			_equipmentName = equipmentName;
			_instructions = instructions;
		}

		public function get equipmentName():String
		{
			return _equipmentName;
		}

		public function get instructions():String
		{
			return _instructions;
		}
	}
}
