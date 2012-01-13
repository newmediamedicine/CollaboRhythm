package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodPressureDiastolic extends VitalSign
	{
		public function BloodPressureDiastolic(dateMeasuredStart:Date, value:String, dateMeasuredEnd:Date = null,
											   position:String = "", site:String = "")
		{
			this.name = new BloodPressureDiastolicCodedValue();
			this.dateMeasuredStart = dateMeasuredStart;
			this.result = new ValueAndUnit(value, new MillimetersOfMercuryCodedValue());
			this.position = position;
			this.site = site;
		}
	}
}