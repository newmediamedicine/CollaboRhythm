package collaboRhythm.shared.pluginsSupport
{
	/**
	 * A component container manages the registration (by component providers) and resolution (by component consumers)
	 * of components. Components are generally provided by plugins and used by the core applicaiton. 
	 * 
	 * @author sgilroy
	 * 
	 */
	public interface IComponentContainer
	{
		/**
		 * Registers a component instance as a provider of the specified service.
		 * 
		 * @param componentKey The component key.
		 * @param serviceType The service class or interface.
		 * @param componentInstance The component instance (which must be of a class that implements the service).
		 */
		function registerComponentInstance(componentKey:String, serviceType:Class, componentInstance:Object):void;
		
		/**
		 * Gets an instance of each component that implements the specified service.
		 * 
		 * @param serviceType The type of service to resolve.
		 * @return The array of resolved services, possibly empty.
		 */
		function resolveAll(serviceType:Class):Array /*of the service type*/;
		
		/**
		 * Removes all instances of all components that have been registered. 
		 * 
		 */
		function removeAllComponents():void;
	}
}