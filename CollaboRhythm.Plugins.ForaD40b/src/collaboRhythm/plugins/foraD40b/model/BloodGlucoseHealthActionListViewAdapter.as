package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.DocumentBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.VitalSign;

	public class BloodGlucoseHealthActionListViewAdapter extends ForaD40bHealthActionListViewAdapterBase
	{
		public function BloodGlucoseHealthActionListViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		override public function get description():String
		{
			return "Blood Glucose Meter";
		}

		override public function get indication():String
		{
			return "Diabetes";
		}

		override public function get primaryInstructions():String
		{
			return "1 measurement from fingerstick";
		}

		override public function get secondaryInstructions():String
		{
			return "take measurement before eating";
		}

		override public function get additionalAdherenceInformation():String
		{
			var additionalAdherenceInformation:String = "...";

			if (_scheduleItemOccurrence.adherenceItem)
			{
				var adherenceResults:Vector.<DocumentBase> = _scheduleItemOccurrence.adherenceItem.adherenceResults;
				if (adherenceResults.length != 0)
				{
					var vitalSign:VitalSign = adherenceResults[0] as VitalSign;
					additionalAdherenceInformation = vitalSign.result.value;
				}
			}

			return additionalAdherenceInformation;
		}
	}
}
