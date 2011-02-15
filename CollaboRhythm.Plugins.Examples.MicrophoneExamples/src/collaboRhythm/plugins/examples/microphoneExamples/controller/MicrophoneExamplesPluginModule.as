package collaboRhythm.plugins.examples.microphoneExamples.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;
	
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	
	import mx.modules.ModuleBase;
	
	public class MicrophoneExamplesPluginModule extends ModuleBase implements IPlugin
	{
		public function MicrophoneExamplesPluginModule()
		{
			super();
		}
		
		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(MicrophoneExamplesAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, new AppControllerInfo(MicrophoneExamplesAppController));
		}
	}
}