package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodPressureSystolic extends VitalSign
	{
		public function BloodPressureSystolic(dateMeasuredStart:Date, value:String, dateMeasuredEnd:Date = null, position:String = "", site:String = "")
		{
			this.name = new BloodPressureSystolicCodedValue();
			this.dateMeasuredStart = dateMeasuredStart;
			this.result = new ValueAndUnit(value, new MillimetersOfMercuryCodedValue());
			this.position = position;
			this.site = site;
		}
	}
}
