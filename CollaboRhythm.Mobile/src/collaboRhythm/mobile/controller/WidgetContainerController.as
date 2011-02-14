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
	import collaboRhythm.core.pluginsManagement.PluginEvent;
	import collaboRhythm.mobile.view.WidgetContainerView;
	import collaboRhythm.core.controller.CollaborationMediatorBase;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import flash.events.TransformGestureEvent;
	
	import spark.components.ViewNavigator;
	import spark.effects.SlideViewTransition;

	public class WidgetContainerController
	{
		private var _navigator:ViewNavigator;
		private var _collaborationMediator:CollaborationMediatorBase;
		
		public function WidgetContainerController(navigator:ViewNavigator, collaborationMediator:CollaborationMediatorBase)
		{
			_navigator = navigator;
			_collaborationMediator = collaborationMediator;
		}

		public function get widgetNavigationIndex():int
		{
			return _navigator.navigationStack.length - 1;
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
			if (_collaborationMediator.appControllersMediator && widgetNavigationIndex > 0)
			{
				navigator.popView(new SlideViewTransition(300, SlideViewTransition.SLIDE_RIGHT));
				
				return true;
			}
			else
				return false;
		}

		public function pushView():Boolean
		{
			if (_collaborationMediator.appControllersMediator && widgetNavigationIndex + 1 < _collaborationMediator.appControllersMediator.workstationApps.length)
			{
				navigator.pushView(WidgetContainerView, null,
					new SlideViewTransition( 300, SlideViewTransition.SLIDE_LEFT));
				
				return true;
			}
			else
				return false;
		}
		
		public function initializeView(view:WidgetContainerView):void
		{
			// FIXME: occasionally I get the following compile error; casting as WidgetContainerController does not help; clean or otherwise rebuilding the project generally resolved the error
			// 1067: Implicit coercion of a value of type collaboRhythm.mobile.controller:WidgetContainerController to an unrelated type collaboRhythm.mobile.controller:WidgetContainerController.
			view.controller = this;
			view.addEventListener(PluginEvent.RELOAD_REQUEST, view_reloadRequestHandler);

			if (_collaborationMediator.appControllersMediator && widgetNavigationIndex >= 0 && widgetNavigationIndex < _collaborationMediator.appControllersMediator.workstationApps.length)
			{
				var app:WorkstationAppControllerBase = _collaborationMediator.appControllersMediator.workstationApps.getValueByIndex(widgetNavigationIndex);
				view.workstationAppController = app;
				if (app)
				{
//					trace("initializeView with app", app.name);
					view.title = app.name;
					app.widgetParentContainer = view;
					app.createAndPrepareWidgetView();
					app.widgetView.percentWidth = 100;
					app.widgetView.percentHeight = 100;
//					app.initialize();
					app.showWidget();
				}
			}
		}
		
		public function view_reloadRequestHandler(event:PluginEvent):void
		{
			_collaborationMediator.reloadPlugins();
		}
		
		public function deactivateView(view:WidgetContainerView):void
		{
			view.removeEventListener(PluginEvent.RELOAD_REQUEST, view_reloadRequestHandler);
			var app:WorkstationAppControllerBase = view.workstationAppController;
			// TODO: perhaps only the widget/mobile view should be destroyed here?
			app.destroyViews();
		}
		
		public function toggleMenu(view:WidgetContainerView):void
		{
			view.toggleMenu();
		}
	}
}