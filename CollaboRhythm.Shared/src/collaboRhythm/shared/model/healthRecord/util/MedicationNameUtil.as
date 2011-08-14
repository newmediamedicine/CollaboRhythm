package collaboRhythm.shared.model.healthRecord.util
{

	public class MedicationNameUtil
	{
		public function MedicationNameUtil()
		{
		}

		public static function parseName(nameString:String):MedicationName
		{
			var medicationName:MedicationName = new MedicationName();

			var rxNormRegExp:RegExp = /(24 HR )?([A-Za-z\s]+)(\d+(?:\.\d+)? MG )([A-Za-z\s]+)\s?(\[[A-Za-z]+\])?/;
			var substrings:Array = nameString.split(rxNormRegExp);

			medicationName.medicationName = substrings[2];
			medicationName.strength = substrings[3];
			medicationName.form = substrings[4];
			if (substrings[5])
			{
				medicationName.proprietaryName = substrings[5];
			}
			return medicationName;
		}
	}
}
