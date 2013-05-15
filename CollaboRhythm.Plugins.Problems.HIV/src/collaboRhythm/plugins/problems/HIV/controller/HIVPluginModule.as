package collaboRhythm.plugins.problems.HIV.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.problems.HIV.model.AddHivMedicationHealthActionCreationControllerFactory;
	import collaboRhythm.plugins.problems.HIV.model.HIVChartModifierFactory;

	import collaboRhythm.plugins.problems.HIV.model.TCellCountHealthActionCreationControllerFactory;

	import collaboRhythm.plugins.problems.HIV.model.ViralLoadHealthActionCreationControllerFactory;

	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	import mx.modules.ModuleBase;

	public class HIVPluginModule extends ModuleBase implements IPlugin
	{
		public function HIVPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(HIVAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, new AppControllerInfo(HIVAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(AddHivMedicationHealthActionCreationControllerFactory).name, IHealthActionCreationControllerFactory, new AddHivMedicationHealthActionCreationControllerFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(ViralLoadHealthActionCreationControllerFactory).name, IHealthActionCreationControllerFactory, new ViralLoadHealthActionCreationControllerFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(TCellCountHealthActionCreationControllerFactory).name, IHealthActionCreationControllerFactory, new TCellCountHealthActionCreationControllerFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(HIVChartModifierFactory).name, IChartModifierFactory, new HIVChartModifierFactory());
		}
	}
}
