package collaboRhythm.plugins.bathroom.model
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.EquipmentScheduleItem;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class BathroomHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function BathroomHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   adapters:ArrayCollection):void
		{
			adapters.addItem(new BathroomHealthActionListViewAdapter(null,
					null));
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			if (ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem) == EquipmentScheduleItem &&
					(scheduleItemOccurrence.scheduleItem as EquipmentScheduleItem).scheduledEquipment.name == "Bathroom")
				return new BathroomHealthActionListViewAdapter(scheduleItemOccurrence, healthActionModelDetailsProvider);
			else
				return currentHealthActionListViewAdapter;


		}
	}
}
