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
package collaboRhythm.shared.pluginsSupport
{

    import collaboRhythm.shared.model.services.IComponentContainer;

    import mx.modules.IModule;

	/**
	 * A CollaboRhythm plugin. Plugins must implement this interface as well as IModule. See AppControllerInfo and
	 * the various CollaboRhythm I*Factory interfaces for possible components to register.
	 * @see AppControllerInfo
	 */
	public interface IPlugin extends IModule
	{
		/**
		 * Registers components that this plugin provides. Plugins should implement this method in order to provide
		 * known components or services which the core application or other plugins can use.
		 *
		 * @param componentContainer The shared component container with which the plugin should register components
		 * and which the core application and other plugins will use to resolve registered components.
		 */
		function registerComponents(componentContainer:IComponentContainer):void;
	}
}