package collaboRhythm.plugins.schedule.shared.model
{
    import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

    import flash.net.URLVariables;

    public class DataInputModelBase
    {
        private var _scheduleItemOccurrence:ScheduleItemOccurrence;
        private var _urlVariables:URLVariables;

        public function DataInputModelBase(scheduleItemOccurrence:ScheduleItemOccurrence = null, urlVariables:URLVariables = null)
        {
            _scheduleItemOccurrence = scheduleItemOccurrence;
            this.urlVariables = urlVariables;
        }

        public function get scheduleItemOccurrence():ScheduleItemOccurrence
        {
            return _scheduleItemOccurrence;
        }

        public function get urlVariables():URLVariables
        {
            return _urlVariables;
        }

        public function set urlVariables(value:URLVariables):void
        {
            // abstract, subclasses should override
            _urlVariables = value;
        }
    }
}
