package collaboRhythm.plugins.equipment.chameleonSpirometer.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.equipment.chameleonSpirometer.model.ChameleonSpirometerHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class ChameleonSpirometerPluginModule extends ModuleBase implements IPlugin
	{
		public function ChameleonSpirometerPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(ChameleonSpirometerAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(ChameleonSpirometerAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(ChameleonSpirometerHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new ChameleonSpirometerHealthActionInputControllerFactory());
		}
	}
}
