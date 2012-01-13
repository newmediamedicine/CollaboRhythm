package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodPressureSystolicCodedValue extends CodedValue
	{
		public static const VALUE:String = "123";
		public static const ABBREV:String = "BPsys";
		public static const TEXT:String = "Blood Pressure Systolic";

		public function BloodPressureSystolicCodedValue()
		{
			type = VitalSign.CODED_VALUE_TYPE;
			value = VALUE;
			abbrev = ABBREV;
			text = TEXT;
		}
	}
}
