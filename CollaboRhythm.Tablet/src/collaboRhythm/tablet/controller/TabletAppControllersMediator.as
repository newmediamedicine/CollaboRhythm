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
package collaboRhythm.tablet.controller
{

	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;

	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;

	import spark.components.ViewNavigator;

	public class TabletAppControllersMediator extends AppControllersMediatorBase
    {
		private var _tabletApplicationController:TabletApplicationController;

        public function TabletAppControllersMediator(widgetContainers:Vector.<IVisualElementContainer>,
													 fullParentContainer:IVisualElementContainer, settings:Settings,
													 componentContainer:IComponentContainer, collaborationLobbyNetConnectionService:CollaborationLobbyNetConnectionService,
				tabletApplicationController:TabletApplicationController)
        {
            super(widgetContainers, fullParentContainer, settings, componentContainer, collaborationLobbyNetConnectionService);
			_tabletApplicationController = tabletApplicationController;
        }

		override protected function showFullViewResolved(appController:AppControllerBase,
														 source:String):AppControllerBase
		{
			// destroy all full views and widget views

			var appInstance:AppControllerBase;

			// TODO: use app id instead of name
			currentFullView = appController.name;

			_tabletApplicationController.pushFullView(appController);
			appInstance = appController;

			return appInstance;
		}

		public function destroyWidgetViews():void
		{
			for each (var app:AppControllerBase in apps.values())
			{
				app.destroyWidgetView();
			}
		}

		override protected function initializeForAccount(activeAccount:Account, activeRecordAccount:Account):void
		{
			super.initializeForAccount(activeAccount, activeRecordAccount);
			factory.viewNavigator = _tabletApplicationController.navigator;
		}
	}
}
