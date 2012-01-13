package collaboRhythm.plugins.schedule.controller
{
    import collaboRhythm.plugins.schedule.shared.model.DataInputViewInitializationModel;
    import collaboRhythm.plugins.schedule.shared.model.ScheduleItemOccurrenceReportingModelBase;
	import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

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

        public function reportAdherence(scheduleItemOccurrence:ScheduleItemOccurrence):void
        {
            if (_scheduleItemOccurrenceReportingModel.scheduleItemOccurrence.adherenceItem)
            {
                _scheduleItemOccurrenceReportingModel.voidAdherenceItem();
            }
            else
            {
                if (_scheduleItemOccurrenceReportingModel.isAdditionalInformationRequired())
                {
                    var dataInputViewInitializationModel:DataInputViewInitializationModel = new DataInputViewInitializationModel(scheduleItemOccurrence,
							null, _scheduleItemOccurrenceReportingModel.scheduleModel, _viewNavigator);
                    _viewNavigator.pushView(_scheduleItemOccurrenceReportingModel.dataInputView, dataInputViewInitializationModel, null, new SlideViewTransition());
                }
                else
                {
                    _scheduleItemOccurrenceReportingModel.reportAdherence();
                }
            }
        }
    }
}
