package collaboRhythm.view.scroll
{
	import flash.events.*;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import mx.controls.Button;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.events.EffectEvent;
	import mx.events.ResizeEvent;
	import mx.events.ScrollEvent;
	import mx.managers.CursorManagerPriority;
	
	import spark.components.Button;
	import spark.components.Label;
	
	/**
	 * Responsible for handling touch scrolling logic. This class makes it possible to implement touch scrolling
	 * for scrollable components using composition (instead of inheritance). 
	 * 
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.ITouchScrollerAdapter
	 */
	public class TouchScroller extends EventDispatcher
	{
		// TouchScroller scrolls the content of a component which is accessed via _adapter
		private var _adapter:ITouchScrollerAdapter;
		
		// length of mouse movement beyond which the move is considered dragging for scrolling
		private var _scrollDetectionThreshold:Number = 10;
		// use vertical scrolling; if true, vertical dragging will cause vertical scrolling 
		private var _useVerticalTouchScrolling:Boolean = true;
		// use horizontal scrolling; if true, horizontal dragging will cause horizontal scrolling
		private var _useHorizontalTouchScrolling:Boolean = true;
		// use inertia when a flick occurs (drag ends) to continue scrolling
		private var _useInertia:Boolean = true;
		private var _friction:Number = 0.2; // range 0 (no friction) to 1 (no inertia)
		private var _springDampeningFactor:Number = 0.15; // range 0 (no dampening) to 1 (no spring force)
		private var _edgeSpringFactor:Number = 0.5; // spring constant, k where F = - k * x
		private var _flickLinearFactor:Number = 0.5; // accentuate (multiply) initial inertia on flick (1 = no change)
		private var _flickSquaredFactor:Number = 0.02; // factor for additional initial inertia on flick (add diff * diff * flickSquaredFactor; 0 = no squared factor)
		private var _maxInertia:Number = 300; // max absolute value for inertia 
		private var _maxEdgeSpring:Number = 300; // max absolute value for edge spring 
		private var _useMouseEventsAsTouch:Boolean = true; // enable use of mouse for drag-scrolling and flicking
		private var _useTouchMoveThreshold:Boolean = false;
		private var _touchMoveThreshold:Number = 2; // touch move must be greater than threshold in order to be considered a movement while dragging
		private var _useTouchFlickThreshold:Boolean = true;
		private var _touchFlickThreshold:Number = 2; // touch move must be greater than threshold in order to be considered a flick when dragging ends 
		private var _showDebugVisualizations:Boolean = false;
		private var _traceEventHandlers:Boolean = false;
		private var _closeToEdgeEpsilon:Number = 2; // for inertial scrolling, snap to scrolling limit (top or bottom edge) if closer than the epsilon value
		private var _scrollIndicatorThickness:Number = 6;
		private var _scrollIndicatorElipseWidth:Number = _scrollIndicatorThickness + 2;

		// time (in milliseconds) of the current frame; used for calculating FPS for debugging/performance testing
		private var _frameTime:Number = 0;
		
		// flag is true when mouse or touch events are being interpreted as scrolling events and should not be propogated to other event listeners 
		private var _shouldStopMouseAndTouchEventPropogation:Boolean = false;
		// flag is true when scrolling is being performed in some parent of the corresponding component (scroll start event detected) and thus any subsequent click event should not be propogated
		private var _shouldStopClickEventPropogation:Boolean = false;
		// flag is true when there is a mouse down event right after a touch begin; when this happens, the mouse events are considered redundant and ignored
		private var _treatMouseEventsAsRedundant:Boolean = false;
		
		// _moveSamplesStack stores recent move (touch or mouse) event coordinates so that filtering can be applied
		private var _moveSamplesStack:Vector.<MoveSample> = new Vector.<MoveSample>();
		// time in milliseconds after which a sample is considered old and not used for determining the current filtered position
		private var _recentSampleEpsilon:Number = 200;
		
		// indicates that user has started dragging (moved beyond the scrollThreshold) and thus scrolling should be done corresponding to the displacement from the start position
		private var _isDragging:Boolean = false;
		// indicates that inertial scrolling is in progress (enter frame events are being listened to, and either _inertia or edgeSpring is non-zero)
		private var _isInertiaScrolling:Boolean = false;
		// last (previous) mouse or touch position; used to determine flick inertia
		private var _lastPos:Point = new Point();
		// first mouse or touch position in local coordinates (used to determine drag offset)
		private var _firstPos:Point = new Point();
		// first mouse or touch position in global coordinates (used to detect movement of the whole component)
		private var _firstPosGlobal:Point = new Point();
		// position of scrollable content when first mouse or touch down event occurs  
		private var _firstContentPos:Point = new Point();
		// difference of mouse movement for flick gesture
		private var _diff:Point = new Point();
		// scroll inhertia power
		private var _inertia:Point = new Point();
		// edge spring force
		private var _edgeSpring:Point = new Point();
		// minimum movable length
		private var _min:Point = new Point();
		// maximum movable length
		private var _max:Point = new Point();
		//Touch coordinates;
		private var _touchX:Number;
		private var _touchY:Number;
		
		// time when last (previous) touch event occurred; used to detect a mouse event that corresponds to a touch event (and should thus be ignored)
		private var _lastTouchTime:Date;
		
		// indicates that the move (dragging) is being done by touch (as opposed to mouse)
		private var _isTouchMove:Boolean = false;
		
		private var _scrollIndicatorMaxAlpha:Number = 0.7; // maximum value used for the scroll bar alpha
		
		private var _scrollIndicatorV:UIComponent;
		private var _scrollIndicatorH:UIComponent;
		// fade effect for the vertical scroll indicator
		private var _scrollIndicatorVFade:Fade;
		// fade effect for the horizontal scroll indicator
		private var _scrollIndicatorHFade:Fade;
		
		// label to show frames per second (only used for performance testing)
		private var _fpsLabel:Label;
		
		// time (in milliseconds) spent doing update of inertia and position for scrolling (only used for performance testing)
		private var _updateDuration:Number = 0;

		[Embed(source="assets/cursors/hand.png")]
		private static const grabCursor:Class;
		private var grabCursorId:int;
		
		[Embed(source="assets/cursors/handClosed.png")]
		private static const grabbingCursor:Class;
		private var grabbingCursorId:int;
		
		public function TouchScroller(adapter:ITouchScrollerAdapter)
		{
			_adapter = adapter;
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			if (_useMouseEventsAsTouch)
				_adapter.component.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			_adapter.component.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			
			_adapter.component.addEventListener(ResizeEvent.RESIZE, resizeHandler);
			
			_adapter.component.addEventListener(TouchScrollerEvent.SCROLL_START, scrollStartHandler);
			
			_adapter.component.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			_adapter.component.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		}
		
		private function mouseOverHandler(event:MouseEvent):void
		{
			// TODO: determine why this isn't working and fix; currently disabled because this results in no visible cursor
//			grabCursorId = _adapter.component.cursorManager.setCursor(grabCursor, CursorManagerPriority.LOW, -8, -8);
		}
		
		private function mouseOutHandler(event:MouseEvent):void
		{
			if (grabCursorId != 0)
			{
				_adapter.component.cursorManager.removeCursor(grabCursorId);
				grabCursorId = 0;
			}
		}
		
		public function get traceEventHandlers():Boolean
		{
			return _traceEventHandlers;
		}

		public function set traceEventHandlers(value:Boolean):void
		{
			_traceEventHandlers = value;
		}

		public function get recentSampleEpsilon():Number
		{
			return _recentSampleEpsilon;
		}

		public function set recentSampleEpsilon(value:Number):void
		{
			_recentSampleEpsilon = value;
		}

		private function get useHorizontalScrollIndicator():Boolean
		{
//			return useHorizontalTouchScrolling && _adapter.contentWidth > _adapter.component.width;
			return false;
		}
		
		private function get useVerticalScrollIndicator():Boolean
		{
//			return useVerticalTouchScrolling && _adapter.contentHeight > _adapter.component.height;
			return false;
		}
		
		public function get useHorizontalTouchScrolling():Boolean
		{
			return _useHorizontalTouchScrolling && _adapter.scrollableAreaWidth > _adapter.panelWidth;
		}
		
		public function set useHorizontalTouchScrolling(value:Boolean):void
		{
			_useHorizontalTouchScrolling = value;
		}

		public function get useVerticalTouchScrolling():Boolean
		{
			return _useVerticalTouchScrolling && _adapter.scrollableAreaHeight > _adapter.panelWidth;
		}

		public function set useVerticalTouchScrolling(value:Boolean):void
		{
			_useVerticalTouchScrolling = value;
		}

		public function createChildren():void
		{
			_fpsLabel = new Label();
			_fpsLabel.setStyle("verticalAlign", "bottom");
			_fpsLabel.setStyle("textAlign", "right");
			_fpsLabel.setStyle("color", 0x0000FF);
			_fpsLabel.visible = false;
			if (_adapter.componentContainer is IVisualElementContainer)
				(_adapter.componentContainer as IVisualElementContainer).addElement(_fpsLabel);
			else
				_adapter.componentContainer.addChild(_fpsLabel);
			
			// initialize scrollIndicator
			_scrollIndicatorV = new UIComponent();
			_scrollIndicatorV.cacheAsBitmap = true;
			_scrollIndicatorV.alpha = 0;
			if (_adapter.componentContainer is IVisualElementContainer)
				(_adapter.componentContainer as IVisualElementContainer).addElement(_scrollIndicatorV);
			else
				_adapter.componentContainer.addChild(_scrollIndicatorV);
			
			_scrollIndicatorVFade = new Fade(_scrollIndicatorV);
			_scrollIndicatorVFade.addEventListener(EffectEvent.EFFECT_END, scrollIndicatorVFade_effectEndHandler);
			
			_scrollIndicatorH = new UIComponent();
			_scrollIndicatorH.cacheAsBitmap = true;
			_scrollIndicatorH.alpha = 0;
			if (_adapter.componentContainer is IVisualElementContainer)
				(_adapter.componentContainer as IVisualElementContainer).addElement(_scrollIndicatorH);
			else
				_adapter.componentContainer.addChild(_scrollIndicatorH);
			
			_scrollIndicatorHFade = new Fade(_scrollIndicatorH);
			_scrollIndicatorHFade.addEventListener(EffectEvent.EFFECT_END, scrollIndicatorHFade_effectEndHandler);
			
			positionChildren();
		}
		
		private function scrollIndicatorVFade_effectEndHandler(event:EffectEvent):void
		{
			// clear the scroll bar because otherwise it interferes with clicks and roll over events, event when alpha = 0
			_scrollIndicatorV.graphics.clear();
			_adapter.showScrollBarV();
		}
		
		private function scrollIndicatorHFade_effectEndHandler(event:EffectEvent):void
		{
			// clear the scroll bar because otherwise it interferes with clicks and roll over events, event when alpha = 0
			_scrollIndicatorH.graphics.clear();
			_adapter.showScrollBarH();
		}
		
		public function keyUpHandler(event:KeyboardEvent):void
		{
			if (event.ctrlKey && event.altKey && event.keyCode == Keyboard.V)
			{
				_showDebugVisualizations = !_showDebugVisualizations;
				_adapter.graphics.clear();
			}
			else if (event.ctrlKey && event.altKey && event.keyCode == Keyboard.E)
			{
				this.traceEventHandlers = !this.traceEventHandlers;
			}
		}
		
		private function get scrollIndicatorVOffset():Number
		{
			return Math.max(_scrollIndicatorThickness * 1.5, _scrollIndicatorThickness + 2);
		}
		
		private function get scrollIndicatorHOffset():Number
		{
			return scrollIndicatorVOffset;
		}
		
		private function resizeHandler(event:ResizeEvent):void
		{
			positionChildren();
		}
		
		private function positionChildren():void
		{
			_scrollIndicatorV.x = _adapter.component.width - scrollIndicatorVOffset;
			_scrollIndicatorH.y = _adapter.component.height - scrollIndicatorHOffset;
			
			// TODO: determine a better way to position the label in the bottom right corner with or without a scroll bar
			_fpsLabel.width = _adapter.component.width - 30;
			_fpsLabel.height = _adapter.component.height;
		}
		
		private function get panelWidth():Number
		{
			return _adapter.panelWidth;
		}
		
		private function get panelHeight():Number
		{
			return _adapter.panelHeight;
		}
		
		private function get contentWidth():Number
		{
			return _adapter.scrollableAreaWidth;
		}
		
		private function get contentHeight():Number
		{
			return _adapter.scrollableAreaHeight;
		}
		
		private function touchBeginHandler(e:TouchEvent):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".touchBeginHandler");
			
			_lastTouchTime = new Date();
			
			if (isTouchScrollerEvent(e))
			{
				_adapter.component.stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
				_adapter.component.stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler);
				
				getTouchPoint(e);
				
				_firstPos.x = _touchX;
				_firstPos.y = _touchY;
				
				initializeStartPosition(e);
			}
		}
		
		/**
		 * Listener for mouse down
		 * @param e information for mouse
		 */
		private function mouseDownHandler(e:MouseEvent):void 
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".mouseDownHandler, inertia: " + _inertia.y.toFixed(2));
			
			if (isTouchScrollerEvent(e))
			{
				_adapter.component.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				_adapter.component.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				_adapter.component.addEventListener(MouseEvent.CLICK, mouseClickHandler);
				_adapter.component.stage.addEventListener(MouseEvent.CLICK, mouseClickHandler);
	
				var now:Date = new Date();
				if (_lastTouchTime != null && now.time - _lastTouchTime.time < 500)
				{
					_treatMouseEventsAsRedundant = true;
					return;
				}
				else
				{
					_treatMouseEventsAsRedundant = false;
				}
				
				_firstPos.x = _adapter.component.mouseX;
				_firstPos.y = _adapter.component.mouseY;
				
				initializeStartPosition(e);
			}
		}
		
		public function isTouchScrollerEvent(e:Event):Boolean
		{
			// ignore all events for buttons (such as buttons in scroll bars)
			if (e.target is spark.components.Button || e.target is mx.controls.Button)
			{
				return false;	
			}
			
			return true;
		}
		
		private function initializeStartPosition(event:Event):void
		{
			_isDragging = false;
			_shouldStopMouseAndTouchEventPropogation = false;
			_shouldStopClickEventPropogation = false;
			
			_moveSamplesStack = new Vector.<MoveSample>();
			_moveSamplesStack.push(new MoveSample(_firstPos.x, _firstPos.y, new Date(), null));
			
			_firstPosGlobal = _adapter.component.localToGlobal(_firstPos);
			
			_lastPos.x = _firstPos.x;
			_lastPos.y = _firstPos.y;
			
			// start dragging immediately (instead of waiting for a move beyond threshold), thus allowing the user to catch an inertial scroll in progress 
			if (isInertiaScrollingInProgress())
			{
				stopInertiaScrolling();
				startDragging(event);
			}
			
			_firstContentPos.x = _adapter.contentPositionX;
			_firstContentPos.y = _adapter.contentPositionY;
			
			_min.x = Math.min(-_adapter.contentPositionX, -contentWidth + panelWidth - _adapter.contentPositionX);
			_min.y = Math.min(-_adapter.contentPositionY, -contentHeight + panelHeight - _adapter.contentPositionY);
			
			_max.x = -_adapter.contentPositionX;
			_max.y = -_adapter.contentPositionY;
		}
		
		private function isInertiaScrollingInProgress():Boolean
		{
			return _inertia.length != 0 || _edgeSpring.length != 0;
		}
		
		private function touchMoveHandler(e:TouchEvent):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".touchMoveHandler, move samples: " + _moveSamplesStack.length);

			_isTouchMove = true;
			getTouchPoint(e);
			
			//			trace("touchMoveHandler firstScrollPos.y: " + firstScrollPos.y.toFixed(2) + " totalY: " + totalY.toFixed(2) + " old: " + verticalScrollPosition.toFixed(2));
			doScrollMove(e, _touchX, _touchY, _useTouchMoveThreshold ? _touchMoveThreshold : 0);
			
