package collaboRhythm.plugins.schedule.shared.model
{

    import castle.flexbridge.reflection.ClassInfo;

    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.ScheduleItemBase;

    public interface IScheduleViewFactory
    {
        function get scheduleItemType():ClassInfo;
        function createScheduleItemClockView(scheduleItem:ScheduleItemBase):ScheduleItemClockViewBase;
        function createScheduleItemReportingView(scheduleItem:ScheduleItemBase):ScheduleItemReportingViewBase;
        function createScheduleItemTimelineView(scheduleItem:ScheduleItemBase):ScheduleItemTimelineViewBase;
    }
}
