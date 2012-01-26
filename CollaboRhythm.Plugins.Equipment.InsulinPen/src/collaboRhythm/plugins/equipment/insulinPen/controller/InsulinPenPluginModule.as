package collaboRhythm.plugins.equipment.insulinPen.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.equipment.insulinPen.model.InsulinPenHealthActionInputControllerFactory;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class InsulinPenPluginModule extends ModuleBase implements IPlugin
	{
		public function InsulinPenPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(InsulinPenAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(InsulinPenAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(InsulinPenHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new InsulinPenHealthActionInputControllerFactory());
		}
	}
}