package collaboRhythm.plugins.medications.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.workstation.controller.apps.AppControllerInfo;
	
	import mx.modules.ModuleBase;
	
	public class MedicationsPluginModule extends ModuleBase implements IPlugin
	{
		public function MedicationsPluginModule()
		{
			super();
		}
		
		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(MedicationsAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, new AppControllerInfo(MedicationsAppController));
		}
	}
}