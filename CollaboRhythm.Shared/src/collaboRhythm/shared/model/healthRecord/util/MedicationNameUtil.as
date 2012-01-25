package collaboRhythm.shared.model.healthRecord.util
{
	import collaboRhythm.shared.model.StringUtils;

	public class MedicationNameUtil
	{
		public function MedicationNameUtil()
		{
		}

		/**
		 * Parses names of various formats.
		 * Examples:
		 * 	Hydrochlorothiazide 25 MG Oral Tablet
		 * 	24 HR Diltiazem Hydrochloride 240 MG Extended Release Capsule
		 * 	3 ML insulin detemir 100 UNT/ML Prefilled Syringe [Levemir]
		 * 	Lisinopril 2.5 MG Oral Tablet [Zestril]
		 *  200 ACTUAT Albuterol 0.09 MG/ACTUAT Metered Dose Inhaler [Proventil]
		 *
		 * @param nameString
		 * @return
		 */
		public static function parseName(nameString:String):MedicationName
		{
			var medicationName:MedicationName = new MedicationName();

			var rxNormRegExp:RegExp = /(?:(\d+ HR) )?(?:(\d+(?:\.\d+)? (?:ML|MG|ACTUAT)) )?([A-Za-z\s]+) (\d+(?:\.\d+)? (?:MG|UNT\/ML|ML|MG\/ACTUAT)) ([A-Za-z\s]+)(?:(\[[A-Za-z]+\]))?/;

			var substrings:Array = nameString.split(rxNormRegExp);

			medicationName.fillQuantity = substrings[2];
			medicationName.medicationName = substrings[3];
			medicationName.strength = substrings[4];
			medicationName.form = StringUtils.trim(substrings[5]);
			if (substrings[6])
			{
				medicationName.proprietaryName = substrings[6];
			}
			return medicationName;
		}
	}
}
