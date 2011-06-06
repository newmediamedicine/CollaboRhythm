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
package collaboRhythm.workstation.view 
{
	import collaboRhythm.workstation.model.settings.WindowState;
	
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowResize;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Screen;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
    import flash.geom.Rectangle;
    import flash.ui.Keyboard;
	
	import mx.core.Container;
	import mx.core.UIComponent;
	import mx.events.AIREvent;
    import mx.events.FlexEvent;
    import mx.events.ResizeEvent;
	
	import spark.components.*;
	import spark.layouts.BasicLayout;
	import spark.layouts.TileLayout;
    import spark.primitives.Rect;
    import spark.skins.spark.SparkChromeWindowedApplicationSkin;
	import spark.skins.spark.WindowedApplicationSkin;

	
	public class WorkstationWindow extends Window
	{
		private var _fullScreenEnabled:Boolean = false;
		private var _displayState:String = NativeWindowDisplayState.NORMAL;
        private var _windowView:UIComponent;
		private var _spaces:Vector.<UIComponent> = new Vector.<UIComponent>();
		
		public function WorkstationWindow()
		{
            addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
			super();
			setStyle("skinClass", WindowedApplicationSkin);
			setStyle("backgroundColor", 0xFFFFFF);
			this.showStatusBar = false;
			this.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, displayStateChangeHandler);
			this.addEventListener(ResizeEvent.RESIZE, resizeHandler);
		}

        private function creationCompleteHandler(event:FlexEvent):void
        {
            systemManager.stage.nativeWindow.addEventListener(
               NativeWindowBoundsEvent.RESIZE, window_resizeHandler);
        }

        private function window_resizeHandler(event:NativeWindowBoundsEvent):void
        {
            if (event.beforeBounds.equals(event.afterBounds))
            {
                event.preventDefault();
                event.stopImmediatePropagation();
            }
        }
		
		private function resizeHandler(event : ResizeEvent) : void
		{
			if (this.stage != null && !this.closed)
			{
				this.width = this.stage.stageWidth;
				this.height = this.stage.stageHeight;
			}
		}
		
		public function get spaces():Vector.<UIComponent>
		{
			return _spaces;
		}

		public function get displayState():String
		{
			return _displayState;
		}

		public function get isMinimized():Boolean
		{
			return _displayState == NativeWindowDisplayState.MINIMIZED;
		}

		public function get isMaximized():Boolean
		{
			return _displayState == NativeWindowDisplayState.MAXIMIZED;
		}

		public function displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void
		{
			_displayState = event.afterDisplayState;
		}
		
		public function initializeForScreen(currentScreen:Screen):void
		{
            var bounds:Rectangle = currentScreen.bounds;
            initializeFromBounds(bounds);
		}
		
		public function initializeForWindowState(windowState:WindowState):void
		{
            var bounds:Rectangle = windowState.bounds;
            initializeFromBounds(bounds);
//			this.open(true);
//			this.stage.nativeWindow.bounds = windowState.bounds;
//
//			// Fix the size. For some reason, the height and width of the Window are not getting updated to match the stage when the window is first created.
//			this.width = this.stage.stageWidth;
//			this.height = this.stage.stageHeight;
//
//
//			if (fullScreenEnabled)
//			{
//				this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
//			}
//			else
//			{
//				if (windowState.isMaximized)
//					this.maximize();
//
//				// don't start the window minimized (even if it was minimized before) because it would be confusing for the user
//			}
		}

        public function initializeFromBounds(bounds:Rectangle):void
        {
			this.open(true);
			this.move(bounds.x, bounds.y);
            this.bounds = bounds;

			if (fullScreenEnabled)
			{
				this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
			else
			{
				this.maximize();
			}
        }
		
		public function get fullScreenEnabled():Boolean
		{
			return _fullScreenEnabled;
		}

		public function set fullScreenEnabled(value:Boolean):void
		{
			_fullScreenEnabled = value;
			
			if (this.stage != null)
			{
				if (_fullScreenEnabled)
					this.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				else
					this.stage.displayState = StageDisplayState.NORMAL;
			}
		}

		public function addSpace(space:UIComponent):void
		{
			this.spaces.push(space);
			this.addElement(space);
		}

        public function get windowView():UIComponent
        {
            return _windowView;
        }

        public function set windowView(value:UIComponent):void
        {
            _windowView = value;
        }
    }
}