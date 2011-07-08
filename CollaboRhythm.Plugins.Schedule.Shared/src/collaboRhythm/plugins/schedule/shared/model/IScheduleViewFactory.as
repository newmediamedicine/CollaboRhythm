package collaboRhythm.plugins.schedule.shared.model
{

    import castle.flexbridge.reflection.ClassInfo;

    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;

    public interface IScheduleViewFactory
    {
        function get scheduleItemType():ClassInfo;
        function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemClockViewBase;
        function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemReportingViewBase;
        function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemTimelineViewBase;
    }
}
