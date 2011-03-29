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
	import collaboRhythm.core.controller.ApplicationControllerBase;
	import collaboRhythm.core.view.RemoteUsersListView;
	import collaboRhythm.mobile.view.WidgetContainerView;
	import collaboRhythm.shared.model.services.DemoEvent;
	import collaboRhythm.shared.view.CollaborationRoomView;
	import collaboRhythm.shared.view.RecordVideoView;

	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import mx.core.IVisualElementContainer;

	import spark.components.View;

	public class MobileApplicationController extends ApplicationControllerBase
	{
		private var _homeView:View;
		private var _mobileApplication:CollaboRhythmMobileApplication;
		private var _widgetContainerController:WidgetContainerController;
		
		public override function get collaborationRoomView():CollaborationRoomView
		{
			return null;
		}
		
		public override function get recordVideoView():RecordVideoView
		{
			return null;
		}
		
		public override function get remoteUsersView():RemoteUsersListView
		{
			return null;
		}
		
		public override function get widgetsContainer():IVisualElementContainer
		{
			return null;
		}
		
		public override function get scheduleWidgetContainer():IVisualElementContainer
		{
			return null;
		}
		
		public override function get fullContainer():IVisualElementContainer
		{
			return null;
		}
		
		public function MobileApplicationController(mobileApplication:CollaboRhythmMobileApplication)
		{
			_mobileApplication = mobileApplication;
		}
		
		private function viewNavigator_transitionCompleteHandler(event:Event):void
		{
//			trace("viewNavigator_transitionCompleteHandler");
		}

		private function viewNavigator_addedHandler(event:Event):void
		{
			var view:WidgetContainerView = event.target as WidgetContainerView;
			if (view)
			{
				initializeView(view);
			}
		}
		
		public function initializeActiveView():void
		{
			var view:WidgetContainerView = _mobileApplication.navigator.activeView as WidgetContainerView;
			if (view)
			{
				initializeView(view);
			}
		}

	private function initializeView(view:WidgetContainerView):void
	{
		_widgetContainerController.initializeView(view);
		view.demoDatePresets = _settings.demoDatePresets;
		view.addEventListener(DemoEvent.CHANGE_DEMO_DATE, view_changeDemoDateHandler);
	}

		private function view_changeDemoDateHandler(event:DemoEvent):void
		{
			targetDate = event.targetDate;
		}
		
		protected function get mobileCollaborationMediator():MobileCollaborationMediator
		{
			return _collaborationMediator as MobileCollaborationMediator;
		}
		
		public function main():void  
		{
			initLogging();
			logger.info("Logging initialized");

			initializeSettings();
			_settings.isWorkstationMode = false;
			logger.info("Settings initialized");
			logger.info("  Application settings file: " + _settingsFileStore.applicationSettingsFile.nativePath);
			logger.info("  User settings file: " + _settingsFileStore.userSettingsFile.nativePath);
			logger.info("  Mode: " + _settings.mode);
			logger.info("  Username: " + _settings.username);

			initializeComponents();
			logger.info("Components initialized. Asynchronous plugin loading initiated.");
			logger.info("  User plugins directory: " + _pluginLoader.userPluginsDirectoryPath);
			logger.info("  Number of loaded plugins: " + _pluginLoader.numPluginsLoaded);

			_collaborationMediator = new MobileCollaborationMediator(this);
			
			_widgetContainerController = new WidgetContainerController(_mobileApplication.navigator, _collaborationMediator);
			_mobileApplication.navigator.addEventListener(Event.COMPLETE, viewNavigator_transitionCompleteHandler);
			_mobileApplication.navigator.addEventListener(Event.ADDED, viewNavigator_addedHandler);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

			initializeActiveView();
		}

	public function keyDownHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.BACK:
					event.preventDefault();
					NativeApplication.nativeApplication.exit();
					trace("Back key is pressed."); 
					break; 
				case Keyboard.MENU: 
					if (_widgetContainerController != null)
					{
						var view:WidgetContainerView = _mobileApplication.navigator.activeView as WidgetContainerView;
						if (view)
						{
							_widgetContainerController.toggleMenu(view);
						}
					}
					
					break; 
				case Keyboard.SEARCH: 
					trace("Search key is pressed."); 
					break;
				case Keyboard.HOME:
					event.preventDefault();
					break;
			} 
		} 
		
	}
}
