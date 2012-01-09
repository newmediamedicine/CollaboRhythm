package collaboRhythm.plugins.schedule.controller
{
    import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;

    import spark.components.ViewNavigator;
    import spark.transitions.SlideViewTransition;

    public class ScheduleItemOccurrenceReportingController
    {
        private var _scheduleItemOccurrenceReportingModel:ScheduleItemOccurrenceReportingModelBase;
        private var _viewNavigator:ViewNavigator;

        public function ScheduleItemOccurrenceReportingController(scheduleItemOccurrenceReportingModel:ScheduleItemOccurrenceReportingModelBase, viewNavigator:ViewNavigator)
        {
            _scheduleItemOccurrenceReportingModel = scheduleItemOccurrenceReportingModel;
            _viewNavigator = viewNavigator;
        }

        public function reportAdherence():void
        {
            if (_scheduleItemOccurrenceReportingModel.scheduleItemOccurrence.adherenceItem)
            {
                _scheduleItemOccurrenceReportingModel.voidAdherenceItem();
            }
            else
            {
                if (_scheduleItemOccurrenceReportingModel.isAdditionalInformationRequired())
                {
                    _viewNavigator.pushView(_scheduleItemOccurrenceReportingModel.additionalInformationView(), null, null, new SlideViewTransition())
                }
                else
                {
                    _scheduleItemOccurrenceReportingModel.reportAdherence();
                }
            }
        }
    }
}
