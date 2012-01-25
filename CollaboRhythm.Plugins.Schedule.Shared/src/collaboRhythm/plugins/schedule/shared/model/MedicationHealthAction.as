package collaboRhythm.plugins.schedule.shared.model
{
	public class MedicationHealthAction extends HealthActionBase
	{
		public static const TYPE:String = "Medication";
		public static const NAME:String = "MedicationAdministration";

		private var _medicationOrderName:String;

		public function MedicationHealthAction(medicationOrderName:String)
		{
			super(TYPE, NAME);
			_medicationOrderName = medicationOrderName;
		}

		public function get medicationOrderName():String
		{
			return _medicationOrderName;
		}
	}
}