//			trace("  should stop propagation:", _shouldStopMouseAndTouchEventPropogation, "isDragging", _isDragging);
			
			if (_shouldStopMouseAndTouchEventPropogation)
				e.stopImmediatePropagation();
		}
		
		private function getTouchPoint(e:TouchEvent):void
		{
			var localPt:Point = _adapter.component.globalToLocal(new Point(e.stageX, e.stageY));
			_touchX = localPt.x;
			_touchY = localPt.y;
		}
		
		/**
		 * Listener for mouse movement
		 * @param e information for mouse
		 */
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".mouseMoveHandler, move samples: " + _moveSamplesStack.length);
			
			if (_treatMouseEventsAsRedundant)
			{
				e.stopImmediatePropagation();
			}
			else
			{
				_isTouchMove = false;
				doScrollMove(e, _adapter.component.mouseX, _adapter.component.mouseY);
				
//				trace("  should stop propagation:", _shouldStopMouseAndTouchEventPropogation, "isDragging", _isDragging);
				if (_shouldStopMouseAndTouchEventPropogation)
					e.stopImmediatePropagation();
			}
		}
		
		private function doScrollMove(event:Event, posX:Number, posY:Number, threshold:Number=0):void
		{
			if (componentMoved())
			{
				removeTouchEventHandlers();
				removeMouseEventHandlers();
				this.dispatchEvent(new TouchScrollerEvent(TouchScrollerEvent.SCROLL_ABORT, _adapter.component));
				return;
			}
			
			updateMoveSamples(posX, posY);
			if (_isTouchMove)
			{
				var filteredPos:Point = getFilteredPosition();
				
				posX = filteredPos.x;
				posY = filteredPos.y;
			}
			
			var totalX:Number = posX - _firstPos.x;
			var totalY:Number = posY - _firstPos.y;
			
			var unfilteredDiff:Point = new Point();
			unfilteredDiff.y = posY - _lastPos.y;
			unfilteredDiff.x = posX - _lastPos.x;
			
			if (unfilteredDiff.length > threshold)
			{
				_diff.y = unfilteredDiff.y;
				_diff.x = unfilteredDiff.x;
				
				_lastPos.y = posY;
				_lastPos.x = posX;
				
				// movement detection
				if (useVerticalTouchScrolling && Math.abs(totalY) > _scrollDetectionThreshold && contentHeight > 0) {
					if (!_isDragging)
						startDragging(event);
					showScrollIndicatorV();

				}
				if (useHorizontalTouchScrolling && Math.abs(totalX) > _scrollDetectionThreshold && contentWidth > 0) {
					if (!_isDragging)
						startDragging(event);
					showScrollIndicatorH();
				}
				
				if (_isDragging) {
					
					if (useVerticalTouchScrolling) {
						if (totalY < _min.y) {
							if (_useInertia)
								totalY = scrollBeyondEdge(_min.y, totalY);
							else
								totalY = _min.y;
						}
						if (totalY > _max.y) {
							if (_useInertia)
								totalY = scrollBeyondEdge(_max.y, totalY);
							else
								totalY = _max.y;
						}
						_adapter.contentPositionY = _firstContentPos.y + totalY;
						dispatchScrollEvent();
						redrawScrollIndicatorV();
					}
					
					if (useHorizontalTouchScrolling) {
						if (totalX < _min.x) {
							if (_useInertia)
								totalX = scrollBeyondEdge(_min.x, totalX);
							else
								totalX = _min.x;
						}
						if (totalX > _max.x) {
							if (_useInertia)
								totalX = scrollBeyondEdge(_max.x, totalX);
							else
								totalX = _max.x;
						}
						_adapter.contentPositionX = _firstContentPos.x + totalX;
						dispatchScrollEvent();
						redrawScrollIndicatorH();
					}
					
				}
			}
			
			updateFps();
		}
		
		private function dispatchScrollEvent():void
		{
			this._adapter.component.dispatchEvent(new ScrollEvent(ScrollEvent.SCROLL));
		}
		
		private function componentMoved():Boolean
		{
			var updatedFirstPosGlobal:Point = _adapter.component.localToGlobal(_firstPos);
			return _firstPosGlobal.subtract(updatedFirstPosGlobal).length > 0;
		}
		
		private function startDragging(event:Event):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".startDragging");

			// TODO: determine why this isn't working and fix; currently disabled because this results in no visible cursor
