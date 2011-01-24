package collaboRhythm.workstation.apps.bloodPressure.controller
{
	import collaboRhythm.shared.pluginsSupport.IFactoryContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.workstation.controller.apps.AppControllerInfo;
	
	import mx.core.IFactory;
	import mx.modules.ModuleBase;
	
	public class BloodPressurePluginModule extends ModuleBase implements IPlugin, IFactory
	{
		public function BloodPressurePluginModule()
		{
			super();
		}

		public function registerFactories(factoryMediator:IFactoryContainer):void
		{
			factoryMediator.addFactory(this, AppControllerInfo);
		}
		
		public function newInstance():*
		{
			return new AppControllerInfo(BloodPressureAppController);
		}
	}
}