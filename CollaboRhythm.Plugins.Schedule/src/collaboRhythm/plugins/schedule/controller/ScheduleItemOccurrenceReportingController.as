package collaboRhythm.plugins.schedule.controller
{
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;

	public class ScheduleItemOccurrenceReportingController
	{
		private var _scheduleItemOccurrenceReportingModel:ScheduleItemOccurrenceReportingModelBase;

		public function ScheduleItemOccurrenceReportingController(scheduleItemOccurrenceReportingModel:ScheduleItemOccurrenceReportingModelBase)
		{
			_scheduleItemOccurrenceReportingModel = scheduleItemOccurrenceReportingModel;
		}

		public function reportAdherence():void
		{
			_scheduleItemOccurrenceReportingModel.reportAdherence();
		}
	}
}
