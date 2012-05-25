package collaboRhythm.mobile.controller
{
	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;

	import mx.core.IVisualElementContainer;

	public class MobileAppControllersMediator extends AppControllersMediatorBase
    {
        public function MobileAppControllersMediator(widgetParentContainer:Vector.<IVisualElementContainer>,
													 scheduleWidgetParentContainer:IVisualElementContainer,
													 fullParentContainer:IVisualElementContainer,
													 componentContainer:IComponentContainer,
													 settings:Settings,
													 appControllerConstructorParams:AppControllerConstructorParams)
        {
            super(widgetParentContainer, fullParentContainer, componentContainer, settings,
					appControllerConstructorParams);
        }
    }
}
