package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class ScheduleItemOccurrenceReportingModelBase
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		protected var _scheduleModel:IScheduleModel;

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

		public function createAdherenceItem():void
		{
			// abstract; subclasses should override
		}

		public function voidAdherenceItem():void
		{
			_scheduleModel.voidAdherenceItem(_scheduleItemOccurrence);
		}

		public function isAdditionalInformationRequired():Boolean
		{
			// abstract; subclasses should override
			return false;
		}

        public function additionalInformationView():Class
        {
            // abstract; subclasses should override
            return null;
        }

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function set scheduleItemOccurrence(value:ScheduleItemOccurrence):void
        {
            _scheduleItemOccurrence = value;
        }
    }
}
