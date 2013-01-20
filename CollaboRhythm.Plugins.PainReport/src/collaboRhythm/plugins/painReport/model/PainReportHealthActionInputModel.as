package collaboRhythm.plugins.painReport.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class PainReportHealthActionInputModel extends HealthActionInputModelBase implements IHealthActionInputModel
	{
		public function PainReportHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence,
														 healthActionModelDetailsProvider:IHealthActionModelDetailsProvider)
		{

		}

		public function get adherenceResultDate():Date
		{
			return null;
		}

		public function get dateMeasuredStart():Date
		{
			return null;
		}

		public function get isChangeTimeAllowed():Boolean
		{
			return true;
		}
	}
}
