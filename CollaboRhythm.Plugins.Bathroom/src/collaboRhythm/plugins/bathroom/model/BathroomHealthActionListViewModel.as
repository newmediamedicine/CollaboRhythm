package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionListViewModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class BathroomHealthActionListViewModel extends HealthActionListViewModelBase
		{
			public function BathroomHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
			{
				super(scheduleItemOccurrence, healthActionModelDetailsProvider)
			}
		}
	}
