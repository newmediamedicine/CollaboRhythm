package collaboRhythm.workstation.controller
{

    import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
    import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.core.IVisualElementContainer;

    public class WorkstationAppControllersMediator extends AppControllersMediatorBase
    {
        public function WorkstationAppControllersMediator(
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
    }
}
