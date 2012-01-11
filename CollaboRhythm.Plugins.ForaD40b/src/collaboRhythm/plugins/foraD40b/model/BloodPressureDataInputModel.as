package collaboRhythm.plugins.foraD40b.model
{
    import collaboRhythm.plugins.schedule.shared.model.DataInputModelBase;
    import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

    import flash.net.URLVariables;

    [Bindable]
    public class BloodPressureDataInputModel extends DataInputModelBase
    {
        private var _systolic:int;
        private var _diastolic:int;
        private var _heartRate:int;

        public function BloodPressureDataInputModel(scheduleItemOccurrence:ScheduleItemOccurrence = null, urlVariables:URLVariables = null)
        {
            super(scheduleItemOccurrence, urlVariables);
        }

        override public function set urlVariables(value:URLVariables):void
        {
            systolic = value.systolic;
            diastolic = value.diastolic;
            heartRate = value.heartrate;
        }

        public function get systolic():int
        {
            return _systolic;
        }

        public function set systolic(value:int):void
        {
            _systolic = value;
        }

        public function get diastolic():int
        {
            return _diastolic;
        }

        public function set diastolic(value:int):void
        {
            _diastolic = value;
        }

        public function get heartRate():int
        {
            return _heartRate;
        }

        public function set heartRate(value:int):void
        {
            _heartRate = value;
        }
    }
}
