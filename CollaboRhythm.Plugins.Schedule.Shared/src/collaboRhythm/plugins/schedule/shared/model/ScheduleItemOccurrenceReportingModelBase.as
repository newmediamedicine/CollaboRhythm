package collaboRhythm.plugins.schedule.shared.model
{

	import collaboRhythm.plugins.schedule.shared.controller.DataInputControllerBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class ScheduleItemOccurrenceReportingModelBase
	{
		private var _scheduleItemOccurrence:ScheduleItemOccurrence;
		private var _scheduleModel:IScheduleModel;
        private var _dataInputController:DataInputControllerBase;

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

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function set scheduleItemOccurrence(value:ScheduleItemOccurrence):void
        {
            _scheduleItemOccurrence = value;
        }

		public function get scheduleModel():IScheduleModel
		{
			return _scheduleModel;
		}

		public function set scheduleModel(value:IScheduleModel):void
		{
			_scheduleModel = value;
		}

		public function get dataInputController():DataInputControllerBase
		{
			return _dataInputController;
		}

		public function set dataInputController(value:DataInputControllerBase):void
		{
			_dataInputController = value;
		}
	}
}
