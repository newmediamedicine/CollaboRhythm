package collaboRhythm.plugins.schedule.shared.model
{
	public class MedicationHealthAction extends HealthActionBase
	{
		public static const TYPE:String = "Medication";

		private var _medicationOrderName:String;

		public function MedicationHealthAction(name:String, medicationOrderName:String)
		{
			super(TYPE, name);
			_medicationOrderName = medicationOrderName;
		}

		public function get medicationOrderName():String
		{
			return _medicationOrderName;
		}
	}
}
