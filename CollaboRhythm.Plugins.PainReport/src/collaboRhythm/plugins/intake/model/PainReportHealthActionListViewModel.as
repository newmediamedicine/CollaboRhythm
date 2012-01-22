package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class PainReportHealthActionListViewModel extends ScheduleItemOccurrenceReportingModelBase
	{
		public function PainReportHealthActionListViewModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																		 scheduleModel:IScheduleModel)
		{
			super(scheduleItemOccurrence, scheduleModel)
		}
	}
}
