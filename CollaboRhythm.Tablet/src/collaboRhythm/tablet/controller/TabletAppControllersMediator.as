package collaboRhythm.tablet.controller
{

	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;

	import mx.core.IVisualElementContainer;

	public class TabletAppControllersMediator extends AppControllersMediatorBase
    {
        public function TabletAppControllersMediator(widgetContainers:Vector.<IVisualElementContainer>,
													 fullParentContainer:IVisualElementContainer, settings:Settings,
													 componentContainer:IComponentContainer, collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService)
        {
            super(widgetContainers, fullParentContainer, settings, componentContainer, collaborationLobbyNetConnectionService)
        }
	}
}
