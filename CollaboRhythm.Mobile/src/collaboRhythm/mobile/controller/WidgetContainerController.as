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
package collaboRhythm.mobile.controller
{
	import collaboRhythm.core.pluginsManagement.PluginEvent;
	import collaboRhythm.core.pluginsManagement.PluginLoader;
	import collaboRhythm.mobile.view.WidgetContainerView;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import flash.events.TransformGestureEvent;
	import flash.filesystem.File;

	import spark.components.ViewNavigator;
	import spark.transitions.SlideViewTransition;
	import spark.transitions.ViewTransitionDirection;

	public class WidgetContainerController
	{
		private var _navigator:ViewNavigator;
		private var _moblieApplicationController:MobileApplicationController;
		
		public function WidgetContainerController(navigator:ViewNavigator, moblieApplicationController:MobileApplicationController)
		{
			_navigator = navigator;
			_moblieApplicationController = moblieApplicationController;
		}

		public function get widgetNavigationIndex():int
		{
			return _navigator.length - 1;
		}

		public function get navigator():ViewNavigator
		{
			return _navigator;
		}
		
		public function gestureSwipeHandler(event:TransformGestureEvent):void
		{
			// Swipe was to the right
			if (event.offsetX == 1 )
			{
				popView();
			}
			// Swipe was to the left
			else if (event.offsetX == -1)
			{
				pushView();
			}
		}
		
		public function popView():Boolean
		{
			// TODO: fix bug where sometimes we do too many pops and there is no view left 
			if (_moblieApplicationController.mobileAppControllersMediator && widgetNavigationIndex > 0)
			{
				var slideViewTransition:SlideViewTransition = new SlideViewTransition();
				slideViewTransition.direction = ViewTransitionDirection.RIGHT;
				navigator.popView(slideViewTransition);
				
				return true;
			}
			else
				return false;
		}

		public function pushView():Boolean
		{
			if (_moblieApplicationController.mobileAppControllersMediator && widgetNavigationIndex + 1 < _moblieApplicationController.mobileAppControllersMediator.workstationApps.length)
			{
				navigator.pushView(WidgetContainerView, null,
					new SlideViewTransition());
				
				return true;
			}
			else
				return false;
		}
		
		public function initializeView(view:WidgetContainerView):void
		{
			view.infoData =
				<root>
					<InfoItem>
						<name>Application Directory</name>
						<value>{File.applicationDirectory.nativePath}</value>
					</InfoItem>
					<InfoItem>
						<name>Application Storage (User) Directory</name>
						<value>{File.applicationStorageDirectory.nativePath}</value>
					</InfoItem>
					<InfoItem>
						<name>Mode</name>
						<value>{_moblieApplicationController.settings.mode}</value>
					</InfoItem>
					<InfoItem>
						<name>Username</name>
						<value>{_moblieApplicationController.settings.username}</value>
					</InfoItem>
					<InfoItem>
						<name>Indivo Server URL</name>
						<value>{_moblieApplicationController.settings.indivoServerBaseURL}</value>
					</InfoItem>
					<InfoItem>
						<name>User settings file loaded</name>
                        <value>{_moblieApplicationController.settingsFileStore.isUserSettingsLoaded}</value>
                    </InfoItem>
                    <InfoItem>
                        <name>User settings file location</name>
                        <value>{_moblieApplicationController.settingsFileStore.userSettingsFile.nativePath}</value>
                    </InfoItem>
					<InfoItem>
						<name>Application settings file loaded</name>
						<value>{_moblieApplicationController.settingsFileStore.isApplicationSettingsLoaded}</value>
					</InfoItem>
					<InfoItem>
						<name>Num Plugin Files</name>
						<value>{getNumPluginFiles()}</value>
					</InfoItem>
					<InfoItem>
						<name>Num Dynamic Apps</name>
						<value>{_moblieApplicationController.mobileAppControllersMediator ? _moblieApplicationController.mobileAppControllersMediator.numDynamicApps : "(not loaded)"}</value>
					</InfoItem>
				</root>;

			// FIXME: occasionally I get the following compile error; casting as WidgetContainerController does not help; clean or otherwise rebuilding the project generally resolved the error
			// 1067: Implicit coercion of a value of type collaboRhythm.mobile.controller:WidgetContainerController to an unrelated type collaboRhythm.mobile.controller:WidgetContainerController.
			view.controller = this;
			view.addEventListener(PluginEvent.RELOAD_REQUEST, view_reloadRequestHandler);

			if (_moblieApplicationController.mobileAppControllersMediator && widgetNavigationIndex >= 0 && widgetNavigationIndex < _moblieApplicationController.mobileAppControllersMediator.workstationApps.length)
			{
				var app:WorkstationAppControllerBase = _moblieApplicationController.mobileAppControllersMediator.workstationApps.getValueByIndex(widgetNavigationIndex);
				view.workstationAppController = app;
				if (app)
				{
					view.title = app.name;
					app.widgetParentContainer = view;
					app.createAndPrepareWidgetView();
					app.widgetView.percentWidth = 100;
					app.widgetView.percentHeight = 100;
					app.showWidget();
				}
			}
		}

		private function getNumPluginFiles():int
		{
			var num:int;
			var pluginLoader:PluginLoader = new PluginLoader();
			num = pluginLoader.getNumPluginFiles();
			return num;
		}
		
		public function view_reloadRequestHandler(event:PluginEvent):void
		{
			_moblieApplicationController.reloadPlugins();
		}
		
		public function destroyView(view:WidgetContainerView):void
		{
			view.removeEventListener(PluginEvent.RELOAD_REQUEST, view_reloadRequestHandler);
			var app:WorkstationAppControllerBase = view.workstationAppController;
			// TODO: perhaps only the widget/mobile view should be destroyed here?
			if (app)
				app.destroyViews();
		}
		
		public function toggleMenu(view:WidgetContainerView):void
		{
			view.toggleMenu();
		}
	}
}