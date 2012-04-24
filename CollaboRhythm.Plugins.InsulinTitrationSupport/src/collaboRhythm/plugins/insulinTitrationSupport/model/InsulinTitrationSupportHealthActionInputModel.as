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

		public function showCharts():void
		{
			_healthActionModelDetailsProvider.record.healthChartsModel.prepareForDecision();
			_healthActionModelDetailsProvider.navigationProxy.showFullView("Health Charts");
		}
	}
}
