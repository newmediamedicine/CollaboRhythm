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
	
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.Group;
	import spark.components.IItemRenderer;
	import spark.components.List;
	import spark.effects.Fade;
	
	/**
	 * List component with the addition of touch scrolling. Click or touch in the content area and drag to scroll.
	 * If drag or touch ends while moving, scrolling will continue with inertia.
	 *  
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public class TouchScrollingList extends List implements ITouchScrollerAdapter
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
		
		public function TouchScrollingList()
		{
			super();
			
			_touchScroller = new TouchScroller(this);
			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
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
			return this.scroller.viewport.contentWidth;
		}
		
		public function get scrollableAreaHeight():Number
		{
			return this.scroller.viewport.contentHeight;
		}
		
		public function get contentPositionY():Number
		{
			return -this.scroller.viewport.verticalScrollPosition + this.scroller.y;
		}
		
		public function set contentPositionY(value:Number):void
		{
			var newVerticalScrollPosition:Number = -value;
			var constrainedVerticalScrollPosition:Number = Math.max(0, Math.min(newVerticalScrollPosition, scrollableAreaHeight - panelHeight));
			
			this.scroller.viewport.verticalScrollPosition = constrainedVerticalScrollPosition;
			var fraction:Number = newVerticalScrollPosition - constrainedVerticalScrollPosition;
			
			this.scroller.y = -fraction;

			// TODO: make the scroll bars stay while the content moves off the edge; neither of the following work
//				this.scroller.verticalScrollBar.y = -beyondTop;
//				(this.scroller.viewport as UIComponent).y = beyondTop;

		}
		
		public function get contentPositionX():Number
		{
			return -this.scroller.viewport.horizontalScrollPosition + this.scroller.x;
		}
		
		public function set contentPositionX(value:Number):void
		{
//			this.scroller.viewport.horizontalScrollPosition = -value;
			var newHorizontalScrollPosition:Number = -value;
			
			var beyondLeft:Number = -newHorizontalScrollPosition;
			var beyondRight:Number = newHorizontalScrollPosition - Math.max(0, (this.scroller.viewport.contentWidth - this.width));
			
			if (beyondLeft > 0)
			{
				this.scroller.x = beyondLeft;
				newHorizontalScrollPosition += beyondLeft;
			}
			else if (beyondRight > 0)
			{
				this.scroller.x = -beyondRight;
				newHorizontalScrollPosition -= beyondRight;
			}
			else
			{
				this.scroller.x = 0;
			}
			
			this.scroller.viewport.horizontalScrollPosition = newHorizontalScrollPosition;
		}
		
		override protected function item_mouseDownHandler(event:MouseEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".item_mouseDownHandler, ");

			if (pendingSelectionOnNoScroll && pendingMouseDownEvent != null)
			{
				pendingMouseDownEvent = null;
				super.item_mouseDownHandler(event);
			}
			else
			{
				// Handle the fixup of selection
				var newIndex:int
				if (event.currentTarget is IItemRenderer)
					newIndex = IItemRenderer(event.currentTarget).itemIndex;
				else
					newIndex = dataGroup.getElementIndex(event.currentTarget as IVisualElement);
				
				if (!allowMultipleSelection)
				{
					// Single selection case, set the selectedIndex 
					var currentRenderer:IItemRenderer;
					if (caretIndex >= 0)
					{
						currentRenderer = dataGroup.getElementAt(caretIndex) as IItemRenderer;
						if (currentRenderer)
							currentRenderer.showsCaret = false;
					}
				}
				
				// note that we don't set pendingSelectionOnNoScroll = true here because scrollStartHandler may occur before OR after item_mouseDownHandler
				pendingMouseDownEvent = event;
				pendingMouseDownEventCurrentTarget = event.currentTarget;
				
//				systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler, false, 0, true);
				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			}
		}
		
		override protected function mouseUpHandler(event:Event):void
		{
			if (_traceEventHandlers)
				trace(this + ".mouseUpHandler");
			
			if (pendingSelectionOnNoScroll && pendingMouseDownEvent != null)
			{
				// fake mouse down event which can now be handled by the List class to select the item
				(pendingMouseDownEventCurrentTarget as IEventDispatcher).dispatchEvent(pendingMouseDownEvent); 
				super.mouseUpHandler(event);
			}
			
			pendingSelectionOnNoScroll = true;
			pendingMouseDownEvent = null;
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
			if (this.scroller.verticalScrollBar != null && this.scroller.getStyle("verticalScrollPolicy") != "off")
			{
				if (this._verticalScrollBarFade != null && this._verticalScrollBarFade.isPlaying)
					this._verticalScrollBarFade.stop();

				previousVerticalScrollPolicy = this.scroller.getStyle("verticalScrollPolicy");
				this.scroller.setStyle("verticalScrollPolicy", "off");
				this.scroller.validateNow();
			}
		}
		
		public function hideScrollBarH():void
		{
			if (this.scroller.horizontalScrollBar != null && this.scroller.getStyle("horizontalScrollPolicy") != "off")
			{
				if (this._horizontalScrollBarFade != null && this._horizontalScrollBarFade.isPlaying)
					this._horizontalScrollBarFade.stop();
				
				previousHorizontalScrollPolicy = this.scroller.getStyle("horizontalScrollPolicy");
				this.scroller.setStyle("horizontalScrollPolicy", "off");
				this.scroller.validateNow();
			}
		}
		
		public function showScrollBarV():void
		{
			if (this.scroller.verticalScrollBar != null)
			{
				// TODO: a fix such as the one below (commented out) may or may not resolve issues with the horizontal scroll bar flickering on for a frame then back off
//				var preventOtherScrollFlicker:Boolean;
//				if (this.scroller.getStyle("horizontalScrollPolicy") == "auto")
//				{
//					this.scroller.setStyle("horizontalScrollPolicy", "off");
//					preventOtherScrollFlicker = true;
//				}
				
				this.scroller.setStyle("verticalScrollPolicy", previousVerticalScrollPolicy);
				
//				if (preventOtherScrollFlicker)
//				{
//					this.scroller.validateNow();
//					this.scroller.setStyle("horizontalScrollPolicy", "auto");
//				}

				_verticalScrollBarFade = new Fade(this.scroller.verticalScrollBar);
				_verticalScrollBarFade.alphaFrom = 0;
				_verticalScrollBarFade.alphaTo = 1;
				_verticalScrollBarFade.play();
			}
		}
		
		public function showScrollBarH():void
		{
			if (this.scroller.horizontalScrollBar != null)
			{
				this.scroller.setStyle("horizontalScrollPolicy", previousHorizontalScrollPolicy);

				_horizontalScrollBarFade = new Fade(this.scroller.horizontalScrollBar);
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