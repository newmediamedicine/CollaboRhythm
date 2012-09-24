package collaboRhythm.plugins.schedule.shared.model
{
	import collaboRhythm.shared.model.healthRecord.util.MedicationName;
	import collaboRhythm.shared.model.healthRecord.util.MedicationNameUtil;

	public class MedicationHealthAction extends HealthActionBase
	{
		public static const TYPE:String = "Medication";
		public static const NAME:String = "MedicationAdministration";

		private var _medicationOrderName:String;
		private var _medicationName:MedicationName;
		private var _medicationCode:String;

		public function MedicationHealthAction(medicationOrderName:String, medicationCode:String)
		{
			super(TYPE, NAME);
			_medicationOrderName = medicationOrderName;
			_medicationCode = medicationCode;
			_medicationName = MedicationNameUtil.parseName(medicationOrderName);
		}

		public function get medicationOrderName():String
		{
			return _medicationOrderName;
		}

		public function get medicationName():MedicationName
		{
			return _medicationName;
		}

		public function get medicationCode():String
		{
			return _medicationCode;
		}
	}
}
