package collaboRhythm.plugins.asthmaManagement.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class AsthmaManagementPluginModule extends ModuleBase implements IPlugin
	{
		public function AsthmaManagementPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(AsthmaManagementAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(AsthmaManagementAppController));
		}
	}
}
