package collaboRhythm.mobile.controller
{
	import castle.flexbridge.reflection.Void;
	
	import collaboRhythm.mobile.view.WidgetContainerView;
	import collaboRhythm.workstation.controller.CollaborationMediatorBase;
	import collaboRhythm.workstation.controller.apps.WorkstationAppControllerBase;
	
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	
	import spark.components.View;
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
		
		public function deactivateView(view:WidgetContainerView):void
		{
			var app:WorkstationAppControllerBase = view.workstationAppController;
			app.widgetView = null;
		}
	}
}