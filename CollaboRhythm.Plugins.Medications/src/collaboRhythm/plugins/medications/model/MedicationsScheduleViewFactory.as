package collaboRhythm.plugins.medications.model
{

	import castle.flexbridge.reflection.ClassInfo;
	import castle.flexbridge.reflection.ReflectionUtils;

    import collaboRhythm.plugins.medications.view.MedicationScheduleItemClockView;
    import collaboRhythm.plugins.medications.view.MedicationScheduleItemReportingView;
    import collaboRhythm.plugins.medications.view.MedicationScheduleItemTimelineView;
    import collaboRhythm.plugins.schedule.shared.model.IScheduleReportingModel;
	import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.healthRecord.document.MedicationScheduleItem;
    import collaboRhythm.shared.model.healthRecord.document.ScheduleItemOccurrence;

	public class MedicationsScheduleViewFactory implements IScheduleViewFactory
    {
        public function MedicationsScheduleViewFactory()
        {
        }

        public function get scheduleItemType():ClassInfo
        {
            return ReflectionUtils.getClassInfo(MedicationScheduleItem);
        }

        public function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemClockViewBase
        {
            var medicationScheduleItemClockView:MedicationScheduleItemClockView =  new MedicationScheduleItemClockView();
            medicationScheduleItemClockView.init(scheduleItemOccurrence);
            return medicationScheduleItemClockView;
        }

        public function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence,
														scheduleReportingModel:IScheduleReportingModel,
														activeAccountId:String):ScheduleItemReportingViewBase
        {
            var medicationScheduleItemReportingView:MedicationScheduleItemReportingView = new MedicationScheduleItemReportingView();
            medicationScheduleItemReportingView.init(scheduleItemOccurrence, scheduleReportingModel, activeAccountId);
            return medicationScheduleItemReportingView;
        }

        public function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemTimelineViewBase
        {
            var medicationScheduleItemTimelineView:MedicationScheduleItemTimelineView = new MedicationScheduleItemTimelineView();
            medicationScheduleItemTimelineView.init(scheduleItemOccurrence);
            return medicationScheduleItemTimelineView;
        }
    }
}
