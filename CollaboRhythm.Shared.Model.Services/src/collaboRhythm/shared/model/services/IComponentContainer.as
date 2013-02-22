/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.model.services
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
		 * Unregisers all of the component instances of a specified service type.
		 *
		 * @param serviceType The service class or interface.
		 */
		function unregisterServiceType(serviceType:Class):void;

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