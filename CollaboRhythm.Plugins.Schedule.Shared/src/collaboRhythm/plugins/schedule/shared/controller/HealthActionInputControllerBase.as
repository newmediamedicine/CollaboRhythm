package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class HealthActionInputControllerBase
	{
		public function HealthActionInputControllerBase()
		{
		}

		public function handleAdherenceChange(dataInputModel:IHealthActionInputModel,
									   scheduleItemOccurrence:ScheduleItemOccurrence, selected:Boolean):void
		{
		}
	}
}
