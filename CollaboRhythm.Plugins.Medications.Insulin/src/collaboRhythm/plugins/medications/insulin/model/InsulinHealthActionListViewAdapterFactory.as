package collaboRhythm.plugins.medications.insulin.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class InsulinHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function InsulinHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
																  adapters:ArrayCollection):void
		{
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			if (ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem) == MedicationScheduleItem)
			{
				var medicationScheduleItem:MedicationScheduleItem = scheduleItemOccurrence.scheduleItem as MedicationScheduleItem;
				if (medicationScheduleItem.name.value == "847241")
				{
					if (currentHealthActionListViewAdapter)
						currentHealthActionListViewAdapter.instructionalVideo = "Joslin_Insulin_Pen_demo.mp4"
				}
			}
			return currentHealthActionListViewAdapter;
		}
	}
}
