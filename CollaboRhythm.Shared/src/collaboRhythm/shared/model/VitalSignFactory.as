package collaboRhythm.shared.model
{
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class VitalSignFactory
	{
		private var _codedValueFactory:CodedValueFactory;

		public function VitalSignFactory()
		{
			_codedValueFactory = new CodedValueFactory();
		}

		public function createBathroomUrine1(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBathroomUrine1CodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createBathroomUrine2(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBathroomUrine2CodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createIntakeFluid(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createIntakeFluidCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createIntakeFood(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createIntakeFoodCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createBloodPressureSystolic(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBloodPressureSystolicCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createBloodPressureDiastolic(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createBloodPressureDiastolicCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}

		public function createHeartRate(dateMeasuredStart:Date, resultValue:String, measuredBy:String = null, dateMeasuredEnd:Date = null, site:String = null, position:String = null, technique:String = null, comments:String = null):VitalSign
		{
			return new VitalSign(_codedValueFactory.createHeartRateCodedValue(), measuredBy, dateMeasuredStart, dateMeasuredEnd, new ValueAndUnit(resultValue, _codedValueFactory.createMillimetersOfMercuryCodedValue()), site,  position, technique, comments);
		}
	}
}
