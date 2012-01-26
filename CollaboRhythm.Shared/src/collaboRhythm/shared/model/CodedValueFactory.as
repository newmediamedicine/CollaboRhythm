package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.healthRecord.CodedValue;

	public class CodedValueFactory
	{
		public static const VITAL_SIGN_CODED_VALUE_TYPE:String = "http://codes.indivo.org/vitalsigns/";

		public static const BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE:String = "123";
		public static const BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_ABBREV:String = "BPsys";
		public static const BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_TEXT:String = "Blood Pressure Systolic";

		public static const BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE:String = "124";
		public static const BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_ABBREV:String = "BPdia";
		public static const BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_TEXT:String = "Blood Pressure Diastolic";

		public static const HEART_RATE_CODED_VALUE:String = "125";
		public static const HEART_RATE_CODED_VALUE_ABBREV:String = "HR";
		public static const HEART_RATE_CODED_VALUE_TEXT:String = "Heart Rate";

		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_TYPE:String = "http://codes.indivo.org/units/";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE:String = "31";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_ABBREV:String = "mmHg";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_TEXT:String = "millimeters of mercury";

		public static const BEATS_PER_MINUTE_CODED_VALUE_TYPE:String = "http://codes.indivo.org/units/";
		public static const BEATS_PER_MINUTE_CODED_VALUE:String = "32";
		public static const BEATS_PER_MINUTE_CODED_VALUE_ABBREV:String = "BPM";
		public static const BEATS_PER_MINUTE_CODED_VALUE_TEXT:String = "beats per minute";

		public static const AMBULATION_NUM_TIMES_CODED_VALUE:String = "33";
		public static const AMBULATION_NUM_TIMES_CODED_VALUE_ABBREV:String = "numAmbul";
		public static const AMBULATION_NUM_TIMES_CODED_VALUE_TEXT:String = "Number of Times out of Bed";

		public static const INTAKE_FLUID_CODED_VALUE:String = "34";
		public static const INTAKE_FLUID_CODED_VALUE_ABBREV:String = "amtFluid";
		public static const INTAKE_FLUID_CODED_VALUE_TEXT:String = "Fluid Intake";
		
		public static const INTAKE_FOOD_CODED_VALUE:String = "35";
		public static const INTAKE_FOOD_CODED_VALUE_ABBREV:String = "foodLevel";
		public static const INTAKE_FOOD_CODED_VALUE_TEXT:String = "Food Level";

		public static const BATHROOM_URINE1_CODED_VALUE:String = "36";
		public static const BATHROOM_URINE1_CODED_VALUE_ABBREV:String ="urine1";
		public static const BATHROOM_URINE1_CODED_VALUE_TEXT:String = "Urine Output 1";

		public static const BATHROOM_URINE2_CODED_VALUE:String = "37";
		public static const BATHROOM_URINE2_CODED_VALUE_ABBREV:String ="urine2";
		public static const BATHROOM_URINE2_CODED_VALUE_TEXT:String = "Urine Output 2";


		public function CodedValueFactory()
		{
		}

		public function createBathroomUrine1CodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BATHROOM_URINE1_CODED_VALUE, BATHROOM_URINE1_CODED_VALUE_ABBREV, BATHROOM_URINE1_CODED_VALUE_TEXT);
		}

		public function createBathroomUrine2CodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BATHROOM_URINE2_CODED_VALUE, BATHROOM_URINE2_CODED_VALUE_ABBREV, BATHROOM_URINE2_CODED_VALUE_TEXT);
		}

		public function createIntakeFluidCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, INTAKE_FLUID_CODED_VALUE, INTAKE_FLUID_CODED_VALUE_ABBREV, INTAKE_FLUID_CODED_VALUE_TEXT);
		}

		public function createIntakeFoodCodedValue():CodedValue{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, INTAKE_FOOD_CODED_VALUE, INTAKE_FOOD_CODED_VALUE_ABBREV, INTAKE_FOOD_CODED_VALUE_TEXT);
		}

		public function createNumberAmbulationsCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, AMBULATION_NUM_TIMES_CODED_VALUE, AMBULATION_NUM_TIMES_CODED_VALUE_ABBREV, AMBULATION_NUM_TIMES_CODED_VALUE_TEXT);
		}
		public function createBloodPressureSystolicCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_ABBREV, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_TEXT);
		}

		public function createBloodPressureDiastolicCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_ABBREV, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_TEXT);
		}

		public function createHeartRateCodedValue():CodedValue
		{
			return new CodedValue(VITAL_SIGN_CODED_VALUE_TYPE, HEART_RATE_CODED_VALUE, HEART_RATE_CODED_VALUE_ABBREV, HEART_RATE_CODED_VALUE_TEXT);
		}

		public function createMillimetersOfMercuryCodedValue():CodedValue
		{
			return new CodedValue(MILLIMETERS_OF_MERCURY_CODED_VALUE_TYPE, MILLIMETERS_OF_MERCURY_CODED_VALUE, MILLIMETERS_OF_MERCURY_CODED_VALUE_ABBREV, MILLIMETERS_OF_MERCURY_CODED_VALUE_TEXT);
		}

		public function createBeatsPerMinuteCodedValue():CodedValue
		{
			return new CodedValue(BEATS_PER_MINUTE_CODED_VALUE_TYPE, BEATS_PER_MINUTE_CODED_VALUE, BEATS_PER_MINUTE_CODED_VALUE_ABBREV, BEATS_PER_MINUTE_CODED_VALUE_TEXT);
		}
	}
}
