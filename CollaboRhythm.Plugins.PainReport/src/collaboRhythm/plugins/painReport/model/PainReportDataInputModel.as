package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.schedule.shared.model.DataInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.MasterHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.net.URLVariables;

	public class PainReportDataInputModel extends DataInputModelBase
	{
		public function PainReportDataInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
												 urlVariables:URLVariables,
												 scheduleModel:IScheduleModel)
		{

		}
	}
}
