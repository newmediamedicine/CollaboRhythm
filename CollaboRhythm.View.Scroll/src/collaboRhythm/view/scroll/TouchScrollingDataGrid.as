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
	import flash.events.*;
	
	import mx.collections.ICollectionView;
	import mx.core.UIComponent;
	import mx.effects.Resize;
	
	import spark.effects.Fade;

	/**
	 * DataGrid component with the addition of touch scrolling. Click or touch in the content area and drag to scroll.
	 * If drag or touch ends while moving, scrolling will continue with inertia.
	 * 
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public class TouchScrollingDataGrid extends SmoothScrollingDataGrid implements ITouchScrollerAdapter
	{
		private var _touchScroller:TouchScroller;
		private var _previousScrollBarVWidth:Number;
		private var _previousScrollBarHHeight:Number;
		private var _verticalScrollBarResize:Resize;
		private var _verticalScrollBarFade:Fade
		private var _horizontalScrollBarResize:Resize;
		private var _horizontalScrollBarFade:Fade
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
		
		public function TouchScrollingDataGrid()
		{
			super();
			
			_touchScroller = new TouchScroller(this);
			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
			_touchScroller.addEventListener(TouchScrollerEvent.SCROLL_ABORT, scrollAbortHandler);
			
			verticalScrollPosition = 1;
			verticalScrollPosition = 0;
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
			return this;
		}
		
		public function get panelWidth():Number
		{
			return this.width;
		}

		public function get panelHeight():Number
		{
			return this.scrollAreaHeight;
		}
		
		public function get scrollableAreaWidth():Number
		{
			return listContent.width;
		}

		public function get scrollableAreaHeight():Number
		{
			return ((this.dataProvider as ICollectionView).length) * rowHeight;
		}
		
		public function get contentPositionY():Number
		{
			return -fractionalVerticalScrollPosition * rowHeight;
		}
		
		public function set contentPositionY(value:Number):void
		{
			var newVerticalScrollPosition:Number = -value / rowHeight;
			
			fractionalVerticalScrollPosition = newVerticalScrollPosition;
		}

		public function get contentPositionX():Number
		{
			return listContent.x - viewMetrics.left - listContent.leftOffset;
		}
		
		public function set contentPositionX(value:Number):void
		{
			// round to avoid rendering artifacts which result from not snapping to pixel boundaries
			value = Math.round(value);

			listContent.x = value + viewMetrics.left + listContent.leftOffset;
		}

		private function get traceInstanceDescription():String
		{
			var componentString:String = (Object(this)).toString();
			var componentParts:Array = componentString.split(".");
			return componentParts[componentParts.length - 1];
		}
		
		override protected function mouseDownHandler(event:MouseEvent):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".mouseDownHandler");
			
			if ((pendingSelectionOnNoScroll && pendingMouseDownEvent != null) || !_touchScroller.isTouchScrollerEvent(event))
			{
				pendingMouseDownEvent = null;
				super.mouseDownHandler(event);
			}
			else
			{
				// note that we don't set pendingSelectionOnNoScroll = true here because scrollStartHandler may occur before OR after item_mouseDownHandler
				pendingMouseDownEvent = event;
				pendingMouseDownEventCurrentTarget = event.target;

				systemManager.getSandboxRoot().addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 0, true);
			}
		}

		override protected function mouseUpHandler(event:MouseEvent):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".mouseUpHandler, currentTarget: " + event.target + ", this: " + this);
			
			if (pendingSelectionOnNoScroll && pendingMouseDownEvent != null)
			{
				// fake mouse down event which can now be handled by the List class to select the item
				(pendingMouseDownEventCurrentTarget as IEventDispatcher).dispatchEvent(pendingMouseDownEvent); 
				super.mouseUpHandler(event);
			}
			else if (!_touchScroller.isTouchScrollerEvent(event))
			{
				super.mouseUpHandler(event);
			}
			
			pendingSelectionOnNoScroll = true;
			pendingMouseDownEvent = null;

			systemManager.getSandboxRoot().removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function scrollStartHandler(event:Event):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".scrollStartHandler");

			ignorePendingMouseDownEvent();
		}
		
		private function scrollAbortHandler(event:Event):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".scrollAbortHandler");

			ignorePendingMouseDownEvent();
		}
		
		private function ignorePendingMouseDownEvent():void
		{
			if (pendingSelectionOnNoScroll && pendingMouseDownEvent != null)
			{
				// fake a mouse out event to remove highlight (note that DataGrid needs a MOUSE_OUT event, unlike a List which needs a ROLL_OUT)
				(pendingMouseDownEventCurrentTarget as IEventDispatcher).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, -1, -1));
			}
			
			// ignore subsequent mouse events because user is scrolling (not selecting an item) 
			pendingSelectionOnNoScroll = false;
			pendingMouseDownEvent = null;
			pendingMouseDownEventCurrentTarget = null;
		}
		
		public function hideScrollBarV():void
		{
			if (this.verticalScrollBar != null)
			{
				if (this._verticalScrollBarFade != null && this._verticalScrollBarFade.isPlaying)
					this._verticalScrollBarFade.stop();
				if (this._verticalScrollBarResize != null && this._verticalScrollBarResize.isPlaying)
					this._verticalScrollBarResize.stop();
				else
				{
					if (this.verticalScrollBar.width > 0)
						_previousScrollBarVWidth = this.verticalScrollBar.width;
				}
				
				this.verticalScrollBar.width = 0;
				this.verticalScrollBar.alpha = 0;
			}
		}
		
		public function hideScrollBarH():void
		{
			if (this.horizontalScrollBar != null)
			{
				if (this._horizontalScrollBarFade != null && this._horizontalScrollBarFade.isPlaying)
					this._horizontalScrollBarFade.stop();
				if (this._horizontalScrollBarResize != null && this._horizontalScrollBarResize.isPlaying)
					this._horizontalScrollBarResize.stop();
				else
				{
					if (this.horizontalScrollBar.height > 0)
						_previousScrollBarHHeight = this.horizontalScrollBar.height;
				}
				
				this.horizontalScrollBar.height = 0;
				this.horizontalScrollBar.alpha = 0;
			}
		}
		
		public function showScrollBarV():void
		{
			if (this.verticalScrollBar != null)
			{
				_verticalScrollBarFade = new Fade(this.verticalScrollBar);
				_verticalScrollBarFade.alphaFrom = 0;
				_verticalScrollBarFade.alphaTo = 1;
				_verticalScrollBarFade.play();
				
				_verticalScrollBarResize = new Resize(this.verticalScrollBar);
				_verticalScrollBarResize.widthFrom = 0;
				_verticalScrollBarResize.widthTo = _previousScrollBarVWidth;
				_verticalScrollBarResize.play();
			}
		}
		
		public function showScrollBarH():void
		{
			if (this.horizontalScrollBar != null)
			{
				_horizontalScrollBarFade = new Fade(this.horizontalScrollBar);
				_horizontalScrollBarFade.alphaFrom = 0;
				_horizontalScrollBarFade.alphaTo = 1;
				_horizontalScrollBarFade.play();
				
				_horizontalScrollBarResize = new Resize(this.horizontalScrollBar);
				_horizontalScrollBarResize.heightFrom = 0;
				_horizontalScrollBarResize.heightTo = _previousScrollBarHHeight;
				_horizontalScrollBarResize.play();
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