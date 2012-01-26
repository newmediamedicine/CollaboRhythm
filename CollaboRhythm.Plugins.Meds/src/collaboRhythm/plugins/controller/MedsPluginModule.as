package collaboRhythm.plugins.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.model.MedsHealthActionInputControllerFactory;
	import collaboRhythm.plugins.model.MedsHealthActionListViewAdapterFactory;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class MedsPluginModule extends ModuleBase implements IPlugin
	{
		public function MedsPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(MedsAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(MedsAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(MedsHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new MedsHealthActionListViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(MedsHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new MedsHealthActionInputControllerFactory());
		}
	}
}

