package collaboRhythm.plugins.messages.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class MessagesPluginModule extends ModuleBase implements IPlugin
		{
			public function MessagesPluginModule()
			{
				super();
			}

			public function registerComponents(componentContainer:IComponentContainer):void
			{
				var typeName:String = ReflectionUtils.getClassInfo(MessagesAppController).name;
				componentContainer.registerComponentInstance(typeName, AppControllerInfo,
						new AppControllerInfo(MessagesAppController));

			}
	}
}
