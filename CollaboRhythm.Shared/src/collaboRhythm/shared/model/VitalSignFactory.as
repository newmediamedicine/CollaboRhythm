package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.healthRecord.CollaboRhythmValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class VitalSignFactory
	{
		private var _codedValueFactory:CodedValueFactory;
		
		public function VitalSignFactory()
		{
			_codedValueFactory = new CodedValueFactory();
		}

		public function createBloodPressureSystolic(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBloodPressureSystolicCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new CollaboRhythmValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createBloodPressureDiastolic(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBloodPressureDiastolicCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new CollaboRhythmValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createHeartRate(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createHeartRateCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new CollaboRhythmValueAndUnit(resultValue, _codedValueFactory.createBeatsPerMinuteCodedValue()), site,  position, technique, comments);
		}

		public function createBloodGlucose(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBloodGlucoseCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new CollaboRhythmValueAndUnit(resultValue, _codedValueFactory.createMilligramsPerDeciliterCodedValue()), site,  position, technique, comments);
		}
	}
}
