package collaboRhythm.plugins.bloodPressure.model.titration
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionPlan;
	import collaboRhythm.shared.model.healthRecord.document.HealthActionSchedule;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import flash.filesystem.File;

	import mx.collections.ArrayCollection;

	public class HypertensionMedicationTitrationSupportHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function HypertensionMedicationTitrationSupportHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																  adapters:ArrayCollection):void
		{
			adapters.addItem(new HypertensionMedicationTitrationSupportHealthActionListViewAdapter(null, healthActionModelDetailsProvider));
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			var healthActionSchedule:HealthActionSchedule = scheduleItemOccurrence.scheduleItem as HealthActionSchedule;
			if (healthActionSchedule && healthActionSchedule.scheduledHealthAction is HealthActionPlan
					&& healthActionModelDetailsProvider.record)
			{
				var healthActionPlan:HealthActionPlan = (healthActionSchedule.scheduledHealthAction as HealthActionPlan);
				if (healthActionPlan.name.text == PersistableHypertensionMedicationTitrationModel.HYPERTENSION_MEDICATION_TITRATION_DECISION_PLAN_NAME)
				{
					return new HypertensionMedicationTitrationSupportHealthActionListViewAdapter(scheduleItemOccurrence,
							healthActionModelDetailsProvider);
				}
			}

			return currentHealthActionListViewAdapter;
		}
	}
}
