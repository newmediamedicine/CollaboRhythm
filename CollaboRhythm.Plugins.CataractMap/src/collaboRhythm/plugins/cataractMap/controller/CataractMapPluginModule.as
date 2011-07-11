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
package collaboRhythm.plugins.cataractMap.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppOrderConstraint;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;
	
	import mx.modules.ModuleBase;
	
	public class CataractMapPluginModule extends ModuleBase implements IPlugin
	{
		public function CataractMapPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:collaboRhythm.shared.model.services.IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(CataractMapAppController).name;
			var appControllerInfo:AppControllerInfo = new AppControllerInfo(CataractMapAppController);
			appControllerInfo.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, "collaboRhythm.plugins.bloodPressure.controller::BloodPressureAppController"));
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, appControllerInfo);
		}
	}
}