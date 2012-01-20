package collaboRhythm.plugins.bathroom.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class BathroomHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function BathroomHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(record:Record, adapters:ArrayCollection):void
		{
			adapters.addItem(new BathroomHealthActionListViewAdapter());
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   scheduleModel:IScheduleModel,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			return null;
		}
	}
}
