package collaboRhythm.plugins.equipment.model
{

    import castle.flexbridge.reflection.ClassInfo;
    import castle.flexbridge.reflection.ReflectionUtils;

    import collaboRhythm.plugins.equipment.model.EquipmentScheduleViewFactory;

    import collaboRhythm.plugins.equipment.view.EquipmentScheduleItemClockView;
    import collaboRhythm.plugins.equipment.view.EquipmentScheduleItemReportingView;
    import collaboRhythm.plugins.equipment.view.EquipmentScheduleItemTimelineView;
    import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.EquipmentScheduleItem;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;

    import spark.components.Group;

    public class EquipmentScheduleViewFactory implements IScheduleViewFactory
    {
        public function EquipmentScheduleViewFactory()
        {
        }

        public function get scheduleItemType():ClassInfo
        {
            return ReflectionUtils.getClassInfo(EquipmentScheduleItem);
        }

        public function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence, parentGroup:Group):ScheduleItemClockViewBase
        {
            var equipmentScheduleItemClockView:EquipmentScheduleItemClockView =  new EquipmentScheduleItemClockView();
            equipmentScheduleItemClockView.init(scheduleItemOccurrence, parentGroup);
            return equipmentScheduleItemClockView;
        }

        public function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence, parentGroup:Group):ScheduleItemReportingViewBase
        {
            var equipmentScheduleItemReportingView:EquipmentScheduleItemReportingView = new EquipmentScheduleItemReportingView();
            equipmentScheduleItemReportingView.init(scheduleItemOccurrence, parentGroup);
            return equipmentScheduleItemReportingView;
        }

        public function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence, parentGroup:Group):ScheduleItemTimelineViewBase
        {
            var equipmentScheduleItemTimelineView:EquipmentScheduleItemTimelineView = new EquipmentScheduleItemTimelineView();
            equipmentScheduleItemTimelineView.init(scheduleItemOccurrence, parentGroup);
            return equipmentScheduleItemTimelineView;
        }
    }
}
