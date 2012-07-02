package collaboRhythm.plugins.foraD40b.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.foraD40b.model.ForaD40bHealthActionInputControllerFactory;
	import collaboRhythm.plugins.foraD40b.model.ForaD40bHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.controller.ScheduleAppControllerInfo;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.controller.apps.AppOrderConstraint;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class ForaD40bPluginModule extends ModuleBase implements IPlugin
    {
        public function ForaD40bPluginModule()
        {
            super();
        }

        public function registerComponents(componentContainer:IComponentContainer):void
        {
            var typeName:String = ReflectionUtils.getClassInfo(ForaD40bAppController).name;
            var appControllerInfo:AppControllerInfo = new AppControllerInfo(ForaD40bAppController);
            var afterScheduleAppOrderConstraint:AppOrderConstraint = new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, ScheduleAppControllerInfo.APP_ID);
            appControllerInfo.initializationOrderConstraints.push(afterScheduleAppOrderConstraint);
            componentContainer.registerComponentInstance(typeName, AppControllerInfo, appControllerInfo);

            componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(ForaD40bHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new ForaD40bHealthActionInputControllerFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(ForaD40bHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new ForaD40bHealthActionListViewAdapterFactory());
        }
    }
}
