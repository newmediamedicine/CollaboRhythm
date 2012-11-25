package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class HealthActionInputControllerBase
	{
		public static const BATCH_TRANSFER_URL_VARIABLE:String = "batchTransfer";
		public static const BATCH_TRANSFER_ACTION_END:String = "end";
		public static const BATCH_TRANSFER_ACTION_BEGIN:String = "begin";

		public function HealthActionInputControllerBase()
		{
		}

		public function handleAdherenceChange(dataInputModel:IHealthActionInputModel,
									   scheduleItemOccurrence:ScheduleItemOccurrence, selected:Boolean):void
		{
		}
	}
}
