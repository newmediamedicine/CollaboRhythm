package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.CodedValueFactory;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodPressureHealthActionListViewAdapter extends ForaD40bHealthActionListViewAdapterBase
	{
		public function BloodPressureHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		override public function get description():String
		{
			return "Blood Pressure Meter";
		}

		override public function get indication():String
		{
			return "Hypertension";
		}

		override public function get primaryInstructions():String
		{
			return "1 measurement from right arm";
		}

		override public function get secondaryInstructions():String
		{
			return "sit down and relax while taking measurement";
		}

		override public function get additionalAdherenceInformation():String
		{
			var additionalAdherenceInformation:String = "...";

			if (_scheduleItemOccurrence.adherenceItem)
			{
				var adherenceResults:Vector.<DocumentBase> = _scheduleItemOccurrence.adherenceItem.adherenceResults;
				if (adherenceResults.length != 0)
				{
					var bloodPressureSystolic:String = "";
					var bloodPressureDiastolic:String = "";
					for each (var vitalSign:VitalSign in adherenceResults)
					{
						if (vitalSign.name.value == CodedValueFactory.BLOOD_PRESSURE_SYSTOLIC_CODED_VALUE)
						{
							bloodPressureSystolic = vitalSign.result.value;
						}
						else if (vitalSign.name.value == CodedValueFactory.BLOOD_PRESSURE_DIASTOLIC_CODED_VALUE)
						{
							bloodPressureDiastolic = vitalSign.result.value;
						}
					}
					additionalAdherenceInformation = bloodPressureSystolic + "/" + bloodPressureDiastolic;
				}
			}

			return additionalAdherenceInformation;
		}
	}
}
