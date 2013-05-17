package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmCodedValue;

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

		public static const VIRAL_LOAD_CODED_VALUE:String = "127";
		public static const VIRAL_LOAD_CODED_VALUE_ABBREV:String = "VL";
		public static const VIRAL_LOAD_CODED_VALUE_TEXT:String = "Viral Load";

		public static const TCELL_COUNT_CODED_VALUE:String = "128";
		public static const TCELL_COUNT_CODED_VALUE_ABBREV:String = "CD4";
		public static const TCELL_COUNT_CODED_VALUE_TEXT:String = "TCell Count";

		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE:String = "31";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_ABBREV:String = "mmHg";
		public static const MILLIMETERS_OF_MERCURY_CODED_VALUE_TEXT:String = "millimeters of mercury";

		public static const BEATS_PER_MINUTE_CODED_VALUE:String = "32";
		public static const BEATS_PER_MINUTE_CODED_VALUE_ABBREV:String = "BPM";
		public static const BEATS_PER_MINUTE_CODED_VALUE_TEXT:String = "beats per minute";

		public static const MILLIGRAMS_PER_DECILITER_CODED_VALUE:String = "33";
		public static const MILLIGRAMS_PER_DECILITER_CODED_VALUE_ABBREV:String = "mg/dL";
		public static const MILLIGRAMS_PER_DECILITER_CODED_VALUE_TEXT:String = "milligrams per deciliter";

		public static const UNIT_CODED_VALUE:String = "Unit";
		public static const UNIT_CODED_VALUE_ABBREV:String = "U";
		public static const UNIT_CODED_VALUE_TEXT:String = "Unit";

		public static const PREFILLED_SYRINGE_CODED_VALUE:String = "prefilled syringe";
		public static const PREFILLED_SYRINGE_CODED_VALUE_ABBREV:String = "prefilled syringe";
		public static const PREFILLED_SYRINGE_CODED_VALUE_TEXT:String = "prefilled syringe";

		public static const COPIES_PER_MILLILITER_CODED_VALUE:String = "copies per milliliter";
		public static const COPIES_PER_MILLILITER_CODED_VALUE_ABBREV:String = "copies/mL";
		public static const COPIES_PER_MILLILITER_CODED_VALUE_TEXT:String = "copies per milliliter";

		public static const CELLS_PER_MILLILITER_CODED_VALUE:String = "cells per milliliter";
		public static const CELLS_PER_MILLILITER_CODED_VALUE_ABBREV:String = "cells/mL";
		public static const CELLS_PER_MILLILITER_CODED_VALUE_TEXT:String = "cells per milliliter";

		public function CodedValueFactory()
		{
		}

		public function createBloodPressureSystolicCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE,
					BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_ABBREV, BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE_TEXT);
		}

		public function createBloodPressureDiastolicCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE,
					BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_ABBREV, BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE_TEXT);
		}

		public function createHeartRateCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(VITAL_SIGN_CODED_VALUE_TYPE, HEART_RATE_CODED_VALUE,
					HEART_RATE_CODED_VALUE_ABBREV,
					HEART_RATE_CODED_VALUE_TEXT);
		}

		public function createBloodGlucoseCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(VITAL_SIGN_CODED_VALUE_TYPE, BLOOD_GLUCOSE_CODED_VALUE,
					BLOOD_GLUCOSE_CODED_VALUE_ABBREV, BLOOD_GLUCOSE_CODED_VALUE_TEXT);
		}

		public function createViralLoadCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(VITAL_SIGN_CODED_VALUE_TYPE, VIRAL_LOAD_CODED_VALUE,
					VIRAL_LOAD_CODED_VALUE_ABBREV, VIRAL_LOAD_CODED_VALUE_TEXT);
		}

		public function createTCellCountCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(VITAL_SIGN_CODED_VALUE_TYPE, TCELL_COUNT_CODED_VALUE,
					TCELL_COUNT_CODED_VALUE_ABBREV, TCELL_COUNT_CODED_VALUE_TEXT);
		}

		public function createMillimetersOfMercuryCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, MILLIMETERS_OF_MERCURY_CODED_VALUE,
					MILLIMETERS_OF_MERCURY_CODED_VALUE_ABBREV, MILLIMETERS_OF_MERCURY_CODED_VALUE_TEXT);
		}

		public function createBeatsPerMinuteCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, BEATS_PER_MINUTE_CODED_VALUE,
					BEATS_PER_MINUTE_CODED_VALUE_ABBREV, BEATS_PER_MINUTE_CODED_VALUE_TEXT);
		}

		public function createMilligramsPerDeciliterCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, MILLIGRAMS_PER_DECILITER_CODED_VALUE,
					MILLIGRAMS_PER_DECILITER_CODED_VALUE_ABBREV, MILLIGRAMS_PER_DECILITER_CODED_VALUE_TEXT);
		}

		public function createDoseUnitCodedValue(form:String):CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, form, form, form);
		}

		public function createUnitCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, UNIT_CODED_VALUE, UNIT_CODED_VALUE_ABBREV,
					UNIT_CODED_VALUE_TEXT);
		}

		public function createPrefilledSyringeCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, PREFILLED_SYRINGE_CODED_VALUE,
					PREFILLED_SYRINGE_CODED_VALUE_ABBREV, PREFILLED_SYRINGE_CODED_VALUE_TEXT);
		}

		public function createCopiesPerMilliliterCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, COPIES_PER_MILLILITER_CODED_VALUE,
					COPIES_PER_MILLILITER_CODED_VALUE_ABBREV, COPIES_PER_MILLILITER_CODED_VALUE_TEXT);
		}

		public function createCellsPerMilliliterCodedValue():CollaboRhythmCodedValue
		{
			return new CollaboRhythmCodedValue(UNITS_CODED_VALUE_TYPE, CELLS_PER_MILLILITER_CODED_VALUE,
					CELLS_PER_MILLILITER_CODED_VALUE_ABBREV, CELLS_PER_MILLILITER_CODED_VALUE_TEXT);
		}
	}
}
