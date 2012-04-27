package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	public class CodedValueFactory
	{
		public static const VITAL_SIGN_CODED_VALUE_TYPE:String = "http://codes.indivo.org/vitalsigns/";
		public static const UNITS_CODED_VALUE_TYPE:String = "http://codes.indivo.org/units/";

		public static const BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE:String = "123";
		public static const BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_ABBREV:String = "BPsys";
		public static const BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_TEXT:String = "Blood Pressure Systolic";

		public static const BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE:String = "124";
		public static const BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_ABBREV:String = "BPdia";
		public static const BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_TEXT:String = "Blood Pressure Diastolic";

		public static const HEART_RATE_CODED_VALUE:String = "125";
		public static const HEART_RATE_CODED_VALUE_ABBREV:String = "HR";
		public static const HEART_RATE_CODED_VALUE_TEXT:String = "Heart Rate";

		public static const BLOOD_GLUCOSE_CODED_VALUE:String = "126";
		public static const BLOOD_GLUCOSE_CODED_VALUE_ABBREV:String = "BG";
		public static const BLOOD_GLUCOSE_CODED_VALUE_TEXT:String = "Blood Glucose";

		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE:String = "31";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_ABBREV:String = "mmHg";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_TEXT:String = "millimeters of mercury";

		public static const BEATS_PER_MINUTE_CODED_VALUE:String = "32";
		public static const BEATS_PER_MINUTE_CODED_VALUE_ABBREV:String = "BPM";
		public static const BEATS_PER_MINUTE_CODED_VALUE_TEXT:String = "beats per minute";

		public static const MILLIGRAMS_PER_DECILITER_CODED_VALUE:String = "33";
		public static const MILLIGRAMS_PER_DECILITER_CODED_VALUE_ABBREV:String = "mg/dL";
		public static const MILLIGRAMS_PER_DECILITER_CODED_VALUE_TEXT:String = "milligrams per deciliter";

		public function CodedValueFactory()
		{
		}

		public function createBloodPressureSystolicCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE,
					BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_ABBREV, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_TEXT);
		}

		public function createBloodPressureDiastolicCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE,
					BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_ABBREV, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_TEXT);
		}

		public function createHeartRateCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, HEART_RATE_CODED_VALUE, HEART_RATE_CODED_VALUE_ABBREV,
					HEART_RATE_CODED_VALUE_TEXT);
		}

		public function createBloodGlucoseCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_GLUCOSE_CODED_VALUE,
					BLOOD_GLUCOSE_CODED_VALUE_ABBREV, BLOOD_GLUCOSE_CODED_VALUE_TEXT);
		}

		public function createMillimetersOfMercuryCodedValue():CodedValue
		{
			return new CodedValue(UNITS_CODED_VALUE_TYPE, MILLIMETERS_OF_MERCURY_CODED_VALUE,
					MILLIMETERS_OF_MERCURY_CODED_VALUE_ABBREV, MILLIMETERS_OF_MERCURY_CODED_VALUE_TEXT);
		}

		public function createBeatsPerMinuteCodedValue():CodedValue
		{
			return new CodedValue(UNITS_CODED_VALUE_TYPE, BEATS_PER_MINUTE_CODED_VALUE,
					BEATS_PER_MINUTE_CODED_VALUE_ABBREV, BEATS_PER_MINUTE_CODED_VALUE_TEXT);
		}

		public function createMilligramsPerDeciliterCodedValue():CodedValue
		{
			return new CodedValue(UNITS_CODED_VALUE_TYPE, MILLIGRAMS_PER_DECILITER_CODED_VALUE,
					MILLIGRAMS_PER_DECILITER_CODED_VALUE_ABBREV, MILLIGRAMS_PER_DECILITER_CODED_VALUE_TEXT);
		}
	}
}
