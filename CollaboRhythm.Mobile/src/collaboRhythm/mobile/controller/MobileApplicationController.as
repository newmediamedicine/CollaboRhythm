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
	import collaboRhythm.core.controller.apps.AppControllersMediatorBase;
	import collaboRhythm.mobile.view.WidgetContainerView;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.services.DemoEvent;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.view.CollaborationRoomView;
	import collaboRhythm.shared.view.CollaborationView;
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
		private var _mobileAppControllersMediator:MobileAppControllersMediator;

		[Embed("/resources/settings.xml", mimeType="application/octet-stream")]
		private var _applicationSettingsEmbeddedFile:Class;

		public function MobileApplicationController(mobileApplication:CollaboRhythmMobileApplication)
		{
			_mobileApplication = mobileApplication;
		}

		override public function main():void
		{
			super.main();

			_settings.modality = Settings.MODALITY_MOBILE;

//			_collaborationMediator = new MobileCollaborationMediator(this);
			initCollaborationController(null);

			_widgetContainerController = new WidgetContainerController(_mobileApplication.navigator, this);
			_mobileApplication.navigator.addEventListener(Event.COMPLETE, viewNavigator_transitionCompleteHandler);
			_mobileApplication.navigator.addEventListener("viewChangeComplete",
														  viewNavigator_transitionCompleteHandler);
			_mobileApplication.navigator.addEventListener(Event.ADDED, viewNavigator_addedHandler);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

			initializeActiveView();

			createSession();
		}

		public override function get fullContainer():IVisualElementContainer
		{
			return null;
		}

		public override function openRecordAccount(recordAccount:Account):void
		{
			super.openRecordAccount(recordAccount);
			_mobileAppControllersMediator = new MobileAppControllersMediator(null,
																			 null,
																			 fullContainer,
																			 _settings,
																			 _componentContainer,
																			 _collaborationController.collaborationModel.collaborationLobbyNetConnectionService);
			_mobileAppControllersMediator.createMobileApps(_activeAccount, recordAccount);
			initializeActiveView();
		}

		private function viewNavigator_transitionCompleteHandler(event:Event):void
		{
//			trace("viewNavigator_transitionCompleteHandler");
			_mobileApplication.busy = false;
		}

		private function viewNavigator_addedHandler(event:Event):void
		{
			var view:WidgetContainerView = event.target as WidgetContainerView;
			if (view)
			{
				_mobileApplication.busy = true;
				initializeView(view);
			}
		}

		public function initializeActiveView():void
		{
			var view:WidgetContainerView = _mobileApplication.navigator.activeView as WidgetContainerView;
			if (view)
			{
				initializeView(view);

				if (_activeRecordAccount)
					_mobileApplication.busy = false;
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

		public function keyDownHandler(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.BACK:
					event.preventDefault();
					exitApplication("back key press");
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

		public function get mobileAppControllersMediator():MobileAppControllersMediator
		{
			return _mobileAppControllersMediator;
		}

		public function set mobileAppControllersMediator(value:MobileAppControllersMediator):void
		{
			_mobileAppControllersMediator = value;
		}

		public override function get applicationSettingsEmbeddedFile():Class
		{
			return _applicationSettingsEmbeddedFile;
		}

		protected override function get appControllersMediator():AppControllersMediatorBase
		{
			return _mobileAppControllersMediator;
		}

		override public function get currentFullView():String
		{
			// TODO: add support for reloading with the correct view
			return null;
		}
	}
}
