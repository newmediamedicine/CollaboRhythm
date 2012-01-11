package collaboRhythm.plugins.foraD40b.controller
{
    import collaboRhythm.plugins.schedule.shared.model.IScheduleCollectionsProvider;
    import collaboRhythm.plugins.schedule.shared.model.ScheduleModelKey;
    import collaboRhythm.shared.controller.apps.AppControllerBase;
    import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;

    public class ForaD40bAppController extends AppControllerBase
    {
        public static const DEFAULT_NAME:String = "FORA D40b";

        private var _scheduleModel:IScheduleCollectionsProvider;

        public function ForaD40bAppController(constructorParams:AppControllerConstructorParams)
        {
            super(constructorParams);
        }

        override public function initialize():void
        {
            super.initialize();
            initializeScheduleModel();
            updateWidgetViewModel();
            updateFullViewModel();
        }

        private function initializeScheduleModel():void
        {
            if (!_scheduleModel)
            {
                _scheduleModel = _activeRecordAccount.primaryRecord.getAppData(ScheduleModelKey.SCHEDULE_MODEL_KEY,
                        IScheduleCollectionsProvider) as IScheduleCollectionsProvider;
            }
        }

        override public function reloadUserData():void
        {
            removeUserData();
            initializeScheduleModel();

            super.reloadUserData();
        }

        private function get scheduleModel():IScheduleCollectionsProvider
        {
            return _scheduleModel;
        }

        protected override function removeUserData():void
        {
            _scheduleModel = null;
        }

        public override function get defaultName():String
        {
            return DEFAULT_NAME;
        }

    }
}
