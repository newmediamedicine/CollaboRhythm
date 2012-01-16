package collaboRhythm.plugins.painReport.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.painReport.model.PainReportDataInputControllerFactory;
	import collaboRhythm.plugins.painReport.model.PainReportReportingViewAdapterFactory;
	import collaboRhythm.plugins.schedule.shared.model.IDataInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IReportingViewAdapterFactory;

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

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(PainReportReportingViewAdapterFactory).name, IReportingViewAdapterFactory, new PainReportReportingViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(PainReportDataInputControllerFactory).name, IDataInputControllerFactory, new PainReportDataInputControllerFactory());
		}
	}
}