//			grabbingCursorId = _adapter.component.cursorManager.setCursor(grabbingCursor, CursorManagerPriority.MEDIUM, -8, -8);

			_isDragging = true;
			_shouldStopMouseAndTouchEventPropogation = true;
			_shouldStopClickEventPropogation = true;
			this.dispatchEvent(new TouchScrollerEvent(TouchScrollerEvent.SCROLL_START, _adapter.component));
			event.target.dispatchEvent(new TouchScrollerEvent(TouchScrollerEvent.SCROLL_START, _adapter.component, true));
		}
		
		private function scrollStartHandler(event:TouchScrollerEvent):void
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".scrollStartHandler, stop? " + _shouldStopMouseAndTouchEventPropogation + ", stop click? " + (event.scrollTarget != _adapter.component) + ", target: " + event.target + ", scrollTarget: " + event.scrollTarget);

			// if some other component (a parent component) is scrolling, we should not propogate mouse and touch events (especially mouse click) 
			if (event.scrollTarget != _adapter.component)
			{
//				_shouldStopMouseAndTouchEventPropogation = true;
//				removeTouchEventHandlers();
//				removeMouseEventHandlers();
				_shouldStopClickEventPropogation = true;

//				removeTouchEventHandlers();
//				removeMouseEventHandlers();
				this.dispatchEvent(new TouchScrollerEvent(TouchScrollerEvent.SCROLL_ABORT, _adapter.component));
			}
		}
		
		private function scrollBeyondEdge(limit:Number, actual:Number):Number
		{
			// Note that if we wanted to use a quadratic fall-off instead of a linear one we could use the following:
			//	totalY = min.y - Math.sqrt(min.y - totalY);
			//	totalY = max.y + Math.sqrt(totalY - max.y);
			return limit + 0.5 * (actual - limit);
		}
		
		private function updateMoveSamples(posX:Number, posY:Number):void
		{
			var previousSample:MoveSample = _moveSamplesStack.length > 0 ? _moveSamplesStack[0] : null;
			
			clearOldMoveSamples();
			
			_moveSamplesStack.unshift(new MoveSample(posX, posY, new Date(), previousSample));
		}
		
		private function getFilteredPosition():Point
		{
			var filteredPos:Point = new Point();
			
			for each (var sample:MoveSample in _moveSamplesStack)
			{
				filteredPos.x += sample.pos.x;
				filteredPos.y += sample.pos.y;
			}
			
			filteredPos.x /= _moveSamplesStack.length;
			filteredPos.y /= _moveSamplesStack.length;
			
//			trace("filtered position determined from " + _moveSamplesStack.length + " samples: " + filteredPos.x.toFixed(2) + ", " + filteredPos.y.toFixed(2)); 
			
			return filteredPos;
		}
		
		private function clearOldMoveSamples():void
		{
			var now:Date = new Date();
			
			// dump old samples
			while (_moveSamplesStack.length > 0 && now.time - _moveSamplesStack[_moveSamplesStack.length - 1].dateStamp.time > _recentSampleEpsilon)
			{
				_moveSamplesStack.pop();
				
				if (_moveSamplesStack.length > 0)
				{
					var oldestPreviousSample:MoveSample = _moveSamplesStack[_moveSamplesStack.length - 1].previousSample;
					if (oldestPreviousSample != null)
						oldestPreviousSample.previousSample = null;
				}
			}
		}
		
		private function touchEndHandler(e:TouchEvent):void 
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".touchEndHandler, stop? " + _shouldStopMouseAndTouchEventPropogation);
			
			removeTouchEventHandlers();
			removeMouseEventHandlers();
			
			_touchX = e.stageX;
			_touchY = e.stageY;
			
			doFlick(e);
			
