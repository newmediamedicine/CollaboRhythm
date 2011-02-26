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
package collaboRhythm.plugins.bloodPressure.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.shared.controller.apps.AppOrderConstraint;
	import collaboRhythm.shared.pluginsSupport.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.controller.apps.AppControllerInfo;

	import mx.modules.ModuleBase;

	public class BloodPressurePluginModule extends ModuleBase implements IPlugin
	{
		public function BloodPressurePluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(BloodPressureAppController).name;
			var mainAppControllerInfo:AppControllerInfo = new AppControllerInfo(BloodPressureAppController);
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
														 mainAppControllerInfo);

			typeName = ReflectionUtils.getClassInfo(BloodPressureChartAppController).name;
			var chartAppControllerInfo:AppControllerInfo = new AppControllerInfo(BloodPressureChartAppController);
			chartAppControllerInfo.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER,
																						 mainAppControllerInfo.appId));
			componentContainer.registerComponentInstance(typeName, AppControllerInfo,
														 chartAppControllerInfo);
		}
	}
}