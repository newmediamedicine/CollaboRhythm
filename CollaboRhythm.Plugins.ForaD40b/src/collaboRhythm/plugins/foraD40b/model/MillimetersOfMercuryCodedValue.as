package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	public class MillimetersOfMercuryCodedValue extends CodedValue
	{
		public static const TYPE:String = "http://codes.indivo.org/units/";
		public static const VALUE:String = "31";
		public static const ABBREV:String = "mmHg";
		public static const TEXT:String = "millimeters of mercury";

		public function MillimetersOfMercuryCodedValue()
		{
			type = TYPE;
			value = VALUE;
			abbrev = ABBREV;
			text = TEXT;
		}
	}
}
