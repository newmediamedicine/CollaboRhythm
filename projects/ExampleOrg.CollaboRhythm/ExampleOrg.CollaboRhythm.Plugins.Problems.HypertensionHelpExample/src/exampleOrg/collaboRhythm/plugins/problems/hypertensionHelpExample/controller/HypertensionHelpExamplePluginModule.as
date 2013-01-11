package exampleOrg.collaboRhythm.plugins.problems.hypertensionHelpExample.controller
{

	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	import mx.modules.ModuleBase;

	public class HypertensionHelpExamplePluginModule extends ModuleBase implements IPlugin
	{
		public function HypertensionHelpExamplePluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			// TODO: each plugin should register one or more of the following components; implement or delete the code below as appropriate; using the CollaboRhythm file templates in IntelliJ IDEA may make this easier
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(HypertensionHelpExampleAppController).name,
														 AppControllerInfo,
														 new AppControllerInfo(HypertensionHelpExampleAppController));

/*
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(HypertensionHelpExampleHealthActionListViewAdapterFactory).name,
														 IHealthActionListViewAdapterFactory,
														 new HypertensionHelpExampleHealthActionListViewAdapterFactory());

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(HypertensionHelpExampleHealthActionInputControllerFactory).name,
														 IHealthActionInputControllerFactory,
														 new HypertensionHelpExampleHealthActionInputControllerFactory());

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(HypertensionHelpExampleChartModifierFactory).name,
														 IChartModifierFactory,
														 new HypertensionHelpExampleChartModifierFactory());

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(HypertensionHelpExampleHealthActionCreationControllerFactory).name,
														 IHealthActionCreationControllerFactory,
														 new HypertensionHelpExampleHealthActionCreationControllerFactory());
*/
		}
	}
}
