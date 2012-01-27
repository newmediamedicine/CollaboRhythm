package collaboRhythm.plugins.postOpHome.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.controller.apps.AppOrderConstraint;

	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class PostOpHomePluginModule extends ModuleBase implements IPlugin
	    {
	        public function PostOpHomePluginModule()
	        {
	            super();
	        }

	        public function registerComponents(componentContainer:IComponentContainer):void
	        {
	            var typeName:String = ReflectionUtils.getClassInfo(PostOpHomeAppController).name;
	            componentContainer.registerComponentInstance(typeName, AppControllerInfo, new AppControllerInfo(PostOpHomeAppController));

				typeName = ReflectionUtils.getClassInfo(PostOpEducationAppController).name;
				componentContainer.registerComponentInstance(typeName, AppControllerInfo,  new AppControllerInfo(PostOpEducationAppController));

				typeName = ReflectionUtils.getClassInfo(PostOpHelpAppController).name;
				componentContainer.registerComponentInstance(typeName, AppControllerInfo,  new AppControllerInfo(PostOpHelpAppController));


			}
	    }
	}