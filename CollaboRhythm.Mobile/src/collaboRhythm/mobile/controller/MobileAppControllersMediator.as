package collaboRhythm.mobile.controller
{

    import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
    import collaboRhythm.shared.model.settings.Settings;
    import collaboRhythm.shared.model.services.IComponentContainer;

    import mx.core.IVisualElementContainer;

    public class MobileAppControllersMediator extends AppControllersMediatorBase
    {
        public function MobileAppControllersMediator(
            widgetParentContainer:IVisualElementContainer,
			scheduleWidgetParentContainer:IVisualElementContainer,
			fullParentContainer:IVisualElementContainer,
			settings:Settings,
//			healthRecordService:CommonHealthRecordService,
//			collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService,
			componentContainer:IComponentContainer
		)
        {
            super(widgetParentContainer,
                  scheduleWidgetParentContainer,
                  fullParentContainer,
                  settings,
//                  healthRecordService,
//                  collaborationRoomNetConnectionService,
                  componentContainer)
        }
        {
        }
    }
}
