package collaboRhythm.workstation.controller
{

    import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.services.IComponentContainer;
    import collaboRhythm.shared.model.settings.Settings;

    import mx.core.IVisualElementContainer;

    public class WorkstationAppControllersMediator extends AppControllersMediatorBase
    {
        public function WorkstationAppControllersMediator(
			widgetContainers:Vector.<IVisualElementContainer>,
			fullContainer:IVisualElementContainer,
			settings:Settings,
//			healthRecordService:CommonHealthRecordService,
//			collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService,
			componentContainer:IComponentContainer,
			collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService
		)
        {
            super(widgetContainers, fullContainer, settings, componentContainer, collaborationLobbyNetConnectionService)
        }
    }
}
