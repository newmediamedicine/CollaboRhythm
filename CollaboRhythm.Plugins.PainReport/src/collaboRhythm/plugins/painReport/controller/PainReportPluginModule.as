package collaboRhythm.plugins.painReport.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.painReport.model.PainReportHealthActionInputControllerFactory;
	import collaboRhythm.plugins.painReport.model.PainReportHealthActionListViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;

	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class PainReportPluginModule extends ModuleBase implements IPlugin
	{
		public function PainReportPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(PainReportAppController).name;
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
					new AppControllerInfo(PainReportAppController));

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(PainReportHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new PainReportHealthActionListViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(PainReportHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new PainReportHealthActionInputControllerFactory());
		}
	}
}
