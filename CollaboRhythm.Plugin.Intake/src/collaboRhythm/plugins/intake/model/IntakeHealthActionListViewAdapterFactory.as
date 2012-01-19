package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class IntakeHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function IntakeHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(record:Record, adapters:ArrayCollection):void
		{
			adapters.addItem(new IntakeHealthActionListViewAdapter());
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   scheduleModel:IScheduleModel,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			return null;
		}
	}
}
