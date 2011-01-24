package collaboRhythm.shared.pluginsSupport
{
	public interface IPlugin
	{
		function registerFactories(factoryMediator:IFactoryContainer):void;
	}
}