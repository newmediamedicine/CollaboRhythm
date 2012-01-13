package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.shared.model.healthRecord.ValueAndUnit;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class HeartRate extends VitalSign
	{
		public function HeartRate(dateMeasuredStart:Date, value:String, dateMeasuredEnd:Date = null,
								  position:String = "", site:String = "")
		{
			this.name = new HeartRateCodedValue();
			this.dateMeasuredStart = dateMeasuredStart;
			this.result = new ValueAndUnit(value, new BeatsPerMinuteCodedValue());
			this.position = position;
			this.site = site;
		}
	}
}
