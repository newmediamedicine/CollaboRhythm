package collaboRhythm.plugins.schedule.shared.model
{
    import collaboRhythm.shared.model.healthRecord.document.ScheduleItemBase;
    import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

    import flash.net.URLVariables;

    public class DataInputViewInitializationModel
    {
        private var _scheduleItemOccurrence:ScheduleItemOccurrence;
        private var _urlVariables:URLVariables;

        public function DataInputViewInitializationModel(scheduleItemOccurrence:ScheduleItemOccurrence = null, urlVariables:URLVariables = null)
        {
            _scheduleItemOccurrence = scheduleItemOccurrence;
            _urlVariables = urlVariables;
        }

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function get urlVariables():URLVariables
        {
            return _urlVariables;
        }
    }
}
