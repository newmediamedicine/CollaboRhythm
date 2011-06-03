package collaboRhythm.plugins.schedule.model
{

    import castle.flexbridge.reflection.ClassInfo;
    import castle.flexbridge.reflection.ReflectionUtils;
    import castle.flexbridge.reflection.ReflectionUtils;

    import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.ScheduleItemBase;
    import collaboRhythm.shared.model.services.IComponentContainer;

    import flash.utils.Dictionary;

    public class MasterScheduleViewFactory implements IScheduleViewFactory
    {
        private var _factoryDictionary:Dictionary = new Dictionary();

        public function MasterScheduleViewFactory(componentContainer:IComponentContainer)
        {
            var factoryArray:Array = componentContainer.resolveAll(IScheduleViewFactory);

            for each (var factory:IScheduleViewFactory in factoryArray)
            {
                _factoryDictionary[factory.scheduleItemType.name] = factory;
            }
        }

        public function get scheduleItemType():ClassInfo
        {
            return null;
        }

        public function createScheduleItemClockView(scheduleItem:ScheduleItemBase):ScheduleItemClockViewBase
        {
            return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItem)).name].createScheduleItemClockView(scheduleItem);
        }

        public function createScheduleItemReportingView(scheduleItem:ScheduleItemBase):ScheduleItemReportingViewBase
        {
            return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItem)).name].createScheduleItemReportingView(scheduleItem);
        }

        public function createScheduleItemTimelineView(scheduleItem:ScheduleItemBase):ScheduleItemTimelineViewBase
        {
            return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItem)).name].createScheduleItemTimelineView(scheduleItem);
        }
    }
}