//			if (_shouldStopMouseAndTouchEventPropogation)
//				e.stopImmediatePropagation();
		}
		
		private function removeTouchEventHandlers():void
		{
//			_adapter.component.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
			_adapter.component.stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
//			_adapter.component.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
			_adapter.component.stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
		}
		
		private function get traceInstanceDescription():String
		{
			var adapterString:String = (Object(this._adapter)).toString();
			var adapterParts:Array = adapterString.split(".");
			return adapterParts[adapterParts.length - 1] + ".touchScroller";
		}
		
		/**
		 * Listener for mouse up action
		 * @param e information for mouse
		 */
		private function mouseUpHandler(e:MouseEvent):void 
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".mouseUpHandler, stop? " + _shouldStopMouseAndTouchEventPropogation + ", move samples: " + _moveSamplesStack.length + ", target: " + e.target);
			
//			if (e.target is WindowedSystemManager) return;
			
			removeMouseEventHandlers();
			
			if (_treatMouseEventsAsRedundant)
			{
				e.stopImmediatePropagation();
			}
			else
			{
				doFlick(e);
				
//				if (_shouldStopMouseAndTouchEventPropogation)
//					e.stopImmediatePropagation();
			}
		}
		
		private function removeMouseEventHandlers():void
		{
			_adapter.component.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_adapter.component.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}

		private function mouseClickHandler(e:MouseEvent):void 
		{
			if (_traceEventHandlers)
				trace(traceInstanceDescription + ".mouseClickHandler, stop? " + _shouldStopMouseAndTouchEventPropogation + ", moved? " + componentMoved() + ", target: " + e.target);
			
			_adapter.component.removeEventListener(MouseEvent.CLICK, mouseClickHandler);
			if (_adapter.component.stage != null)
				_adapter.component.stage.removeEventListener(MouseEvent.CLICK, mouseClickHandler);

			if (_shouldStopMouseAndTouchEventPropogation || _shouldStopClickEventPropogation || componentMoved())
				e.stopImmediatePropagation();
		}
		
		private function doFlick(event:Event):void
		{
			if (!_isDragging)
				return;
			
			if (grabbingCursorId != 0)
			{
				_adapter.component.cursorManager.removeCursor(grabbingCursorId);
				grabbingCursorId = 0;
			}
			
			_isDragging = false;
			
			_diff.x = 0;
			_diff.y = 0;
			
			clearOldMoveSamples();
			if (_moveSamplesStack.length > 0)
			{
				var lastSample:MoveSample = _moveSamplesStack[0];
				var firstSample:MoveSample = _moveSamplesStack[_moveSamplesStack.length - 1];
				if (firstSample.previousSample != null)
					firstSample = firstSample.previousSample;
				
				if (firstSample != null)
				{
					_lastPos.x = lastSample.pos.x;
					_lastPos.y = lastSample.pos.y;
					
					_diff.x = lastSample.pos.x - firstSample.pos.x;
					_diff.y = lastSample.pos.y - firstSample.pos.y;
					
					// setting inertia power
					if (useVerticalTouchScrolling)
					{
						if (event.type != TouchEvent.TOUCH_END || (_useTouchFlickThreshold && Math.abs(_diff.y) > _touchFlickThreshold))
						{
							_inertia.y = _diff.y * _flickLinearFactor + _diff.y * Math.abs(_diff.y) * _flickSquaredFactor;
//							trace("Flick: " + inertia.y.toFixed(2) + " from a " + event.type + ", target: " + event.target);
						}
					}
					if (useHorizontalTouchScrolling)
					{
						if (event.type != TouchEvent.TOUCH_END || (_useTouchFlickThreshold && Math.abs(_diff.x) > _touchFlickThreshold))
						{
							_inertia.x = _diff.x * _flickLinearFactor + _diff.x * Math.abs(_diff.x) * _flickSquaredFactor;
						}
					}
				}
			}
			
			if (_showDebugVisualizations)
			{
				_adapter.graphics.clear();
				_adapter.graphics.lineStyle(1, 0x008800, 0.5);
				for each (var sample:MoveSample in _moveSamplesStack)
				{
					if (sample.previousSample != null)
					{
						_adapter.graphics.moveTo(sample.previousSample.pos.x, sample.previousSample.pos.y);
						_adapter.graphics.lineTo(sample.pos.x, sample.pos.y);
					}
					_adapter.graphics.drawCircle(sample.pos.x, sample.pos.y, 2);
				}
				
				_adapter.graphics.lineStyle(1, 0xFF0000, 0.5);
				_adapter.graphics.moveTo(_lastPos.x, _lastPos.y);
				_adapter.graphics.lineTo(_lastPos.x - _diff.x, _lastPos.y - _diff.y);
				_adapter.graphics.lineStyle(2, 0x0000FF, 0.5);
				_adapter.graphics.drawCircle(_lastPos.x, _lastPos.y, 2);
			}
			
			if (_useInertia)
			{
				_adapter.component.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
				_isInertiaScrolling = true;
			}
			else
			{
				this.dispatchEvent(new TouchScrollerEvent(TouchScrollerEvent.SCROLL_STOP, _adapter.component));
			}
		}
		
		/**
		 * Listener for enter frame event
		 * @param e event information
		 */
		private function enterFrameHandler(e:Event):void 
		{
//			trace("enter frame, inertia: " + _inertia.y.toFixed(2) + ", spring: " + _edgeSpring.y.toFixed(2) + " parent heights: " + getParentHeights());
			if (inertiaScrollingUpdate())
				stopInertiaScrolling();
			
			updateFps();
		}
		
		private function getParentHeights():String
		{
			var heights:String = "";
			
			var component:UIComponent = _adapter.component;
			while (component != null)
			{
				heights += component.height.toFixed(0) + ", ";
				component = component.parent as UIComponent;
			}
			return heights;
		}
		
		public function stopInertiaScrolling():void
		{
			if (_isInertiaScrolling)
			{
				_inertia.y = 0;
				_inertia.x = 0;
				
				_edgeSpring.y = 0;
				_edgeSpring.x = 0;
				
				_adapter.component.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				this.dispatchEvent(new TouchScrollerEvent(TouchScrollerEvent.SCROLL_STOP, _adapter.component));
				
				_isInertiaScrolling = false;
			}
		}
		
		/**
		 * Updates the scroll position and visibility of the scroll indicators.
		 * @return true if updating is complete and no changes will be made on subsequent updates 
		 */
		private function inertiaScrollingUpdate():Boolean
		{
			// movements while non dragging
			
			var functionStartTime:Date = new Date(); 
			
			if (useVerticalTouchScrolling) {
				//					if (inertia.y != 0)
				//						trace(" --> inertia, y: " + inertia.y.toFixed(2) + ", " + _adapter.contentPositionY.toFixed(2));
				
				_edgeSpring.y = 0;
				
				// scroll up past top edge
				if (_adapter.contentPositionY > 0) {
					if (_inertia.y == 0 && _adapter.contentPositionY < _closeToEdgeEpsilon)
					{
						_adapter.contentPositionY = 0;
						dispatchScrollEvent();
					}
					else
						_edgeSpring.y = - _edgeSpringFactor * _adapter.contentPositionY;
				}
				
				// scroll down past bottom edge
				if (contentHeight >= panelHeight && _adapter.contentPositionY < panelHeight - contentHeight) {
					var goal:Number = panelHeight - contentHeight;
					var diff:Number = goal - _adapter.contentPositionY;
					
					if (_inertia.y == 0 && diff < _closeToEdgeEpsilon)
					{
						_adapter.contentPositionY += diff;
						dispatchScrollEvent();
					}
					else
						_edgeSpring.y = _edgeSpringFactor * diff; 
				}
				
				// scroll down when there is no where to scrolll to
				if (contentHeight < panelHeight && _adapter.contentPositionY < 0) {
					if (_inertia.y == 0 && _adapter.contentPositionY > -_closeToEdgeEpsilon)
					{
						_adapter.contentPositionY = 0;
						dispatchScrollEvent();
					}
					else
						_edgeSpring.y = - _edgeSpringFactor * _adapter.contentPositionY;
				}
				
				if (Math.abs(_edgeSpring.y) > 1) {
					_edgeSpring.y = limitAbsValue(_edgeSpring.y, _maxEdgeSpring); 
					//						_edgeSpring.y *= (1 - springDampeningFactor);
					//						inertia.y += _edgeSpring.y;
					_adapter.contentPositionY += _edgeSpring.y;
					dispatchScrollEvent();
					_inertia.y *= (1 - _springDampeningFactor);
				} else {
					_edgeSpring.y = 0;
				}
				
				if (Math.abs(_inertia.y) > 1) {
					_inertia.y = limitAbsValue(_inertia.y, _maxInertia); 
					_adapter.contentPositionY += _inertia.y;
					dispatchScrollEvent();
					_inertia.y *= (1 - _friction);
				} else {
					_inertia.y = 0;
				}
				
				if (_inertia.y != 0 || _edgeSpring.y != 0) {
					redrawScrollIndicatorV();
				} else {
					if (_scrollIndicatorV.alpha > 0 && !_scrollIndicatorVFade.isPlaying)
					{
						_scrollIndicatorV.alpha = _scrollIndicatorMaxAlpha * 0.99;
						_scrollIndicatorVFade.alphaFrom = _scrollIndicatorV.alpha;
						_scrollIndicatorVFade.alphaTo = 0;
						_scrollIndicatorVFade.play();
					}
				}
			}
			
			if (useHorizontalTouchScrolling) {
				//					if (inertia.x != 0)
				//						trace(" --> inertia, x: " + inertia.x.toFixed(2) + ", " + _adapter.contentPositionX.toFixed(2));
				
				_edgeSpring.x = 0;
				
				// scroll up past top edge
				if (_adapter.contentPositionX > 0) {
					if (_inertia.x == 0 && _adapter.contentPositionX < _closeToEdgeEpsilon)
					{
						_adapter.contentPositionX = 0;
						dispatchScrollEvent();
					}
					else
						_edgeSpring.x = - _edgeSpringFactor * _adapter.contentPositionX;
				}
				
				// scroll down past bottom edge
				if (contentWidth >= panelWidth && _adapter.contentPositionX < panelWidth - contentWidth) {
					goal = panelWidth - contentWidth;
					diff = goal - _adapter.contentPositionX;
					
					if (_inertia.x == 0 && diff < _closeToEdgeEpsilon)
					{
						_adapter.contentPositionX += diff;
						dispatchScrollEvent();
					}
					else
						_edgeSpring.x = _edgeSpringFactor * diff; 
				}
				
				// scroll down when there is no where to scrolll to
				if (contentWidth < panelWidth && _adapter.contentPositionX < 0) {
					if (_inertia.x == 0 && _adapter.contentPositionX > -_closeToEdgeEpsilon)
					{
						_adapter.contentPositionX = 0;
						dispatchScrollEvent();
					}
					else
						_edgeSpring.x = - _edgeSpringFactor * _adapter.contentPositionX;
				}
				
				if (Math.abs(_edgeSpring.x) > 1) {
					_edgeSpring.x = limitAbsValue(_edgeSpring.x, _maxEdgeSpring); 
					//						_edgeSpring.x *= (1 - springDampeningFactor);
					//						inertia.x += _edgeSpring.x;
					_adapter.contentPositionX += _edgeSpring.x;
					dispatchScrollEvent();
					_inertia.x *= (1 - _springDampeningFactor);
				} else {
					_edgeSpring.x = 0;
				}
				
				if (Math.abs(_inertia.x) > 1) {
					_inertia.x = limitAbsValue(_inertia.x, _maxInertia); 
					_adapter.contentPositionX += _inertia.x;
					dispatchScrollEvent();
					_inertia.x *= (1 - _friction);
				} else {
					_inertia.x = 0;
				}
				
				if (_inertia.x != 0 || _edgeSpring.x != 0) {
					redrawScrollIndicatorH();
				} else {
					if (_scrollIndicatorH.alpha > 0 && !_scrollIndicatorHFade.isPlaying)
					{
						_scrollIndicatorH.alpha = _scrollIndicatorMaxAlpha * 0.99;
						_scrollIndicatorHFade.alphaFrom = _scrollIndicatorH.alpha;
						_scrollIndicatorHFade.alphaTo = 0;
						_scrollIndicatorHFade.play();
					}
				}
			}
			
			var functionEndTime:Date = new Date();
			_updateDuration = functionEndTime.time - functionStartTime.time;
			
			return (_inertia.length == 0 && _edgeSpring.length == 0);
		}
		
		private function updateFps():void
		{
			var lastFrameTime:Number = _frameTime;
			_frameTime = (new Date()).time;
			var fps:Number = 1000 / (_frameTime - lastFrameTime);
			_fpsLabel.text = "FPS: " + fps.toFixed(1) + " Update Time: " + _updateDuration.toFixed(1);
			// For debugging: show where the label is positioned
			//			_adapter.graphics.lineStyle(3, 0x0000FF);
			//			_adapter.graphics.drawRect(_fpsLabel.x, _fpsLabel.y, _fpsLabel.width, _fpsLabel.height);
		}
		
		private function showScrollIndicatorV():void
		{
			if (useVerticalScrollIndicator)
			{
				redrawScrollIndicatorV();
				
				_scrollIndicatorVFade.stop();
				_scrollIndicatorV.alpha = _scrollIndicatorMaxAlpha;
	
				_adapter.hideScrollBarV();
			}
		}
		
		private function redrawScrollIndicatorV():void
		{
			_scrollIndicatorV.graphics.clear();
			if (useVerticalScrollIndicator)
			{
				var indicatorTop:Number = panelHeight * Math.min(1, (-_adapter.contentPositionY / contentHeight));
				var indicatorBottom:Number = indicatorTop + panelHeight * Math.max(0, panelHeight / Math.max(panelHeight, contentHeight));
				
				// when scrolling beyond the edge, don't draw the scroll indicator (change the length of the scroll indicator) 
				indicatorTop = Math.max(indicatorTop, 0);
				indicatorTop = Math.min(indicatorTop, panelHeight - _scrollIndicatorThickness);
				indicatorBottom = Math.max(indicatorBottom, 0 + _scrollIndicatorThickness);
				indicatorBottom = Math.min(indicatorBottom, panelHeight);
				
				_scrollIndicatorV.graphics.beginFill(0x888899,1);
				_scrollIndicatorV.graphics.drawRoundRect(0, indicatorTop, _scrollIndicatorThickness, indicatorBottom - indicatorTop, _scrollIndicatorElipseWidth);
				_scrollIndicatorV.graphics.endFill();
			}
		}
		
		private function showScrollIndicatorH():void
		{
			if (useHorizontalScrollIndicator)
			{
				redrawScrollIndicatorH();
	
				_scrollIndicatorHFade.stop();
				_scrollIndicatorH.alpha = _scrollIndicatorMaxAlpha;
				
				_adapter.hideScrollBarH();
			}
		}
		
		private function redrawScrollIndicatorH():void
		{
			_scrollIndicatorH.graphics.clear();
			if (useHorizontalScrollIndicator)
			{
				var indicatorLeft:Number = panelWidth * Math.min(1, (-_adapter.contentPositionX / contentWidth));
				var indicatorRight:Number = indicatorLeft + panelWidth * Math.max(0, panelWidth / Math.max(panelWidth, contentWidth));
				
				// when scrolling beyond the edge, don't draw the scroll indicator (change the length of the scroll indicator) 
				indicatorLeft = Math.max(indicatorLeft, 0);
				indicatorLeft = Math.min(indicatorLeft, panelWidth - _scrollIndicatorThickness);
				indicatorRight = Math.max(indicatorRight, 0 + _scrollIndicatorThickness);
				indicatorRight = Math.min(indicatorRight, panelWidth);
				
				_scrollIndicatorH.graphics.beginFill(0x888899,1);
				_scrollIndicatorH.graphics.drawRoundRect(indicatorLeft, 0, indicatorRight - indicatorLeft, _scrollIndicatorThickness, _scrollIndicatorElipseWidth);
				_scrollIndicatorH.graphics.endFill();
			}
		}
		
		private function limitAbsValue(value:Number, limit:Number):Number
		{
			if (value == 0)
				return 0;
			else
				return Math.min(Math.abs(value), limit) * (Math.abs(value) / value);
		}		
	}
}