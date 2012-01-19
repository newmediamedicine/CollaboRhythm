package collaboRhythm.plugins.healthActions.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.model.services.IComponentContainer;

	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class HealthActionsPluginModule extends ModuleBase implements IPlugin
	{
		public function HealthActionsPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(HealthActionsAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(HealthActionsAppController));
		}
	}
}