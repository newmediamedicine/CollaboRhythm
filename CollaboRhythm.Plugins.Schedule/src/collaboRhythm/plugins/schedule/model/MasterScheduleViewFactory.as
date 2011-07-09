package collaboRhythm.plugins.schedule.model
{

    import castle.flexbridge.reflection.ClassInfo;
    import castle.flexbridge.reflection.ReflectionUtils;

    import collaboRhythm.plugins.schedule.shared.model.IScheduleReportingModel;

    import collaboRhythm.plugins.schedule.shared.model.IScheduleViewFactory;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemClockViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemReportingViewBase;
    import collaboRhythm.plugins.schedule.shared.view.ScheduleItemTimelineViewBase;
    import collaboRhythm.shared.model.ScheduleItemOccurrence;
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

        public function createScheduleItemClockView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemClockViewBase
        {
            return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem)).name].createScheduleItemClockView(scheduleItemOccurrence);
        }

        public function createScheduleItemReportingView(scheduleItemOccurrence:ScheduleItemOccurrence, scheduleReportingModel:IScheduleReportingModel):ScheduleItemReportingViewBase
        {
            return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem)).name].createScheduleItemReportingView(scheduleItemOccurrence, scheduleReportingModel);
        }

        public function createScheduleItemTimelineView(scheduleItemOccurrence:ScheduleItemOccurrence):ScheduleItemTimelineViewBase
        {
            return _factoryDictionary[ReflectionUtils.getClassInfo(ReflectionUtils.getClass(scheduleItemOccurrence.scheduleItem)).name].createScheduleItemTimelineView(scheduleItemOccurrence);
        }
    }
}
