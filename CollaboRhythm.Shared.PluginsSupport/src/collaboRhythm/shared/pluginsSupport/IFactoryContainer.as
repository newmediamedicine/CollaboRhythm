package collaboRhythm.shared.pluginsSupport
{
	import mx.core.IFactory;

	public interface IFactoryContainer
	{
		/**
		 * Adds a factory to the container for the given creatable type.
		 * The provided factory must create an object of the specified type when IFactory.newInstance is invoked.
		 * Note that multiple factories can be added for a given type.
		 * 
		 * @param factory the provided factory
		 * @param type
		 * 
		 */
		function addFactory(factory:IFactory, type:Class):void;
		function getFactories(type:Class):Vector.<IFactory>;
	}
}