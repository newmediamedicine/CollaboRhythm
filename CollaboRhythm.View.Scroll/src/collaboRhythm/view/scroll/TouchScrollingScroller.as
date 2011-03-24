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
package collaboRhythm.view.scroll
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;

	import spark.components.Group;
	import spark.components.Scroller;
	import spark.core.IViewport;
	import spark.effects.Fade;

	/**
	 * Scroller component with the addition of touch scrolling. Click or touch in the content area and drag to scroll.
	 * If drag or touch ends while moving, scrolling will continue with inertia.
	 *  
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public class TouchScrollingScroller extends Scroller implements ITouchScrollerAdapter
	{
		private var _touchScroller:TouchScroller;
		private var _traceEventHandlers:Boolean = false;
		
		/**
		 *  @private
		 *  When touch scrolling is enabled, the selection is not
		 *  comitted immediately on mouse down, but we wait to see whether the user
		 *  intended to start a scroll gesture instead. In that case we postpone
		 *  comitting the selection untill mouse up, and only do so if
		 *  no scroll gesture occurred.
		 */
		private var pendingSelectionOnNoScroll:Boolean = true;
		
		private var pendingMouseDownEvent:MouseEvent;
		private var pendingMouseDownEventCurrentTarget:Object;
		
		private var previousVerticalScrollPolicy:String;
		private var previousHorizontalScrollPolicy:String;
		private var _verticalScrollBarFade:Fade
		private var _horizontalScrollBarFade:Fade
		private var _viewportX:Number = 0;
		private var _viewportY:Number = 0;
		
		//----------------------------------
		//  overlay container
		//----------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 *  The optional Group used as the parent for any other visual elements required by TouchScroller.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var overlayContainer:Group;
		
		[SkinPart(required="false")]
		public var viewportContainer:Group;
		
		public function TouchScrollingScroller()
		{
			super();
			
			_touchScroller = new TouchScroller(this);
			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
		}

		//----------------------------------
		//  viewport - default property
		//----------------------------------    
		
		private var _viewport:IViewport;
		
		/**
		 *  The viewport component to be scrolled.
		 * 
		 *  <p>
		 *  The viewport is added to the Scroller component's skin, 
		 *  which lays out both the viewport and scroll bars.
		 * 
		 *  When the <code>viewport</code> property is set, the viewport's 
		 *  <code>clipAndEnableScrolling</code> property is 
		 *  set to true to enable scrolling.
		 * 
		 *  The Scroller does not support rotating the viewport directly.  The viewport's
		 *  contents can be transformed arbitrarily, but the viewport itself cannot.
		 * </p>
		 * 
		 *  This property is Bindable.
		 * 
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override public function get viewport():IViewport
		{       
			return _viewport;
		}
		
		/**
		 *  @private
		 */
		override public function set viewport(value:IViewport):void
		{
			if (value == _viewport)
				return;
			
			uninstallViewport();
			_viewport = value;
			installViewport();
			dispatchEvent(new Event("viewportChanged"));
		}
		
		private function installViewport():void
		{
			if (viewportContainer && viewport)
			{
				viewport.clipAndEnableScrolling = true;
				viewportContainer.addElementAt(viewport, 0);
				viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
			}
			if (verticalScrollBar)
				verticalScrollBar.viewport = viewport;
			if (horizontalScrollBar)
				horizontalScrollBar.viewport = viewport;
		}
		
		private function uninstallViewport():void
		{
			if (horizontalScrollBar)
				horizontalScrollBar.viewport = null;
			if (verticalScrollBar)
				verticalScrollBar.viewport = null;        
			if (viewportContainer && viewport)
			{
				viewport.clipAndEnableScrolling = false;
				viewportContainer.removeElement(viewport);
				viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, viewport_propertyChangeHandler);
			}
		}
		
		private function viewport_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			switch(event.property) 
			{
				case "contentWidth": 
				case "contentHeight": 
					invalidateSkin();
					break;
			}
		}

		private function invalidateSkin():void
		{
			if (skin)
			{
				skin.invalidateSize();
				skin.invalidateDisplayList();
			}
		}

		/**
		 *  @private
		 */
		override protected function attachSkin():void
		{
			super.attachSkin();
			
			// undo super.installViewport(); which puts the viewport in the wrong place 
			if (skin && viewport)
			{
				Group(skin).removeElement(viewport);
			}
			
			installViewport();
		}
		
		/**
		 *  @private
		 */
		override protected function detachSkin():void
		{    
			uninstallViewport();

			super.detachSkin();
		}
		
		public function get viewportY():Number
		{
			return _viewportY;
		}

		public function set viewportY(value:Number):void
		{
//			value = 0;
			_viewportY = value;
			this.contentComponent.y = _viewportY;
		}

		public function get viewportX():Number
		{
			return _viewportX;
		}

		public function set viewportX(value:Number):void
		{
//			value = 0;
			_viewportX = value;
			this.contentComponent.x = _viewportX;
		}

		override protected function createChildren():void
		{
			super.createChildren();
			_touchScroller.createChildren();
		}
		
		override protected function keyUpHandler(event:KeyboardEvent):void
		{
			_touchScroller.keyUpHandler(event);
		}

