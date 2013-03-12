package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.schedule.shared.model.HealthActionInputModelBase;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class HypertensionMedicationTitrationSupportHealthActionInputModel extends HealthActionInputModelBase
	{
		private var _decisionScheduleItemOccurrence:ScheduleItemOccurrence;

		public function HypertensionMedicationTitrationSupportHealthActionInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null, decisionScheduleItemOccurrence:ScheduleItemOccurrence = null,
																	  healthActionModelDetailsProvider:IHealthActionModelDetailsProvider = null)
		{
			super(scheduleItemOccurrence, healthActionModelDetailsProvider);
			_decisionScheduleItemOccurrence = decisionScheduleItemOccurrence;
		}

		public function prepareChartsForDecision():Boolean
		{
			if (healthActionModelDetailsProvider.record && healthActionModelDetailsProvider.record.healthChartsModel)
			{
				healthActionModelDetailsProvider.record.healthChartsModel.prepareForDecision("Health Charts - Medication Adjustment Plan (MAP)",
						decisionScheduleItemOccurrence);
				return true;
			}
			_logger.warn("Failed to prepare charts for decision. healthActionModelDetailsProvider.record = " + healthActionModelDetailsProvider.record);
			return false;
		}

		public function showCharts():void
		{
			healthActionModelDetailsProvider.navigationProxy.showFullView("Health Charts");
		}

		public function get decisionScheduleItemOccurrence():ScheduleItemOccurrence
		{
			return _decisionScheduleItemOccurrence;
		}
	}
}
