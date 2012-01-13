package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	public class BeatsPerMinuteCodedValue extends CodedValue
	{
		public static const TYPE:String = "http://codes.indivo.org/units/";
		public static const VALUE:String = "32";
		public static const ABBREV:String = "BPM";
		public static const TEXT:String = "beats per minute";

		public function BeatsPerMinuteCodedValue()
		{
			type = TYPE;
			value = VALUE;
			abbrev = ABBREV;
			text = TEXT;
		}
	}
}
