package collaboRhythm.workstation.controller
{

	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;

	import mx.core.IVisualElementContainer;

	public class WorkstationAppControllersMediator extends AppControllersMediatorBase
    {
        public function WorkstationAppControllersMediator(
			widgetContainers:Vector.<IVisualElementContainer>,
			fullContainer:IVisualElementContainer,
			componentContainer:IComponentContainer,
			settings:Settings,
			appControllerConstructorParams:AppControllerConstructorParams
		)
        {
            super(widgetContainers, fullContainer, componentContainer, settings, appControllerConstructorParams);
        }
    }
}
