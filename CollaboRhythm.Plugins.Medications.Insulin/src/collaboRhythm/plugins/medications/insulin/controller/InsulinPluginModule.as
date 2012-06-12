package collaboRhythm.plugins.medications.insulin.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.medications.insulin.model.InsulinHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class InsulinPluginModule extends ModuleBase implements IPlugin
	{
		public function InsulinPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(InsulinAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
														 new AppControllerInfo(InsulinAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(InsulinHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new InsulinHealthActionListViewAdapterFactory());
		}
	}
}
