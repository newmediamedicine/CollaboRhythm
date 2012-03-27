package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionListViewModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class InsulinTitrationSupportHealthActionListViewModel extends HealthActionListViewModelBase
	{
		public function InsulinTitrationSupportHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																		 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider)
		}
	}
}
