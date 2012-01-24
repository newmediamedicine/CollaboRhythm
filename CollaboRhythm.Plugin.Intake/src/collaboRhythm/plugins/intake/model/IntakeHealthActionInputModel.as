package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class IntakeHealthActionInputModel extends HealthActionInputModelBase
	{
		public function IntakeHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
													 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{

		}
	}
}
