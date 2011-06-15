package collaboRhythm.plugins.schedule.shared.model
{

    import castle.flexbridge.reflection.ClassInfo;

    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;

    import spark.components.Group;

    public interface IScheduleViewFactory
    {
        function get scheduleItemType():ClassInfo;
        function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence, parentGroup:Group):ScheduleItemClockViewBase;
        function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence, parentGroup:Group):ScheduleItemReportingViewBase;
        function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence, parentGroup:Group):ScheduleItemTimelineViewBase;
    }
}
