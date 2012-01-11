package collaboRhythm.plugins.equipment.model
{

    import collaboRhythm.plugins.schedule.shared.model.IScheduleModel;
	import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class EquipmentScheduleItemOccurrenceReportingModel extends ScheduleItemOccurrenceReportingModelBase
	{
		public function EquipmentScheduleItemOccurrenceReportingModel(scheduleItemOccurrence:ScheduleItemOccurrence,
																	  scheduleModel:IScheduleModel)
		{
			super(scheduleItemOccurrence, scheduleModel);
		}

		override public function createAdherenceItem():void
		{
			// abstract; subclasses should override
		}

		override public function isAdditionalInformationRequired():Boolean
		{
			return true;
		}

        override public function additionalInformationView():Class
        {
            return null;
        }
	}
}
