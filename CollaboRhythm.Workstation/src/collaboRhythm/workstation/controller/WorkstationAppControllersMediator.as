package collaboRhythm.workstation.controller
{

    import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
    import collaboRhythm.shared.model.CollaborationRoomNetConnectionService;
    import collaboRhythm.shared.model.healthRecord.CommonHealthRecordService;
    import collaboRhythm.shared.model.settings.Settings;
    import collaboRhythm.shared.pluginsSupport.IComponentContainer;

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
