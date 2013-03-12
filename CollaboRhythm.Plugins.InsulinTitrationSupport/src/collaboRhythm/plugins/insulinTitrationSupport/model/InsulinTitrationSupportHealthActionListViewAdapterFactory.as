package collaboRhythm.plugins.insulinTitrationSupport.model
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

	public class InsulinTitrationSupportHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function InsulinTitrationSupportHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																  adapters:ArrayCollection):void
		{
			adapters.addItem(new InsulinTitrationSupportHealthActionListViewAdapter(null, healthActionModelDetailsProvider));
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
				if (healthActionPlan.name.text == TitratingInsulinHealthActionListViewAdapter.INSULIN_TITRATION_DECISION_HEALTH_ACTION_SCHEDULE_NAME)
				{
					return new InsulinTitrationSupportHealthActionListViewAdapter(scheduleItemOccurrence, healthActionModelDetailsProvider);
				}
			}

			var medicationScheduleItem:MedicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
			if (medicationScheduleItem)
			{
				if (InsulinTitrationSupportChartModifier.INSULIN_MEDICATION_CODES.indexOf(medicationScheduleItem.name.value) != -1)
				{
					return new TitratingInsulinHealthActionListViewAdapter(scheduleItemOccurrence, healthActionModelDetailsProvider, currentHealthActionListViewAdapter);
				}
			}
			return currentHealthActionListViewAdapter;
		}
	}
}
