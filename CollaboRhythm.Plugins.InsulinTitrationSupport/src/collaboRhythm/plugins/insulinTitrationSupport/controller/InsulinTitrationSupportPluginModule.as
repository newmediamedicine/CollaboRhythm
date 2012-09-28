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
package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportChartModifierFactory;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportHealthActionInputControllerFactory;
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationSupportHealthActionListViewAdapterFactory;
	import collaboRhythm.insulinTitrationSupport.model.states.InsulinTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionInputControllerFactory;
	import collaboRhythm.plugins.schedule.shared.model.IHealthActionListViewAdapterFactory;
	import collaboRhythm.shared.insulinTitrationSupport.model.states.IInsulinTitrationDecisionSupportStatesFileStore;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.pluginsSupport.IPlugin;
	import collaboRhythm.shared.ui.healthCharts.model.modifiers.IChartModifierFactory;

	import mx.modules.ModuleBase;

	public class InsulinTitrationSupportPluginModule extends ModuleBase implements IPlugin
	{
		public function InsulinTitrationSupportPluginModule()
		{
			super();
		}

		public function registerComponents(componentContainer:IComponentContainer):void
		{
            componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(InsulinTitrationSupportHealthActionListViewAdapterFactory).name, IHealthActionListViewAdapterFactory, new InsulinTitrationSupportHealthActionListViewAdapterFactory());
			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(InsulinTitrationSupportHealthActionInputControllerFactory).name, IHealthActionInputControllerFactory, new InsulinTitrationSupportHealthActionInputControllerFactory());

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(InsulinTitrationSupportChartModifierFactory).name, IChartModifierFactory, new InsulinTitrationSupportChartModifierFactory());

			componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(IInsulinTitrationDecisionSupportStatesFileStore).name, IInsulinTitrationDecisionSupportStatesFileStore, new InsulinTitrationDecisionSupportStatesFileStore());
		}
	}
}
