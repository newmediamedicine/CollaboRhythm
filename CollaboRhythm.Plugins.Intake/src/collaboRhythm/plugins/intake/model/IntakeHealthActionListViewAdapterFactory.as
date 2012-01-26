package collaboRhythm.plugins.intake.model
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapter;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionModelDetailsProvider;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	import mx.collections.ArrayCollection;

	public class IntakeHealthActionListViewAdapterFactory implements IHealthActionListViewAdapterFactory
	{
		public function IntakeHealthActionListViewAdapterFactory()
		{
		}

		public function createUnscheduledHealthActionViewAdapters(healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
														   adapters:ArrayCollection):void
		{
			adapters.addItem(new IntakeHealthActionListViewAdapter());
		}

		public function createScheduledHealthActionViewAdapter(scheduleItemOccurrence:ScheduleItemOccurrence,
															   healthActionModelDetailsProvider:IHealthActionModelDetailsProvider,
															   currentHealthActionListViewAdapter:IHealthActionListViewAdapter):IHealthActionListViewAdapter
		{
			return null;
		}
	}
}
