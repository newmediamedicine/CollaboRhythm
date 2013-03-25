package collaboRhythm.plugins.schedule.shared.controller
{
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputModel;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class HealthActionInputControllerBase
	{
		public static const BATCH_TRANSFER_URL_VARIABLE:String = "batchTransfer";
		public static const BATCH_TRANSFER_ACTION_END:String = "end";
		public static const BATCH_TRANSFER_ACTION_BEGIN:String = "begin";
		protected var _synchronizationService:SynchronizationService;

		public function HealthActionInputControllerBase()
		{
		}

		public function handleAdherenceChange(dataInputModel:IHealthActionInputModel,
									   scheduleItemOccurrence:ScheduleItemOccurrence, selected:Boolean):void
		{
		}

		public function get isReview():Boolean
		{
			return false;
		}

		public function removeEventListener():void
		{
			destroy();
		}

		public function destroy():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
				_synchronizationService = null;
			}
		}

		public function clearInputData():void
		{

		}
	}
}
