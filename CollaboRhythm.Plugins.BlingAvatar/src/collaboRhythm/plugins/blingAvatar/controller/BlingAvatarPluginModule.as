package collaboRhythm.plugins.blingAvatar.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class BlingAvatarPluginModule extends ModuleBase implements IPlugin
		{
			public function BlingAvatarPluginModule()
			{
				super();
			}
	
			public function registerComponents(componentContainer:IComponentContainer):void
			{
				var typeName:String = ReflectionUtils.getClassInfo(BlingAvatarAppController).name;
				componentContainer.registerComponentInstance(typeName, AppControllerInfo,
						new AppControllerInfo(BlingAvatarAppController));
			}
		}
	}
