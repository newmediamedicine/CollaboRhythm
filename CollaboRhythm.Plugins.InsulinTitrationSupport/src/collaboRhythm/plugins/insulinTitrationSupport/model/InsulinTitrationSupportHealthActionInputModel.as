package collaboRhythm.plugins.insulinTitrationSupport.model
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class InsulinTitrationSupportHealthActionInputModel extends HealthActionInputModelBase
	{
		public function InsulinTitrationSupportHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null,
																	  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
		}

		public function prepareChartsForDecision():void
		{
			//TODO: I have not been able to reproduce it, but the record was null once
			healthActionModelDetailsProvider.record.healthChartsModel.prepareForDecision("Health Charts - Insulin Titration", scheduleItemOccurrence);
		}

		public function showCharts():void
		{
			healthActionModelDetailsProvider.navigationProxy.showFullView("Health Charts");
		}
	}
}
