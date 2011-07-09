package collaboRhythm.plugins.schedule.controller
{

    import collaboRhythm.plugins.schedule.model.ScheduleGroup;
    import collaboRhythm.plugins.schedule.model.ScheduleModel;
    import collaboRhythm.plugins.schedule.model.ScheduleReportingModel;
    import collaboRhythm.plugins.schedule.view.ScheduleReportingFullView;
    import collaboRhythm.shared.controller.apps.AppEvent;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;
	import collaboRhythm.shared.model.healthRecord.document.AdherenceItem;

	import flash.events.EventDispatcher;

    import mx.binding.utils.BindingUtils;
    import mx.core.UIComponent;

    public class ScheduleReportingController extends EventDispatcher
    {
        private var _scheduleModel:ScheduleModel;
        private var _scheduleReportingFullView:ScheduleReportingFullView;
        private var _scheduleReportingModel:ScheduleReportingModel;

        public function ScheduleReportingController(scheduleModel:ScheduleModel,
                                                    scheduleReportingFullView:ScheduleReportingFullView,
                                                    scheduleReportingModel:ScheduleReportingModel)
        {
            _scheduleModel = scheduleModel;
            _scheduleReportingFullView = scheduleReportingFullView;
            _scheduleReportingModel = scheduleReportingModel;
            _scheduleReportingModel.isReportingCompleted = false;

            BindingUtils.bindSetter(reportingCompletedHandler, _scheduleReportingModel, "isReportingCompleted");
        }

        private function reportingCompletedHandler(isReportingCompleted:Boolean):void
        {
            if (isReportingCompleted)
            {
                dispatchEvent(new AppEvent(AppEvent.HIDE_FULL_VIEW));
            }
        }

        public function goBack():void
        {
            _scheduleReportingModel.viewStack.removeItemAt(_scheduleReportingModel.viewStack.length - 1)
        }

        public function createAdherenceItem(scheduleGroup:ScheduleGroup, scheduleItemOccurrence:ScheduleItemOccurrence,
                                            adherenceItem:AdherenceItem):void
        {
            _scheduleReportingModel.createAdherenceItem(scheduleGroup, scheduleItemOccurrence, adherenceItem);
        }

        public function showAdditionalInformationView(additionalInformationView:UIComponent):void
        {
            _scheduleReportingModel.showAdditionalInformationView(additionalInformationView);
        }
    }
}
