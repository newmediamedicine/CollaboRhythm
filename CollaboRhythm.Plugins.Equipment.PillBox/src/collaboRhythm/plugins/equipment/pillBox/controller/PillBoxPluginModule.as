package collaboRhythm.plugins.equipment.pillBox.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.equipment.pillBox.model.PillBoxHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class PillBoxPluginModule extends ModuleBase implements IPlugin
	    {
	        public function PillBoxPluginModule()
	        {
	            super();
	        }

	        public function registerComponents(componentContainer:IComponentContainer):void
	        {
	            var typeName:String = ReflectionUtils.getClassInfo(PillBoxAppController).name;
				componentContainer.registerComponentInstance(typeName, AppControllerInfo,
									new AppControllerInfo(PillBoxAppController));

				componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(PillBoxHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new PillBoxHealthActionInputControllerFactory());
	        }
	    }
	}