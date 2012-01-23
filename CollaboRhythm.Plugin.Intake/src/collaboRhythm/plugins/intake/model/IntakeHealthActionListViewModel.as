package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionListViewModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class IntakeHealthActionListViewModel extends HealthActionListViewModelBase
	{
		public function IntakeHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																		 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider)
		}
	}
}
