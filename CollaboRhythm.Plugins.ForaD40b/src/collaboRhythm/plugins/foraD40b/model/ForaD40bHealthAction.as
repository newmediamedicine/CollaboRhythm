package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.EquipmentHealthAction;

	public class ForaD40bHealthAction extends EquipmentHealthAction
	{
		public static const BLOOD_PRESSURE_INSTRUCTIONS_MATCH_LIST:Vector.<String> = new <String>["blood pressure", "systolic", "diastolic"];
		public static const BLOOD_GLUCOSE_PARTIAL_INSTRUCTIONS:String = "blood glucose";

		public function ForaD40bHealthAction(name:String, equipmentName:String, instructions:String)
		{
			super(name, equipmentName, instructions);
		}

		public function get isBloodPressure():Boolean
		{
			if (instructions)
			{
				for each (var pattern:String in BLOOD_PRESSURE_INSTRUCTIONS_MATCH_LIST)
				{
					if (instructions.toLowerCase().indexOf(pattern) != -1)
						return true;
				}
			}
			return false;
		}

		public function get isBloodGlucose():Boolean
		{
			return instructions && instructions.toLowerCase().indexOf(BLOOD_GLUCOSE_PARTIAL_INSTRUCTIONS) != -1;
		}
	}
}
