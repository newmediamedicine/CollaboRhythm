package collaboRhythm.plugins.bathroom.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;
	import collaboRhythm.plugins.bathroom.model.BathroomHealthActionInputControllerFactory;
	import collaboRhythm.plugins.bathroom.model.BathroomHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class BathroomPluginModule extends ModuleBase implements IPlugin
	{
		public function BathroomPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(BathroomAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(BathroomAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(BathroomHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new BathroomHealthActionListViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(BathroomHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new BathroomHealthActionInputControllerFactory());
		}
	}
}

