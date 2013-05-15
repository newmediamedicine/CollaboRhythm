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
		 *  Oxybutynin chloride 1 MG/ML Oral Solution [Ditropan]
		 *
		 * @param medicationNameText
		 * @return
		 */
		public static function parseName(medicationNameText:String):MedicationName
		{
			var substrings:Array = medicationNameText.split(" / ");

			if (substrings.length == 1)
			{
				return  parseSingleIngredientName(medicationNameText);
			}
			else
			{
				var combinedName:MedicationName = new MedicationName();
				combinedName.rawName = medicationNameText;
				for each (var ingredient:String in substrings)
				{
					var medicationName:MedicationName = parseSingleIngredientName(ingredient);

					if (medicationName.medicationName)
						combinedName.medicationName = (combinedName.medicationName == null ? "" : (combinedName.medicationName + " / ")) +  medicationName.medicationName;
					if (medicationName.fillQuantity)
						combinedName.fillQuantity = (combinedName.fillQuantity == null ? "" : combinedName.fillQuantity + " / ") +  medicationName.fillQuantity;
					if (medicationName.strength)
						combinedName.strength = (combinedName.strength == null ? "" : combinedName.strength + " / ") +  medicationName.strength;
					if (medicationName.form)
						combinedName.form = (combinedName.form == null ? "" : combinedName.form + " / ") +  medicationName.form;
					if (medicationName.proprietaryName)
						combinedName.proprietaryName = (combinedName.proprietaryName == null ? "" : combinedName.proprietaryName + " / ") +  medicationName.proprietaryName;
				}
				return combinedName;
			}
		}

		private static function parseSingleIngredientName(medicationNameText:String):MedicationName
		{
			var medicationName:MedicationName = new MedicationName();
			medicationName.rawName = medicationNameText;

			var rxNormRegExp:RegExp = /(?:(\d+ HR) )?(?:(\d+(?:\.\d+)? (?:ML|MG|ACTUAT)) )?([A-Za-z\s]+) (\d+(?:\.\d+)? (?:UNT\/ML|ML|MG\/ACTUAT|MG\/ML|MG))(?:([A-Za-z\s]+))?(?:(\[[A-Za-z]+\]))?/;

			var substrings:Array = medicationNameText.split(rxNormRegExp);

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
