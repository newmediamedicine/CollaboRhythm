package collaboRhythm.workstation.apps.bloodPressure.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.workstation.controller.apps.AppControllerInfo;
	
	import mx.modules.ModuleBase;
	
	public class BloodPressurePluginModule extends ModuleBase implements IPlugin
	{
		public function BloodPressurePluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(BloodPressureAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, new AppControllerInfo(BloodPressureAppController));
		}
	}
}