package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionListViewModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class HypertensionMedicationTitrationSupportHealthActionListViewModel extends HealthActionListViewModelBase
	{
		public function HypertensionMedicationTitrationSupportHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																		 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider)
		}
	}
}
