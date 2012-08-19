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
package collaboRhythm.plugins.medications.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.medications.model.MedicationHealthActionCreationControllerFactory;

	import collaboRhythm.plugins.medications.model.MedicationHealthActionListViewAdapterFactory;

    import collaboRhythm.plugins.schedule.shared.controller.ScheduleAppControllerInfo;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionCreationControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
    import collaboRhythm.shared.controller.apps.AppControllerInfo;
	import collaboRhythm.shared.controller.apps.AppOrderConstraint;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;

	import mx.modules.ModuleBase;

	public class MedicationsPluginModule extends ModuleBase implements IPlugin
	{
		public function MedicationsPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
			var typeName:String = ReflectionUtils.getClassInfo(MedicationsAppController).name;
			var appControllerInfo:AppControllerInfo = new AppControllerInfo(MedicationsAppController);
			var afterScheduleAppOrderConstraint:AppOrderConstraint = new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, ScheduleAppControllerInfo.APP_ID);
			appControllerInfo.initializationOrderConstraints.push(afterScheduleAppOrderConstraint);
			appControllerInfo.initializationOrderConstraints.push(new AppOrderConstraint(AppOrderConstraint.ORDER_AFTER, "collaboRhythm.plugins.cataractMap.controller::CataractMapAppController"));
			componentContainer.registerComponentInstance(typeName, AppControllerInfo, appControllerInfo);

            componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(MedicationHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new MedicationHealthActionListViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(MedicationHealthActionCreationControllerFactory).name, IHealthActionCreationControllerFactory, new MedicationHealthActionCreationControllerFactory());
		}
	}
}
