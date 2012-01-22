package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class PainReportHealthActionInputModel extends HealthActionInputModelBase
	{
		public function PainReportHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{

		}
	}
}
