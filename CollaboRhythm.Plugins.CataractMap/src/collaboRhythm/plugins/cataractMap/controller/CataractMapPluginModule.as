package collaboRhythm.plugins.cataractMap.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	
	import mx.modules.ModuleBase;
	
	public class CataractMapPluginModule extends ModuleBase implements IPlugin
	{
		public function CataractMapPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(CataractMapAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, new AppControllerInfo(CataractMapAppController));
		}
	}
}