package collaboRhythm.workstation.controller
{
	import castle.flexbridge.kernel.DefaultKernel;
	import castle.flexbridge.kernel.IKernel;
	
	import collaboRhythm.workstation.model.Settings;
	import collaboRhythm.workstation.model.User;
	import collaboRhythm.workstation.model.services.DefaultCurrentDateSource;
	import collaboRhythm.workstation.model.services.DemoCurrentDateSource;
	import collaboRhythm.workstation.model.services.ICurrentDateSource;
	import collaboRhythm.workstation.model.services.WorkstationKernel;
	import collaboRhythm.workstation.model.settings.ComponentLayout;
	import collaboRhythm.workstation.model.settings.WindowSettings;
	import collaboRhythm.workstation.model.settings.WindowSettingsDataStore;
	import collaboRhythm.workstation.model.settings.WindowState;
	import collaboRhythm.workstation.view.CollaborationRoomView;
	import collaboRhythm.workstation.view.RemoteUsersListView;
	import collaboRhythm.workstation.view.WorkstationCommandBarView;
	import collaboRhythm.workstation.view.spaces.CenterSpace;
	import collaboRhythm.workstation.view.spaces.LeftSpace;
	import collaboRhythm.workstation.view.spaces.RightSpace;
	import collaboRhythm.workstation.view.spaces.SingleWindowSpaceCombination;
	import collaboRhythm.workstation.view.spaces.TopSpace;
	
	import com.daveoncode.logging.LogFileTarget;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.DividedBox;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	
	import spark.components.Window;

	/**
	 * Top level controller for the whole application. Responsible for creating and managing the windows of the application. 
	 */
	public class WorkstationController extends ApplicationControllerBase
	{
		public function WorkstationController()
		{
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onExiting);
		}
		
		import collaboRhythm.workstation.view.WorkstationWindow;
		
		import flash.events.KeyboardEvent;
		
		import mx.core.IVisualElementContainer;
		
		private var _windows:Vector.<WorkstationWindow> = new Vector.<WorkstationWindow>();
		private var _primaryWindow:WorkstationWindow;
		private var _topSpace:TopSpace;
		private var _centerSpace:CenterSpace;
		private var _leftSpace:LeftSpace;
		private var _rightSpace:RightSpace;
		private var _fullContainer:IVisualElementContainer;
		private var _widgetsContainer:IVisualElementContainer;
		private var _scheduleWidgetContainer:IVisualElementContainer;
		private var _fullScreen:Boolean = true;
		private var _zoom:Number = 0;
		private var _resetingWindows:Boolean = false;
		
		public function get topSpace():TopSpace
		{
			return _topSpace;
		}
		
		public function get resetingWindows():Boolean
		{
			return _resetingWindows;
		}

		public function set resetingWindows(value:Boolean):void
		{
			_resetingWindows = value;
		}

		public function get windows():Vector.<WorkstationWindow>
		{
			return _windows;
		}

		public function set windows(value:Vector.<WorkstationWindow>):void
		{
			_windows = value;
		}

		public function get zoom():Number
		{
			return _zoom;
		}

		public function set zoom(value:Number):void
		{
			_zoom = value;
			applyZoom();
		}
		
		private function applyZoom():void
		{
//			var scale:Number = 1 + (0.1 * _zoom * Math.abs(_zoom));
			var scale:Number;
			
			if (isNaN(_zoom))
				scale = 1;
			else if (_zoom == -7)
			{
				scale = 2.0 / 3;
			}
			else
			{
				scale = 1 + (0.05 * _zoom);
			}
			
			for each (var window:WorkstationWindow in _windows)
			{
				for (var i:int = 0; i < window.numElements; i++)
				{
					var child:IUIComponent = window.getElementAt(i) as IUIComponent;
					if (child != null)
					{
						child.scaleX = scale;
						child.scaleY = scale;
					}
				}
			}
		}

		public function get workstationCommandBarView():WorkstationCommandBarView
		{
			return _topSpace.workstationCommandBarView;
		}

		public override function get remoteUsersView():RemoteUsersListView
		{
			return _centerSpace.remoteUsersView;
		}
		
		public override function get collaborationRoomView():CollaborationRoomView
		{
			return _topSpace.collaborationRoomView;
		}

		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}

		public function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
			
			for each (var window:WorkstationWindow in _windows)
			{
				window.fullScreenEnabled = _fullScreen;
			}
		}

		public override function get widgetsContainer():IVisualElementContainer
		{
			return _widgetsContainer;
		}

		public override function get scheduleWidgetContainer():IVisualElementContainer
		{
			return _scheduleWidgetContainer;
		}
		
		public override function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public function get primaryWindow():WorkstationWindow
		{
			return _primaryWindow;
		}

		public function main():void  
		{
			initLogging();
			logger.info("Logging initialized");
			
			_settings = new Settings();
			logger.info("Settings initialized");

			initializeComponents();
			logger.info("Components initialized");
			
			initializeWindows();
			logger.info("Windows initialized");
		}
		
		private function initializeWindows():void
		{
			var resetWindowSettings:Boolean = settings.resetWindowSettings;
			
			var windowSettings:WindowSettings;
			
			if (!resetWindowSettings)
			{
				windowSettings = readWindowSettings();
				resetWindowSettings = !validateWindowSettings(windowSettings);
			}
			
			if (resetWindowSettings)
				createWindowsForScreens();
			else
				createWindows(windowSettings);
			
			// TODO: handle less screens more gracefully
			if (_widgetsContainer == null)
			{
				// share the same container for widgets
				_widgetsContainer = _fullContainer;
			}
			
			_collaborationMediator = new CollaborationMediator(this);
		}
		
		private function resetWindows():void
		{
			// TODO: reset but preserve all existing spaces/components (move them instead of recreating them)
			
			settings.resetWindowSettings = true;
			_resetingWindows = true;
			for each (var window:WorkstationWindow in _windows)
			{
				window.close();
			}
			_resetingWindows = false;

			_windows = new Vector.<WorkstationWindow>();
			_primaryWindow = null;
			_topSpace = null;
			_centerSpace = null;
			_leftSpace = null;
			_rightSpace = null;
			_fullContainer = null;
			_widgetsContainer = null;
			
			initializeWindows();
		}
		
		public function initializeWindowCommon(window:WorkstationWindow):void
		{
			window.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function createWindowsForScreens():void
		{
			// Create a window for each of the screens
			var screenNum:Number = 0;
			if (Screen.screens.length == 1 || settings.useSingleScreen)
			{
				var window:WorkstationWindow = createWorkstationWindow();
				window.initializeForScreen(Screen.screens[0]);
				initializeWindowCommon(window);
				addSingleWindowSpaceCombination(window);
			}
			else
			{
				for each (var screen:Screen in Screen.screens)
				{
					if (screenNum >= 0 && screenNum <= 3)
					{
						window = createWorkstationWindow();
						window.initializeForScreen(screen);
						initializeWindowCommon(window);
						
						if (screenNum == 0)
						{
							addTopSpace(window);
						}
						else if (screenNum == 1)
						{
							addCenterSpace(window);
						}
						else if (screenNum == 2)
						{
							addRightSpace(window);
						}
						else if (screenNum == 3)
						{
							addLeftSpace(window);
						}
					}
					screenNum += 1;
				}
			}
		}
		
		private function validateWindowSettings(windowSettings:WindowSettings):Boolean
		{
			if (windowSettings == null || windowSettings.windowStates.length == 0)
				return false;
			
			var topSpaceFound:Boolean;
			var centerSpaceFound:Boolean;
			var leftSpaceFound:Boolean;
			var rightSpaceFound:Boolean;
			var singleWindowSpaceCombinationFound:Boolean;
			
			for each (var windowState:WindowState in windowSettings.windowStates)
			{
				for each (var spaceId:String in windowState.spaces)
				{
					if (spaceId == "topSpace")
						topSpaceFound = true;
					else if (spaceId == "centerSpace")
						centerSpaceFound = true;
					else if (spaceId == "leftSpace")
						leftSpaceFound = true;
					else if (spaceId == "rightSpace")
						rightSpaceFound = true;
					else if (spaceId == "singleWindowSpaceCombination")
						singleWindowSpaceCombinationFound = true;
				}
			}
			
			// if less than 4 screens, the left and right are considered optional
			if (singleWindowSpaceCombinationFound && !topSpaceFound && !centerSpaceFound && !leftSpaceFound && !rightSpaceFound)
				return true;
			else if (singleWindowSpaceCombinationFound)
				return false;
			else if (Screen.screens.length > 3)
				return (topSpaceFound && centerSpaceFound && leftSpaceFound && rightSpaceFound);
			else
				return (topSpaceFound && centerSpaceFound);
		}

		private function createWindows(windowSettings:WindowSettings):void
		{
			fullScreen = windowSettings.fullScreen;

			for each (var windowState:WindowState in windowSettings.windowStates)
			{
				// only restore the window if it contains one of the known "spaces"
				if (windowState.spaces.length > 0)
				{
					var window:WorkstationWindow = createWorkstationWindow();
					window.initializeForWindowState(windowState);
					initializeWindowCommon(window);
					
					// TODO: if more than one space is in a window, use a HDividedBox to contain them
					for each (var spaceId:String in windowState.spaces)
					{
						if (spaceId == "topSpace")
							addTopSpace(window);
						else if (spaceId == "centerSpace")
							addCenterSpace(window);
	//					else if (spaceId == "leftSpace")
	//						addLeftSpace(window);
	//					else if (spaceId == "rightSpace")
	//						addRightSpace(window);
						else if (spaceId == "singleWindowSpaceCombination")
							addSingleWindowSpaceCombination(window);
					}
					layoutComponentsFromSettings(windowState.componentLayouts, window);
				}
			}

			zoom = windowSettings.zoom;

			// TODO: if the required containers were not created, add them now
			if (_fullContainer == null)
				throw new Error("The required primary container was not created after creating windows from the settings file");
			if (_widgetsContainer == null)
				throw new Error("The required widgets container was not created after creating windows from the settings file");
		}
		
		public function createWorkstationWindow():WorkstationWindow
		{
			var window:WorkstationWindow = new WorkstationWindow();
			window.addEventListener(Event.CLOSING, windw_closingHandler);
			window.fullScreenEnabled = _fullScreen;
			_windows.push(window);
			return window;
		}
		
		public function windw_closingHandler(event:Event):void
		{
			//			trace("onClosing for " + this.toString());
			
			if (!_resetingWindows)
			{
				// Exit the application when any window is closed.
				// Note that we dispatch an exiting event but not a window closing event.
				// The exiting event handler will take care of any saving and cleanup operations.
				var exitingEvent:Event = new Event(Event.EXITING, false, true); 
				NativeApplication.nativeApplication.dispatchEvent(exitingEvent); 
				if (!exitingEvent.isDefaultPrevented())
				{
					NativeApplication.nativeApplication.exit(); 
				}
			}
		}
		
		private function addTopSpace(window:WorkstationWindow):void
		{
			if (_topSpace != null)
				throw new Error("topSpace was already initialized when trying to add a new topSpace");
			
			_topSpace = new TopSpace();
			_topSpace.id = "topSpace";
			_widgetsContainer = _topSpace.widgetsContainer;
			_scheduleWidgetContainer = _topSpace.scheduleWidgetContainer;
			window.addSpace(_topSpace);

			_primaryWindow = window;
		}
		
		private function addCenterSpace(window:WorkstationWindow):void
		{
			if (_centerSpace != null)
				throw new Error("centerSpace was already initialized when trying to add a new centerSpace");
			
			_centerSpace = new CenterSpace();
			_centerSpace.id = "centerSpace";
			_fullContainer = _centerSpace.fullContainer;
			window.addSpace(_centerSpace);
		}

		private function addLeftSpace(window:WorkstationWindow):void
		{
			if (_leftSpace != null)
				throw new Error("leftSpace was already initialized when trying to add a new leftSpace");
			
			_leftSpace = new LeftSpace();
			_leftSpace.id = "leftSpace";
			window.addSpace(_leftSpace);
		}
		
		private function addRightSpace(window:WorkstationWindow):void
		{
			if (_rightSpace != null)
				throw new Error("rightSpace was already initialized when trying to add a new rightSpace");
			
			_rightSpace = new RightSpace();
			_rightSpace.id = "rightSpace";
			window.addSpace(_rightSpace);
		}
		
		private function addSingleWindowSpaceCombination(window:WorkstationWindow):void
		{
			if (_rightSpace != null)
				throw new Error("rightSpace was already initialized when trying to add a new rightSpace");
			if (_leftSpace != null)
				throw new Error("leftSpace was already initialized when trying to add a new leftSpace");
			if (_centerSpace != null)
				throw new Error("centerSpace was already initialized when trying to add a new centerSpace");
			if (_topSpace != null)
				throw new Error("topSpace was already initialized when trying to add a new topSpace");
			
			var combination:SingleWindowSpaceCombination = new SingleWindowSpaceCombination();
			combination.id = "singleWindowSpaceCombination";
			window.addSpace(combination);
			
			_topSpace = combination.topSpace;
			_centerSpace = combination.centerSpace;
//			_leftSpace = combination.leftSpace;
//			_rightSpace = combination.rightSpace;
			_widgetsContainer = _topSpace.widgetsContainer;
			_scheduleWidgetContainer = _topSpace.scheduleWidgetContainer;
			_fullContainer = _centerSpace.fullContainer;
		}
		
		private function onKeyUp(event:KeyboardEvent):void 
		{
			// If the user presses escape, close the entire application
			if (event.keyCode == Keyboard.ESCAPE)
			{
				applicationExit();
			}
			else if (event.keyCode == Keyboard.F11)
			{
				fullScreen = !fullScreen;
			}
			if (event.ctrlKey && !event.altKey)
			{
				if (event.keyCode == Keyboard.EQUAL)
				{
					changeZoom(1);
				}
				else if (event.keyCode == Keyboard.MINUS)
				{
					changeZoom(-1);
				}
				else if (event.keyCode == Keyboard.NUMBER_0)
				{
					zoom = 0;
				}
				else if (event.keyCode == Keyboard.L)
				{
					testLogging();
				}
			}
			else if (event.ctrlKey && event.altKey)
			{
				if (event.keyCode == Keyboard.NUMBER_0)
				{
					zoom = -7;
				}
				else if (event.keyCode == Keyboard.NUMBER_1)
				{
					_settings.useSingleScreen = true;
					resetWindows();
				}
				else if (event.keyCode == Keyboard.NUMBER_2)
				{
					_settings.useSingleScreen = false;
					resetWindows();
				}
			}
			else if (event.keyCode == Keyboard.F1)
			{
				targetDate = new Date("2010/1/13");
			}
			else if (event.keyCode == Keyboard.F2)
			{
				targetDate = new Date("2010/1/14");
			}
			else if (event.keyCode == Keyboard.F3)
			{
				targetDate = new Date("2010/2/4");
			}
			else if (event.keyCode == Keyboard.F4)
			{
				targetDate = new Date("2010/2/17");
			}
			else if (event.keyCode == Keyboard.F5)
			{
				targetDate = null;
			}
		}
		
		private function changeZoom(zoomDelta:Number):void
		{
			zoom += zoomDelta;
		}	
		
		// Close the entire application, sending out an event to any processes that might want to interrupt the closing
		private function applicationExit():void 
		{
			var exitingEvent:Event = new Event(Event.EXITING, false, true); 
			NativeApplication.nativeApplication.dispatchEvent(exitingEvent); 
			if (!exitingEvent.isDefaultPrevented())
			{
				NativeApplication.nativeApplication.exit(); 
			} 
		}
		
		// Close each of the windows in the application, and do any cleanup for the application after that
		private function onExiting(exitingEvent:Event):void 
		{ 
			for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows)
			{
				window.close(); 
			} 
			
			_collaborationMediator.cancelAllCollaborations();
			saveWindowSettings();
		}
		
		private function saveWindowSettings():void
		{
			var windowSettings:WindowSettings = new WindowSettings();
			windowSettings.fullScreen = fullScreen;
			windowSettings.zoom = zoom;
			for each (var window:WorkstationWindow in _windows)
			{
				var windowState:WindowState = new WindowState();
				windowState.bounds = window.stage.nativeWindow.bounds;
				windowState.displayState = window.displayState;
				
				// Note that WindowState has no fullScreen property because
				// we track this property application-wide instead of on a per-window basis.
				
				for each (var component:UIComponent in window.spaces)
				{
					if (component.id != null)
					{
						windowState.spaces.push(component.id);
					}
				}
				
				addComponentLayoutsFromWindow(window, windowState.componentLayouts);
				
				windowSettings.windowStates.push(windowState);
			}
			
			var windowSettingsDataStore:WindowSettingsDataStore = new WindowSettingsDataStore();
			windowSettingsDataStore.saveWindowSettings(windowSettings);
		}
		
		private function addComponentLayoutsFromWindow(window:WorkstationWindow, componentLayouts:Vector.<ComponentLayout>):void
		{
			addComponentLayoutsFromContainerRecursive(window, componentLayouts);
		}

		private function addComponentLayoutsFromContainerRecursive(container:UIComponent, componentLayouts:Vector.<ComponentLayout>):void
		{
			// first add the ComponentLayout for this container if appropriate
			if (container != null && container.id != null && !isNaN(container.percentWidth) && !isNaN(container.percentHeight) && container.parent is DividedBox)
			{
				componentLayouts.push(new ComponentLayout(container.id, container.percentWidth, container.percentHeight));
			}
			
			// now act recursively on any children
			var displayObjectContainer:DisplayObjectContainer = container;
			var visualElementContainer:IVisualElementContainer = container as IVisualElementContainer;
			
			if (visualElementContainer != null)
			{
				for (i = 0; i < visualElementContainer.numElements; i++)
				{
					var visualElement:IVisualElement = visualElementContainer.getElementAt(i);
					addComponentLayoutsFromContainerRecursive(visualElement as UIComponent, componentLayouts);
				}
			}
			else if (displayObjectContainer != null)
			{
				for (var i:int = 0; i < displayObjectContainer.numChildren; i++)
				{
					var displayObject:DisplayObject = displayObjectContainer.getChildAt(i);
					addComponentLayoutsFromContainerRecursive(displayObject as UIComponent, componentLayouts);
				}
			}
		}
		
		private function layoutComponentsFromSettings(componentLayouts:Vector.<ComponentLayout>, window:WorkstationWindow):void
		{
			for each (var componentLayout:ComponentLayout in componentLayouts)
			{
				var component:UIComponent = findComponentById(window, componentLayout.id);
				if (component != null)
				{
					component.percentWidth = componentLayout.percentWidth;
					component.percentHeight = componentLayout.percentHeight;
				}
			}
		}
		
		private function findComponentById(window:WorkstationWindow, id:String):UIComponent
		{
			return findComponentByIdRecursive(window, id);
		}
		
		private function findComponentByIdRecursive(container:UIComponent, id:String):UIComponent
		{
			// first see if we have a match
			if (container != null && container.id != null && container.id == id)
			{
				return container;
			}
			
			// now act recursively on any children
			var displayObjectContainer:DisplayObjectContainer = container;
			var visualElementContainer:IVisualElementContainer = container as IVisualElementContainer;
			
			if (visualElementContainer != null)
			{
				for (i = 0; i < visualElementContainer.numElements; i++)
				{
					var visualElement:IVisualElement = visualElementContainer.getElementAt(i);
					var foundComponent:UIComponent = findComponentByIdRecursive(visualElement as UIComponent, id);
					if (foundComponent != null)
						return foundComponent;
				}
			}
			else if (displayObjectContainer != null)
			{
				for (var i:int = 0; i < displayObjectContainer.numChildren; i++)
				{
					var displayObject:DisplayObject = displayObjectContainer.getChildAt(i);
					foundComponent = findComponentByIdRecursive(displayObject as UIComponent, id);
					if (foundComponent != null)
						return foundComponent;
				}
			}
			
			return null;
		}

		private function readWindowSettings():WindowSettings
		{
			var windowSettingsDataStore:WindowSettingsDataStore = new WindowSettingsDataStore();
			var windowSettings:WindowSettings = windowSettingsDataStore.readWindowSettings();
			return windowSettings;
		}
	}
}