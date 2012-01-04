package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class ScheduleItemOccurrenceReportingModelBase
	{
		protected var _scheduleItemOccurrence:ScheduleItemOccurrence;
		protected var _scheduleModel:IScheduleModel;
		private var _additionalInformation:Boolean = false;

		public function ScheduleItemOccurrenceReportingModelBase(scheduleItemOccurrence:ScheduleItemOccurrence,
																 scheduleModel:IScheduleModel)
		{
			_scheduleItemOccurrence = scheduleItemOccurrence;
			_scheduleModel = scheduleModel;
		}

		public function reportAdherence():void
		{
			if (_scheduleItemOccurrence.adherenceItem)
			{
				voidAdherenceItem();
			}
			else
			{
				createAdherenceItem();
			}
		}

		protected function createAdherenceItem():void
		{
			// abstract; subclasses should override
		}

		private function voidAdherenceItem():void
		{
			_scheduleModel.voidAdherenceItem(_scheduleItemOccurrence);
		}

		public function isAdditionalInformationRequired():Boolean
		{
			// abstract; subclasses should override
			return false;
		}
	}
}
