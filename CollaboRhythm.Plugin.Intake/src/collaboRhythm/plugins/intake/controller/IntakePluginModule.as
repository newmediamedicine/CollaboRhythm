package collaboRhythm.plugins.intake.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.intake.model.IntakeHealthActionInputControllerFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class IntakePluginModule extends ModuleBase implements IPlugin
	{
		public function IntakePluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(IntakeAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(IntakeAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(IntakeHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new PainReportHealthActionListViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(IntakeHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new PainReportHealthActionInputControllerFactory());
		}
	}
}
