/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see <http://www.gnu.org/licenses/>.
*/
package collaboRhythm.mobile.controller
{
	import collaboRhythm.mobile.view.WidgetContainerView;
	import collaboRhythm.workstation.controller.ApplicationControllerBase;
	import collaboRhythm.workstation.controller.CollaborationMediator;
	import collaboRhythm.workstation.model.Settings;
	import collaboRhythm.workstation.view.CollaborationRoomView;
	import collaboRhythm.workstation.view.RemoteUsersListView;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	
	import mx.core.IVisualElementContainer;
	
	import spark.components.View;
	import spark.components.ViewNavigator;
	import spark.effects.ViewTransition;

	public class MobileApplicationController extends ApplicationControllerBase
	{
		private var _homeView:View;
		private var _mobileApplication:CollaboRhythmMobileApplication;
		private var _widgetContainerController:WidgetContainerController;
		
		public override function get collaborationRoomView():CollaborationRoomView
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
			var navigator:ViewNavigator = _mobileApplication.navigator;
//			var view:WidgetContainerView = navigator.getElementAt(navigator.numElements - 1) as WidgetContainerView;
			var view:WidgetContainerView = event.target as WidgetContainerView;
			if (view)
			{
				_widgetContainerController.initializeView(view);
			}
		}
		
		public function initializeActiveView():void
		{
			var view:WidgetContainerView = _mobileApplication.navigator.activeView as WidgetContainerView;
			if (view)
			{
				_widgetContainerController.initializeView(view);
			}
		}
		
		protected function get mobileCollaborationMediator():MobileCollaborationMediator
		{
			return _collaborationMediator as MobileCollaborationMediator;
		}
		
		public function main():void  
		{
			initLogging();
			logger.info("Logging initialized");
			
			_settings = new Settings();
			_settings.isWorkstationMode = false;
			logger.info("Settings initialized");
			
			initializeComponents();
			logger.info("Components initialized");
			
			_collaborationMediator = new MobileCollaborationMediator(this);
			
			_widgetContainerController = new WidgetContainerController(_mobileApplication.navigator, _collaborationMediator);
			_mobileApplication.navigator.addEventListener(Event.COMPLETE, viewNavigator_transitionCompleteHandler);
			_mobileApplication.navigator.addEventListener(Event.ADDED, viewNavigator_addedHandler);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		public function keyDownHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.BACK:
					event.preventDefault();
					trace("Back key is pressed."); 
					break; 
				case Keyboard.MENU: 
					trace("Menu key is pressed.");
					
					trace("  applicationStorageDirectory", File.applicationStorageDirectory.nativePath);
					trace("  applicationDirectory", File.applicationDirectory.nativePath);
					break; 
				case Keyboard.SEARCH: 
					trace("Search key is pressed."); 
					break; 
			} 
		} 
		
	}
}