package collaboRhythm.plugins.foraD40b.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class BloodGlucoseHealthActionInputModel extends HealthActionInputModelBase
    {
        public function BloodGlucoseHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
        													healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
        {
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
        }
    }
}
