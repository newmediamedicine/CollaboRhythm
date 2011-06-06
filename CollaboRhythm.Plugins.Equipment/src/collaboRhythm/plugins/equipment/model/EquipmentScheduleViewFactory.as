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

    public class EquipmentScheduleViewFactory implements IScheduleViewFactory
    {
        public function EquipmentScheduleViewFactory()
        {
        }

        public function get scheduleItemType():ClassInfo
        {
            return ReflectionUtils.getClassInfo(EquipmentScheduleItem);
        }

        public function createScheduleItemClockView(scheduleItem:ScheduleItemBase):ScheduleItemClockViewBase
        {
            return new EquipmentScheduleItemClockView();
        }

        public function createScheduleItemReportingView(scheduleItem:ScheduleItemBase):ScheduleItemReportingViewBase
        {
            return new EquipmentScheduleItemReportingView();
        }

        public function createScheduleItemTimelineView(scheduleItem:ScheduleItemBase):ScheduleItemTimelineViewBase
        {
            var equipmentScheduleItemTimelineView:EquipmentScheduleItemTimelineView = new EquipmentScheduleItemTimelineView();
            equipmentScheduleItemTimelineView.init(scheduleItem);
            return equipmentScheduleItemTimelineView;
        }
    }
}
