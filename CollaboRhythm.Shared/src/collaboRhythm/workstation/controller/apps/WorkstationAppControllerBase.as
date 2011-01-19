package collaboRhythm.workstation.controller.apps
{
	import collaboRhythm.workstation.model.CollaborationRoomNetConnectionServiceProxy;
	import collaboRhythm.workstation.model.CommonHealthRecordService;
	import collaboRhythm.workstation.model.User;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.IWindow;
	import mx.core.UIComponent;
	import mx.effects.Parallel;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.graphics.ImageSnapshot;
	import mx.managers.DragManager;
	
	import spark.components.Group;
	import spark.components.Window;
	import spark.effects.*;
	import spark.layouts.BasicLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Rect;

	/**
	 * Represents an instance of a workstation app which can be used to view and/or manipulate some aspect of a health record
	 * in a collaborative (or solo) work session. Workstation apps can have a mini "widget" view and a larger "full"
	 * view.
	 */	
	public class WorkstationAppControllerBase extends EventDispatcher
	{
		public static const WIDGET_WATERMARK_ALPHA:Number = 0.2;
		public static const DEBUG_BUTTON_ALPHA:Number = 0.2;
		public static const DEBUG_BUTTON_VISIBLE:Boolean = false;
		public static const WIDGET_HEIGHT:Number = 165;
		public static const PREVENT_RE_SHOWING_FULL_VIEW:Boolean = true;
		
		protected var _widgetParentContainer:IVisualElementContainer;
		protected var _widgetParentContainerLayout:LayoutBase;
		protected var _fullParentContainer:IVisualElementContainer;
		protected var _healthRecordService:CommonHealthRecordService;
		protected var _user:User;
		protected var _collaborationRoomNetConnectionServiceProxy:CollaborationRoomNetConnectionServiceProxy;
		
		private var _topSpaceTransitionComponent:UIComponent;
		private var _centerSpaceTransitionComponent:UIComponent;
		
		private var _name:String;
		
		public function WorkstationAppControllerBase(widgetParentContainer:IVisualElementContainer, fullParentContainer:IVisualElementContainer)
		{
			_widgetParentContainer = widgetParentContainer;
			_fullParentContainer = fullParentContainer;

			createAndPrepareWidgetView();
			
			if (_fullParentContainer)
			{
				fullView = createFullView();
				this.prepareFullView();
			}
			
			if (widgetView)
				showWidgetAsDraggable(fullView != null);
		}
		
		public function createAndPrepareWidgetView():void
		{
			if (_widgetParentContainer && !widgetView)
			{
				widgetView = createWidgetView();
				this.prepareWidgetView();
			}
		}

		public function get widgetParentContainer():IVisualElementContainer
		{
			return _widgetParentContainer;
		}

		public function set widgetParentContainer(value:IVisualElementContainer):void
		{
			_widgetParentContainer = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		/**
		 * Temporary instance of the view used in the top space for transition effect when showing the full view.  
		 */
		public function get topSpaceTransitionComponent():UIComponent
		{
			return _topSpaceTransitionComponent;
		}

		public function set topSpaceTransitionComponent(value:UIComponent):void
		{
			if (_topSpaceTransitionComponent != null)
			{
				removeFromParent(_topSpaceTransitionComponent);
			}	
			_topSpaceTransitionComponent = value;
		}
		
		/**
		 * Temporary instance of the view used in the center space for transition effect when showing the full view.  
		 */
		public function get centerSpaceTransitionComponent():UIComponent
		{
			return _centerSpaceTransitionComponent;
		}

		public function set centerSpaceTransitionComponent(value:UIComponent):void
		{
			if (_centerSpaceTransitionComponent != null)
			{
				removeFromParent(_centerSpaceTransitionComponent);
			}	
			_centerSpaceTransitionComponent = value;
		}
		
		public function removeFromParent(component:UIComponent):void
		{
			if (component != null)
			{
				var element:IVisualElement = component;
				if (element != null)
				{
					var parentContainer:IVisualElementContainer = component.parent as IVisualElementContainer;
					if (parentContainer != null)
						parentContainer.removeElement(element);
				}
				
				if (component.parent != null)
					component.parent.removeChild(component);
			}
		}

		public function get widgetView():UIComponent
		{
			return null;
		}

		public function set widgetView(value:UIComponent):void
		{
		}

		public function get fullView():UIComponent
		{
			return null;
		}

		public function set fullView(value:UIComponent):void
		{
		}
		
		public function get healthRecordService():CommonHealthRecordService
		{
			return _healthRecordService;
		}

		public function set healthRecordService(value:CommonHealthRecordService):void
		{
			_healthRecordService = value;
		}

		public function get user():User
		{
			return _user;
		}

		public function set user(value:User):void
		{
			_user = value;
		}
		
		public function get collaborationRoomNetConnectionServiceProxy():CollaborationRoomNetConnectionServiceProxy
		{
			return _collaborationRoomNetConnectionServiceProxy;
		}
		
		public function set collaborationRoomNetConnectionServiceProxy(value:CollaborationRoomNetConnectionServiceProxy):void
		{
			_collaborationRoomNetConnectionServiceProxy = value;
		}
		
		/**
		 * Factory method to create an instance of the widget view associated with this app.
		 * Note that this instance may or may not be used as the main instance corresponding to the "widgetView" property.
		 * @return a new instance of the corresponding widget view component
		 */
		protected function createWidgetView():UIComponent
		{
			return null;
		}
		
		/**
		 * Factory method to create an instance of the full view associated with this app.
		 * Note that this instance may or may not be used as the main instance corresponding to the "fullView" property.
		 * @return a new instance of the corresponding full view component
		 */
		protected function createFullView():UIComponent
		{
			return null;
		}

		/**
		 * Prepares the widget view for use. 
		 */
		protected function prepareWidgetView():void
		{
//			widgetView.height = WIDGET_HEIGHT;
			
//			Multitouch.inputMode = MultitouchInputMode.GESTURE;
//			widgetView.addEventListener(TransformGestureEvent.GESTURE_PAN, widgetPanHandler);
			
			widgetView.addEventListener(MouseEvent.CLICK, widgetClickHandler);
			widgetView.addEventListener(MouseEvent.MOUSE_DOWN, widgetMouseDownHandler);
			
			widgetView.visible = false;
			_widgetParentContainer.addElement(widgetView);
		}
		
		/**
		 * Prepares the fullView for use. 
		 */
		protected function prepareFullView():void
		{
			if (fullView != null)
			{
				fullView.visible = false;
				_fullParentContainer.addElement(fullView);
			}
		}
		
		public function canShowFullView():Boolean
		{
			if (fullView == null || (topSpaceTransitionComponent != null && topSpaceTransitionComponent.visible))
				return false;
			
			if (PREVENT_RE_SHOWING_FULL_VIEW)
			{
				var selected:Boolean = widgetView.getStyle("selected") as Boolean;
				return !selected;
			}
			else
				return true;
		}
		
		public function beginDrag(mouseEvent:MouseEvent):void
		{
			if (mouseEvent.buttonDown)
			{
				if (canShowFullView())
				{
					showWidgetAsDraggable(false);
					showWidgetAsSelected(true);
					
					// the drag initiator is the object being dragged (target of the mouse event)
					var dragInitiator:IUIComponent = mouseEvent.currentTarget as IUIComponent;
					
					// the drag source contains data about what's being dragged
					var dragSource:DragSource = new DragSource();
					dragSource.addData(new WorkstationAppDragData(mouseEvent), WorkstationAppDragData.DRAG_SOURCE_DATA_FORMAT);
					
					// ask the DragManger to begin the drag
					DragManager.doDrag(dragInitiator, dragSource, mouseEvent, this.createWidgetView());
				}
			}
		}
		
		public function showWidgetAsDraggable(value:Boolean):void
		{
			widgetView.setStyle("dropShadowVisible", value);
		}
		
		public function showWidgetAsSelected(value:Boolean):void
		{
			widgetView.setStyle("selected", value);
		}
		
		public function makeDroppable( component:IUIComponent ):void
		{
			// a dragEnter event occurs when a draggable is over a droppable
			component.addEventListener( DragEvent.DRAG_ENTER, allowDrop );
			
			// a dragDrop event occurs when a draggable is dropped
			component.addEventListener( DragEvent.DRAG_DROP, acceptDrop );
			
			component.addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);
			
			component.addEventListener(DragEvent.DRAG_COMPLETE, dragComleteHandler);
		}
		
		public function dragComleteHandler(dragEvent:DragEvent):void
		{
			var dragSource:DragSource = dragEvent.dragSource;
			var dragInitiator:IUIComponent = dragEvent.dragInitiator;
			var dropTarget:Object = dragEvent.currentTarget;
			
			trace( "Drag Complete ("+dragInitiator.name +") to ("+dropTarget.name +") " + dragEvent.delta );
			
			var data:WorkstationAppDragData = dragSource.dataForFormat(WorkstationAppDragData.DRAG_SOURCE_DATA_FORMAT) as WorkstationAppDragData;
			var startRect:Rect;
			if (data != null)
			{
				startRect = new Rect();
				startRect.x = dragEvent.localX - data.mouseEvent.localX;
				startRect.y = dragEvent.localY - data.mouseEvent.localY;
				
			}
			this.dispatchEvent(new WorkstationAppEvent(WorkstationAppEvent.SHOW_FULL_VIEW, this, startRect));
		}
		
		public function dragExitHandler(dragEvent:DragEvent):void
		{
			var dragSource:DragSource = dragEvent.dragSource;
			var dragInitiator:IUIComponent = dragEvent.dragInitiator;
			var dropTarget:Object = dragEvent.currentTarget;
			
			trace( "Drag Exit ("+dragInitiator.name +") to ("+dropTarget.name +")" );
		}
		
		public function allowDrop( dragEvent:DragEvent ):void
		{
			// the drop target
			var dropTarget:IUIComponent = dragEvent.currentTarget as IUIComponent;
			
			// signal to the drop manager that this will accept the item
			DragManager.acceptDragDrop(dropTarget);
			
			DragManager.showFeedback(DragManager.MOVE);
		}
		
		public function acceptDrop( dragEvent:DragEvent ):void
		{
			var dragSource:DragSource = dragEvent.dragSource;
			var dragInitiator:IUIComponent = dragEvent.dragInitiator;
			var dropTarget:Object = dragEvent.currentTarget;
			
			trace( "Dragged ("+dragInitiator.name +") to ("+dropTarget.name +") and Dropped" );
		}
		
		private function widgetDragCompleteHandler(event:DragEvent):void
		{
			
		}
		
		private function widgetPanHandler(e:TransformGestureEvent):void
		{
			trace("On pan... " + e.phase + " " + e.offsetX + " offset Y " + e.offsetY);
//			var prevPoint:Point = new Point(img.x,img.y);
//			img.x += e.offsetX*3;
//			img.y += e.offsetY*3;
			
//			if (e.phase == GesturePhase.END && Math.abs(e.offsetX) < 100 && e.offsetY < -20)
//				this.dispatchEvent(new WorkstationAppEvent(WorkstationAppEvent.SHOW_FULL_VIEW, this));
		}
		
		private function widgetDoubleClickHandler(event:MouseEvent):void
		{
			if (canShowFullView())
				this.dispatchEvent(new WorkstationAppEvent(WorkstationAppEvent.SHOW_FULL_VIEW, this));
		}

		private function widgetClickHandler(event:MouseEvent):void
		{
//			trace("widgetClickHandler");
			
			if (canShowFullView() && isShowFullViewClickEvent(event))
				this.dispatchEvent(new WorkstationAppEvent(WorkstationAppEvent.SHOW_FULL_VIEW, this));
		}
		
		private function isShowFullViewClickEvent(event:MouseEvent):Boolean
		{
			// ignore all events for buttons (such as buttons in scroll bars)
			if (event.target is spark.components.Button || event.target is mx.controls.Button)
			{
				return false;
			}
			
			return true;
		}
		
		private function widgetMouseDownHandler(event:MouseEvent):void
		{
			if (canShowFullView())
				showWidgetAsDraggable(false);
		}
		
		public function get parentContainer():IVisualElementContainer
		{
			return _widgetParentContainer;
		}

		private function set parentContainer(value:IVisualElementContainer):void
		{
			_widgetParentContainer = value;
		}
		
		public function showWidget(left:Number=-1, top:Number=-1):void
		{
			if (left != -1 && top != -1)
				widgetView.move(left, top);

//			var move:Move = new Move(widgetView);
//			move.xTo = widgetView.x;
//			move.xFrom = _widgetParentContainer.width / 2;
//			move.yTo = widgetView.y;
//			move.yFrom = _widgetParentContainer.height;
//			move.play();
			
//			var resize:Resize = new Resize(widgetView);
//			resize.widthTo = 400;
//			resize.widthFrom = 10;
//			resize.heightTo = 300;
//			resize.heightFrom = 10;
//			resize.disableLayout = true;
//			resize.play();
			
//			var spin:Rotate = new Rotate(widgetView);
//			spin.angleBy = 360;
//			spin.play();
			
//			var fade:Fade = new Fade(widgetView);
//			fade.alphaFrom = 0;
//			fade.alphaTo = 1;
//			fade.duration = 2000;
//			fade.play();
			
			widgetView.visible = true;
		}
		
		/**
		 * Converts from the local coordinate system of the "from" component to the local coordinate system of the "to" component.
		 * Will convert values correctly even if the two components are from different stages (different windows). 
		 * @param from Component to use for the "from" the local coordinates  
		 * @param to
		 * @return A point in the coordinat system of the "to" component.
		 * 
		 */
		public static function localToLocal(from:UIComponent, to:UIComponent, fromPoint:Point=null):Point
		{
			if (fromPoint == null)
				fromPoint = new Point(0,0);
			
			var globalPoint:Point = from.localToGlobal(fromPoint);
			
			globalPoint.x += from.stage.nativeWindow.x;
			globalPoint.y += from.stage.nativeWindow.y;
			globalPoint.x -= to.stage.nativeWindow.x;
			globalPoint.y -= to.stage.nativeWindow.y;
			return to.globalToLocal(globalPoint);
		}
		
		private function applyShowFullViewEffects(view:UIComponent, startRect:Rect, shouldResize:Boolean):void
		{
			if (_traceEventHandlers)
				trace(this + ".applyShowFullViewEffects");

			const duration:Number = 1000;
			
			// move to the front and make visible
			var viewParent:IVisualElementContainer = view.parent as IVisualElementContainer
			if (viewParent != null)
				viewParent.setElementIndex(view, viewParent.numElements - 1);
			view.visible = true;
			
			var parallel:Parallel = new Parallel(view);
			var move:Move = new Move(view);
			parallel.addChild(move);
			var fromPosition:Point;
			
			if (startRect != null)
				fromPosition = localToLocal(widgetView, view, new Point(startRect.x, startRect.y));
			else
				fromPosition = localToLocal(widgetView, view);
			
			var toPosition:Point = localToLocal(_fullParentContainer as UIComponent, view);
			
			if (!shouldResize)
			{
				// make the toPosition centered on the _fullParentContainer
				toPosition.x += (_fullParentContainer as UIComponent).width / 2;
				toPosition.y += (_fullParentContainer as UIComponent).height / 2;

				toPosition.x -= view.width / 2;
				toPosition.y -= view.height / 2;
			}
			
			move.xFrom = fromPosition.x;
			move.yFrom = fromPosition.y;
			move.xTo = toPosition.x;
			move.yTo = toPosition.y;
			move.duration = duration;
//			move.addEventListener(EffectEvent.EFFECT_END, showFullViewMoveEndHandler);
			parallel.addEventListener(EffectEvent.EFFECT_END, showFullViewMoveEndHandler);
//			move.play();
			
			if (shouldResize)
			{
				var resize:Resize = new Resize(view);
				parallel.addChild(resize);
				resize.widthFrom = widgetView.width;
				resize.heightFrom = widgetView.height;
				resize.widthTo = (_fullParentContainer as UIComponent).width;
				resize.heightTo = (_fullParentContainer as UIComponent).height;
				resize.addEventListener(EffectEvent.EFFECT_END, showFullViewResizeEndHandler);
				resize.duration = duration;
//				resize.play();
				
				var scale:Scale = new Scale(view);
				parallel.addChild(scale);
				scale.scaleXFrom = resize.widthFrom / resize.widthTo;
				scale.scaleYFrom = resize.heightFrom / resize.heightTo;
				scale.scaleXTo = getEffectiveScaleX(_fullParentContainer as UIComponent);
				scale.scaleYTo = getEffectiveScaleY(_fullParentContainer as UIComponent);
				scale.duration = duration;
//				scale.play();
			}
			
			var fade:Fade = new Fade(view);
			parallel.addChild(fade);
			fade.alphaFrom = 0.5;
			fade.alphaTo = 1;
			fade.duration = duration;
//			fade.play();
			
			parallel.play();
		}
		
		private function getEffectiveScaleX(component:UIComponent):Number
		{
			var current:UIComponent = component;
			
			var scale:Number = 1;
			
			// walk up the component hierarchy to include scale
			while (current != null)
			{
				scale *= current.scaleX;
				current = current.parent as UIComponent;
			}
			
			return scale;
		}
		
		private function getEffectiveScaleY(component:UIComponent):Number
		{
			var current:UIComponent = component;
			
			var scale:Number = 1;
			
			// walk up the component hierarchy to include scale
			while (current != null)
			{
				scale *= current.scaleY;
				current = current.parent as UIComponent;
			}
			
			return scale;
		}
		
		public function showFullView(startRect:Rect):void
		{
			if (canShowFullView())
			{
				showFullViewStart();
				
				showWidgetAsDraggable(false);
				showWidgetAsSelected(true);
				
				var bitmapData:BitmapData = ImageSnapshot.captureBitmapData(fullView);
				
				topSpaceTransitionComponent = createBitmapComponent(bitmapData);
				centerSpaceTransitionComponent = createBitmapComponent(bitmapData);
				
				fullView.visible = false;
//				(fullView.parent as IVisualElementContainer).setElementIndex(fullView, (fullView.parent as IVisualElementContainer).numElements - 1);
				
				var widgetParentContainerComponent:UIComponent = _widgetParentContainer as UIComponent;
				var widgetWindow:Window;
				widgetWindow = Window.getWindow(widgetView) as Window;
				
				// TODO: use a more robust way to distinguish when we are in mobile mode vs. workstation
				if (widgetWindow != null)
				{
					if (topSpaceTransitionComponent != null)
					{
						// TODO: avoid this hack; there should be a cleaner way to get the appropriate container to put the temporary full view into
						// Note that we can't just use _widgetParentContainer.addElement because this container is using a tile layout
						//_widgetParentContainer.addElement(_fullViewFromWidget);
						//((_widgetParentContainer as IVisualElement).parent as IVisualElementContainer).addElement(fullViewFromWidget);
	
						widgetWindow.addElement(topSpaceTransitionComponent);
						
						applyShowFullViewEffects(topSpaceTransitionComponent, startRect, true);
					}
					
					var fullParentContainerComponent:UIComponent = _fullParentContainer as UIComponent;
					var fullWindow:Window;
					fullWindow = Window.getWindow(fullView) as Window;
					
					if (centerSpaceTransitionComponent != null && widgetWindow != fullWindow)
					{
						fullWindow.addElement(centerSpaceTransitionComponent);
						
						applyShowFullViewEffects(centerSpaceTransitionComponent, startRect, true);
					}
				}
				else
				{
					fullView.visible = true;
					hideOtherFullViews();
					showFullViewComplete();
				}
			}
		}
		
		/**
		 * Called at the beginning when showing a full view (before transition animations). Override in subclasses to change behavior for showing full view.
		 */
		protected function showFullViewStart():void
		{
		}
		
		/**
		 * Called at the end when showing a full view (after transition animations). Override in subclasses to change behavior for showing full view.
		 */
		protected function showFullViewComplete():void
		{
		}
		
		private function createBitmapComponent(bitmapData:BitmapData):UIComponent
		{
			var bitmapComponent:UIComponent = new UIComponent();
			bitmapComponent.graphics.lineStyle(0,0,0);
			bitmapComponent.graphics.beginBitmapFill(bitmapData, null, false, true);
			bitmapComponent.graphics.drawRect(0, 0, bitmapData.width, bitmapData.height);
			return bitmapComponent;
		}
		
		private var _traceEventHandlers:Boolean = false;

		public function showFullViewMoveEndHandler(event:EffectEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".showFullViewMoveEndHandler");

			fullView.alpha = 1;
			fullView.visible = true;
			
			hideOtherFullViews();
			
//			fullView.percentWidth = 100;
//			fullView.percentHeight = 100;
//			fullView.width = NaN;
//			fullView.height = NaN;
			
			// make sure the view is on top of any siblings
//			(fullView.parent as IVisualElementContainer).setElementIndex(fullView, (fullView.parent as IVisualElementContainer).numElements - 1);
			
			// make sure the parent resizes the full view immediately; otherwise, the contents of the full view can get sized incorrectly
//			(fullView.parent as UIComponent).validateNow();
			
			removeFromParent(topSpaceTransitionComponent);
			topSpaceTransitionComponent = null;
			
			removeFromParent(centerSpaceTransitionComponent);
			centerSpaceTransitionComponent = null;
			
			showFullViewComplete();
		}
		
		private function hideOtherFullViews():void
		{
			var fullViewParent:IVisualElementContainer = (fullView.parent as IVisualElementContainer);
			for (var i:int = 0; i < fullViewParent.numElements; i++)
			{
				var child:IUIComponent = fullViewParent.getElementAt(i) as IUIComponent;
				if (child != null && child != fullView)
				{
					child.visible = false;
				}
			}
		}

		public function showFullViewResizeEndHandler(event:EffectEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".showFullViewResizeEndHandler");
		}
		
		public function hideFullView():void
		{
			showWidgetAsDraggable(fullView != null);
			showWidgetAsSelected(false);
			if (fullView != null && fullView.visible)
			{
//				var move:Move = new Move(fullView);
//				move.xFrom = 0;
//				move.xTo = (_fullParentContainer as UIComponent).width / 2;
//				move.yFrom = 0;
//				move.yTo = -(_fullParentContainer as UIComponent).height;
//				move.play();
//				
//				var resize:Resize = new Resize(fullView);
//				resize.widthFrom = (_fullParentContainer as UIComponent).width;
//				resize.widthTo = SHRINK_WIDTH;
//				resize.heightFrom = (_fullParentContainer as UIComponent).height;
//				resize.heightTo = SHRINK_HEIGHT;
//				resize.play();

				var fade:Fade = new Fade(fullView);
				fade.alphaFrom = 1;
				fade.alphaTo = 1;
				fade.duration = 1500;
				fade.play();
				fade.addEventListener(EffectEvent.EFFECT_END, hideFullViewFadeEndHandler);
			}
			else
			{
				//trace("hideFullView() called but fullView is null");
			}
		}

		public function hideFullViewFadeEndHandler(event:EffectEvent):void
		{
			fullView.visible = false;
			hideFullViewComplete();
		}
		
		/**
		 * Called after hidding the full view is complete. Override in subclasses to change behavior for hidding full view. 
		 */
		protected function hideFullViewComplete():void
		{
		}
		
		public function close():void
		{
			// TODO: ensure that the views are completely destructed and removed from memory (remove and references, event listeners)
			
			if(widgetView.parent != null)
			{
				if (widgetView.parent is IVisualElementContainer)
					(widgetView.parent as IVisualElementContainer).removeElement(widgetView);
				else
					widgetView.parent.removeChild(widgetView);
			}
			
			if(fullView != null && fullView.parent != null)
			{
				if (fullView.parent is IVisualElementContainer)
					(fullView.parent as IVisualElementContainer).removeElement(fullView);
				else
					fullView.parent.removeChild(fullView);
			}
		}
		
		/**
		 * Initializes the app. Called after standard properties (healthRecordService, user, etc) are set so
		 * that the app can be prepared for use. 
		 */
		public function initialize():void
		{
			if (widgetView)
			{
				widgetView.addEventListener("dragStart", dragStartHandler);
				widgetView.addEventListener("dragEnd", dragEndHandler);
			}
		}
		
		private function dragStartHandler(event:Event):void
		{
			var widgetParentContainerGroup:Group = _widgetParentContainer as Group;
			// turn off tiling
			if (widgetParentContainerGroup != null)
			{
				var moveComponent:UIComponent = event.target as UIComponent;
				if (moveComponent != null && !(widgetParentContainerGroup.layout is BasicLayout))
				{
					_widgetParentContainerLayout = widgetParentContainerGroup.layout; 
					widgetParentContainerGroup.layout = new BasicLayout();
					
					// move above all others
					if (widgetParentContainerGroup == moveComponent.parent)
					{
						var index:int = widgetParentContainerGroup.getChildIndex(moveComponent);
						var last:int = widgetParentContainerGroup.numChildren - 1;
						if (index != last)
						{
							widgetParentContainerGroup.setElementIndex(moveComponent, last);
						}
					}
				}
			}
		}
		
		private function dragEndHandler(event:Event):void
		{
			var widgetParentContainerGroup:Group = _widgetParentContainer as Group;
			// set an appropriate index based on the new position and re-enable the tile layout
			if (widgetParentContainerGroup != null)
			{
				var moveComponent:UIComponent = event.target as UIComponent;
				if (moveComponent != null)
				{
					var minDistance:Number = Number.MAX_VALUE;
					var moveToIndex:int = -1;
					for (var index:int = 0; index < _widgetParentContainer.numElements; index++)
					{
						var tiledComponent:UIComponent = _widgetParentContainer.getElementAt(index) as UIComponent;
						if (tiledComponent != null)
						{
							var distance:Number = distanceFrom(moveComponent, tiledComponent);
							if (tiledComponent != moveComponent && Math.abs(distance) < Math.abs(minDistance))
							{
								minDistance = distance;
								if (distance > 0)
									moveToIndex = index + 1;
								else
									moveToIndex = index;
							}
						}
					}
					
					if (moveToIndex != -1)
						_widgetParentContainer.setElementIndex(moveComponent, moveToIndex);
				}
				
				// TODO: remove this hack
				widgetParentContainerGroup.layout = _widgetParentContainerLayout;
//				((_widgetParentContainer as UIComponent).parent.parent as TopSpace).enableContainerLayout();
			}
		}
		
		private function distanceFrom(moveComponent:UIComponent, tiledComponent:UIComponent):int
		{
			// in the same row?
			if (moveComponent.y >= tiledComponent.y && moveComponent.y <= tiledComponent.y + tiledComponent.height)
			{
				return moveComponent.x - (tiledComponent.x + (tiledComponent.width / 2));
			}
			else
			{
				return Number.MAX_VALUE;
			}
		}
		
		public function reloadUserData():void
		{
			// to be implemented by subclasses
		}
	}
}