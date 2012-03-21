package collaboRhythm.mobile.controller
{

    import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.settings.Settings;
    import collaboRhythm.shared.model.services.IComponentContainer;

    import mx.core.IVisualElementContainer;

    public class MobileAppControllersMediator extends AppControllersMediatorBase
    {
        public function MobileAppControllersMediator(
            widgetParentContainer:Vector.<IVisualElementContainer>,
			scheduleWidgetParentContainer:IVisualElementContainer,
			fullParentContainer:IVisualElementContainer,
			settings:Settings,
//			healthRecordService:CommonHealthRecordService,
//			collaborationRoomNetConnectionService:CollaborationRoomNetConnectionService,
			componentContainer:IComponentContainer,
			collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService
		)
        {
            super(widgetParentContainer, fullParentContainer, settings, componentContainer, collaborationLobbyNetConnectionService)
        }
        {
        }
    }
}
