package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class HeartRateCodedValue extends CodedValue
	{
		public static const VALUE:String = "125";
		public static const ABBREV:String = "HR";
		public static const TEXT:String = "Heart Rate";

		public function HeartRateCodedValue()
		{
			type = VitalSign.CODED_VALUE_TYPE;
			value = VALUE;
			abbrev = ABBREV;
			text = TEXT;
		}
	}
}
