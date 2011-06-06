package collaboRhythm.plugins.medications.model
{

    import castle.flexbridge.reflection.ClassInfo;
    import castle.flexbridge.reflection.ReflectionUtils;

    import collaboRhythm.plugins.medications.view.MedicationScheduleItemClockView;
    import collaboRhythm.plugins.medications.view.MedicationScheduleItemReportingView;
    import collaboRhythm.plugins.medications.view.MedicationScheduleItemTimelineView;
    import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.MedicationScheduleItem;
    import collaboRhythm.shared.model.ScheduleItemBase;

    public class MedicationsScheduleViewFactory implements IScheduleViewFactory
    {
        public function MedicationsScheduleViewFactory()
        {
        }

        public function get scheduleItemType():ClassInfo
        {
            return ReflectionUtils.getClassInfo(MedicationScheduleItem);
        }

        public function createScheduleItemClockView(scheduleItem:ScheduleItemBase):ScheduleItemClockViewBase
        {
            return new MedicationScheduleItemClockView();
        }

        public function createScheduleItemReportingView(scheduleItem:ScheduleItemBase):ScheduleItemReportingViewBase
        {
            return new MedicationScheduleItemReportingView();
        }

        public function createScheduleItemTimelineView(scheduleItem:ScheduleItemBase):ScheduleItemTimelineViewBase
        {
            var medicationScheduleItemTimelineView:MedicationScheduleItemTimelineView = new MedicationScheduleItemTimelineView();
            medicationScheduleItemTimelineView.init(scheduleItem);
            return medicationScheduleItemTimelineView;
        }
    }
}
