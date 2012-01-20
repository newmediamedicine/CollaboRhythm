package collaboRhythm.plugins.model
{
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class MedsHealthActionListViewModel extends ScheduleItemOccurrenceReportingModelBase
	{
		public function MedsHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																		 scheduleModel:IScheduleModel)
		{
			super(scheduleItemOccurrence, scheduleModel)
		}
	}
}
