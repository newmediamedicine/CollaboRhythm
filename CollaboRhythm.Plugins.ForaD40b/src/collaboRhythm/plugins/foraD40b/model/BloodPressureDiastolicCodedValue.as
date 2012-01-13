package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodPressureDiastolicCodedValue extends CodedValue
	{
		public static const VALUE:String = "124";
		public static const ABBREV:String = "BPdia";
		public static const TEXT:String = "Blood Pressure Diastolic";

		public function BloodPressureDiastolicCodedValue()
		{
			type = VitalSign.CODED_VALUE_TYPE;
			value = VALUE;
			abbrev = ABBREV;
			text = TEXT;
		}
	}
}
