package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class BathroomHealthActionListViewModel extends ScheduleItemOccurrenceReportingModelBase
	{
		public function BathroomHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																		 scheduleModel:IScheduleModel)
		{
			super(scheduleItemOccurrence, scheduleModel)
		}
	}
}