//		override protected function updateDisplayList(w:Number, h:Number):void
//		{
//			super.updateDisplayList(w, h);
//			this.contentComponent.x = _viewportX;
//			this.contentComponent.y = _viewportY;
//		}
		
		public function get component():UIComponent
		{
			return this;
		}
		
		public function get componentContainer():UIComponent
		{
			return this.overlayContainer;
		}
		
		public function get panelWidth():Number
		{
			return this.width;
		}
		
		public function get panelHeight():Number
		{
			return this.height;
		}
		
		public function get scrollableAreaWidth():Number
		{
			return this.viewport.contentWidth;
		}
		
		public function get scrollableAreaHeight():Number
		{
			return this.viewport.contentHeight;
		}
		
		private function get contentComponent():IUIComponent
		{
			return viewportContainer as IUIComponent;
		}
		
		public function get contentPositionY():Number
		{
			return -this.viewport.verticalScrollPosition + viewportY;
		}
		
		public function set contentPositionY(value:Number):void
		{
			// round to avoid rendering artifacts which result from not snapping to pixel boundaries
			value = Math.round(value);
			
			var newVerticalScrollPosition:Number = -value;
			var constrainedVerticalScrollPosition:Number = Math.max(0, Math.min(newVerticalScrollPosition, scrollableAreaHeight - panelHeight));
			
			this.viewport.verticalScrollPosition = constrainedVerticalScrollPosition;
			var fraction:Number = newVerticalScrollPosition - constrainedVerticalScrollPosition;
			
			// make the scroll bars stay while the content moves off the edge
			viewportY = -fraction;
		}
		
		public function get contentPositionX():Number
		{
			return -this.viewport.horizontalScrollPosition + viewportX;
		}
		
		public function set contentPositionX(value:Number):void
		{
			// round to avoid rendering artifacts which result from not snapping to pixel boundaries
			value = Math.round(value);
			
			var newHorizontalScrollPosition:Number = -value;
			
			var beyondLeft:Number = -newHorizontalScrollPosition;
			var beyondRight:Number = newHorizontalScrollPosition - Math.max(0, (this.viewport.contentWidth - this.width));
			
			if (beyondLeft > 0)
			{
				viewportX = beyondLeft;
				newHorizontalScrollPosition += beyondLeft;
			}
			else if (beyondRight > 0)
			{
				viewportX = -beyondRight;
				newHorizontalScrollPosition -= beyondRight;
			}
			else
			{
				viewportX = 0;
			}
			
			this.viewport.horizontalScrollPosition = newHorizontalScrollPosition;
		}
		
		private function scrollStartHandler(event:Event):void
		{
			if (_traceEventHandlers)
				trace(this + ".scrollStartHandler");
			
			if (pendingSelectionOnNoScroll && pendingMouseDownEvent != null)
			{
				// fake a roll out event to remove highlight
				(pendingMouseDownEventCurrentTarget as IEventDispatcher).dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, false, false, pendingMouseDownEvent.localX, pendingMouseDownEvent.localY));
			}
			
			// ignore subsequent mouse events because user is scrolling (not selecting an item) 
			pendingSelectionOnNoScroll = false;
			pendingMouseDownEvent = null;
			pendingMouseDownEventCurrentTarget = null;
		}
		
		public function hideScrollBarV():void
		{
			if (this.verticalScrollBar != null && this.getStyle("verticalScrollPolicy") != "off")
			{
				if (this._verticalScrollBarFade != null && this._verticalScrollBarFade.isPlaying)
					this._verticalScrollBarFade.stop();
				
				previousVerticalScrollPolicy = this.getStyle("verticalScrollPolicy");
				this.setStyle("verticalScrollPolicy", "off");
				this.validateNow();
			}
		}
		
		public function hideScrollBarH():void
		{
			if (this.horizontalScrollBar != null && this.getStyle("horizontalScrollPolicy") != "off")
			{
				if (this._horizontalScrollBarFade != null && this._horizontalScrollBarFade.isPlaying)
					this._horizontalScrollBarFade.stop();
				
				previousHorizontalScrollPolicy = this.getStyle("horizontalScrollPolicy");
				this.setStyle("horizontalScrollPolicy", "off");
				this.validateNow();
			}
		}
		
		public function showScrollBarV():void
		{
			if (this.verticalScrollBar != null)
			{
				this.setStyle("verticalScrollPolicy", previousVerticalScrollPolicy);
				
				_verticalScrollBarFade = new Fade(this.verticalScrollBar);
				_verticalScrollBarFade.alphaFrom = 0;
				_verticalScrollBarFade.alphaTo = 1;
				_verticalScrollBarFade.play();
			}
		}
		
		public function showScrollBarH():void
		{
			if (this.horizontalScrollBar != null)
			{
				this.setStyle("horizontalScrollPolicy", previousHorizontalScrollPolicy);
				
				_horizontalScrollBarFade = new Fade(this.horizontalScrollBar);
				_horizontalScrollBarFade.alphaFrom = 0;
				_horizontalScrollBarFade.alphaTo = 1;
				_horizontalScrollBarFade.play();
			}
		}
		
		public function get useHorizontalTouchScrolling():Boolean
		{
			return _touchScroller.useHorizontalTouchScrolling;
		}
		
		public function set useHorizontalTouchScrolling(value:Boolean):void
		{
			_touchScroller.useHorizontalTouchScrolling = value;
		}
		
		public function get useVerticalTouchScrolling():Boolean
		{
			return _touchScroller.useVerticalTouchScrolling;
		}
		
		public function set useVerticalTouchScrolling(value:Boolean):void
		{
			_touchScroller.useVerticalTouchScrolling = value;
		}
	}
}