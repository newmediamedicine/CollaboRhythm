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
package collaboRhythm.shared.controller.apps
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.IApplicationNavigationProxy;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionService;
	import collaboRhythm.shared.model.services.IComponentContainer;
	import collaboRhythm.shared.model.settings.Settings;
	import collaboRhythm.shared.view.BitmapCopyComponent;

	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;

	import mx.controls.Image;
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.effects.Parallel;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.graphics.ImageSnapshot;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.DragManager;

	import spark.components.Application;
	import spark.components.Button;
	import spark.components.View;
	import spark.components.ViewNavigator;
	import spark.components.ViewNavigatorApplication;
	import spark.components.Window;
	import spark.effects.*;
	import spark.primitives.Rect;

	/**
	 * Represents an instance of a CollaboRhythm app which can be used to view and/or manipulate some aspect of a health record
	 * in a collaborative (or solo) work session. CollaboRhythm apps can have a mini "widget" view and a larger "full"
	 * view. They can also use the ViewNavigator (currently in Tablet mode only) to navigate to
	 * spark.componenets.View instances that they create.
	 */
	public class AppControllerBase extends EventDispatcher
	{
		public static const WIDGET_WATERMARK_ALPHA:Number = 0.2;
		public static const DEBUG_BUTTON_ALPHA:Number = 0.2;
		public static const DEBUG_BUTTON_VISIBLE:Boolean = false;
		public static const PREVENT_RE_SHOWING_FULL_VIEW:Boolean = true;

		protected var _widgetContainer:IVisualElementContainer;
		protected var _fullContainer:IVisualElementContainer;

		private var _topSpaceTransitionComponent:UIComponent;
		private var _centerSpaceTransitionComponent:UIComponent;

		private var _name:String;
		private var _modality:String;
		protected var _activeAccount:Account;
		protected var _activeRecordAccount:Account;
		protected var _settings:Settings;
		protected var _componentContainer:IComponentContainer;
		protected var _collaborationLobbyNetConnectionService:ICollaborationLobbyNetConnectionService;
		protected var _viewNavigator:ViewNavigator;
		protected var _primaryShowFullViewParallelEffect:Parallel;
		protected var _secondaryShowFullViewParallelEffect:Parallel;
		private var _isWidgetViewPrepared:Boolean = false;
		private var _isFullViewPrepared:Boolean = false;

		protected var _logger:ILogger;

		private var _traceEventHandlers:Boolean = false;
		private var _cacheFullView:Boolean = false;

		private var _createFullViewOnInitialize:Boolean = false;
		protected var _navigationProxy:IApplicationNavigationProxy;
		private var _fullViewTitle:String;

		public function AppControllerBase(constructorParams:AppControllerConstructorParams)
		{
			_logger = Log.getLogger(getQualifiedClassName(this).replace("::", "."));

			_widgetContainer = constructorParams.widgetContainer;
			_fullContainer = constructorParams.fullContainer;
			_modality = constructorParams.modality;
			_activeAccount = constructorParams.activeAccount;
			_activeRecordAccount = constructorParams.activeRecordAccount;
			_settings = constructorParams.settings;
			_componentContainer = constructorParams.componentContainer;
			_collaborationLobbyNetConnectionService = constructorParams.collaborationLobbyNetConnectionService;
			_viewNavigator = constructorParams.viewNavigator;
			_navigationProxy = constructorParams.navigationProxy;

			name = defaultName;

			initializeShowFullViewParallelEffects();

			createAndPrepareWidgetView();

			if (widgetView)
				showWidgetAsDraggable(fullView != null);

		}

		public function get isWorkstationMode():Boolean
		{
			return _modality == Settings.MODALITY_WORKSTATION;
		}

		public function get isMobileMode():Boolean
		{
			return _modality == Settings.MODALITY_MOBILE;
		}

		public function get isTabletMode():Boolean
		{
			return _modality == Settings.MODALITY_TABLET;
		}

		public function createAndPrepareWidgetView():void
		{
			if (_widgetContainer && !widgetView)
			{
				widgetView = createWidgetView();
				this.prepareWidgetView();
			}
		}

		public function get widgetContainer():IVisualElementContainer
		{
			return _widgetContainer;
		}

		public function set widgetContainer(value:IVisualElementContainer):void
		{
			_widgetContainer = value;
		}

		public function get defaultName():String
		{
			return null;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
			updateFullViewTitle();
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

		/**
		 * Factory method to create the one and only instance of the widget view associated with this app.
		 * Note that this instance will be used as the main instance corresponding to the "widgetView" property.
		 * The widget view does not need be initialized or prepared in any way by createWidgetView. A subsequent call to
		 * prepareWidgetView will take care of this.
		 * @return the new instance of the corresponding widget view component
		 */
		protected function createWidgetView():UIComponent
		{
			return null;
		}

		/**
		 * Factory method to create the one and only instance of the full view associated with this app.
		 * Note that this instance will be used as the main instance corresponding to the "fullView" property.
		 * The full view does not need be initialized or prepared in any way by createFullView. A subsequent call to
		 * prepareFullView will take care of this.
		 * @return the new instance of the corresponding full view component
		 */
		protected function createFullView():UIComponent
		{
			return null;
		}

		/**
		 * Prepares the widget view for use when it is first created. The view
		 * should be added to the appropriate parent container, and should respond to mouse events appropriately.
		 * The widgetView should be hidden initially so that it can be initialized and ready before is is subsequently shown.
		 * The updateWidgetViewModel method will be called to initialize the view with any required model or data.
		 * Subclasses should NOT generally need to override this method but should override updateWidgetViewModel
		 * instead to initialize data that the view needs.
		 */
		protected function prepareWidgetView():void
		{
			if (widgetView != null && !_isWidgetViewPrepared)
			{
				updateWidgetViewModel();
				widgetView.addEventListener(MouseEvent.CLICK, widgetClickHandler);
				widgetView.addEventListener(MouseEvent.MOUSE_DOWN, widgetMouseDownHandler);

				widgetView.visible = false;
				_widgetContainer.addElement(widgetView);
				_isWidgetViewPrepared = true;
			}
		}

		/**
		 * Initializes the widgetView with any required model or data.
		 * Subclasses should override this method to initialize the view appropriately.
		 * This method is called both when the widgetView is initially created and prepared, and when/if the data
		 * is reloaded (such as when changing the demo date).
		 */
		protected function updateWidgetViewModel():void
		{
		}

		/**
		 * Prepares the fullView for use when it is first created. The view
		 * should be added to the appropriate parent container, and should respond to mouse events appropriately.
		 * The fullView should be hidden initially so that it can be initialized and ready before is is subsequently shown.
		 * The updateFullViewModel method will be called to initialize the view with any required model or data.
		 * Subclasses should NOT generally need to override this method but should override updateFullViewModel
		 * instead to initialize data that the view needs.
		 */
		protected function prepareFullView():void
		{
			if (fullView != null && !_isFullViewPrepared)
			{
				updateFullViewModel();
				_primaryShowFullViewParallelEffect.stop();
				_secondaryShowFullViewParallelEffect.stop();
				fullView.visible = false;
				if (fullView.parent == null && _fullContainer)
					_fullContainer.addElement(fullView);
				_isFullViewPrepared = true;
			}
		}

		/**
		 * Initializes the fullView with any required model or data.
		 * Subclasses should override this method to initialize the view appropriately.
		 * This method is called both when the fullView is initially created and prepared, and when/if the data
		 * is reloaded (such as when changing the demo date).
		 */
		protected function updateFullViewModel():void
		{
		}

		public function get isFullViewSupported():Boolean
		{
			return false;
		}

		public function canShowFullView():Boolean
		{
			if (!isFullViewSupported || (topSpaceTransitionComponent != null && topSpaceTransitionComponent.visible))
				return false;

			if (PREVENT_RE_SHOWING_FULL_VIEW)
			{
				var selected:Boolean = widgetView && widgetView.getStyle("selected") as Boolean;
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
					dragSource.addData(new AppDragData(mouseEvent),
									   AppDragData.DRAG_SOURCE_DATA_FORMAT);

					// ask the DragManger to begin the drag
					DragManager.doDrag(dragInitiator, dragSource, mouseEvent,
									   BitmapCopyComponent.createFromComponent(this.widgetView));
				}
			}
		}

		public function showWidgetAsDraggable(value:Boolean):void
		{
			if (widgetView)
				widgetView.setStyle("dropShadowVisible", value);
		}

		public function showWidgetAsSelected(value:Boolean):void
		{
			if (widgetView)
				widgetView.setStyle("selected", value);
		}

		public function makeDroppable(component:IUIComponent):void
		{
			// a dragEnter event occurs when a draggable is over a droppable
			component.addEventListener(DragEvent.DRAG_ENTER, allowDrop);

			// a dragDrop event occurs when a draggable is dropped
			component.addEventListener(DragEvent.DRAG_DROP, acceptDrop);

			component.addEventListener(DragEvent.DRAG_EXIT, dragExitHandler);

			component.addEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
		}

		public function dragCompleteHandler(dragEvent:DragEvent):void
		{
			var dragSource:DragSource = dragEvent.dragSource;
			var dragInitiator:IUIComponent = dragEvent.dragInitiator;
			var dropTarget:Object = dragEvent.currentTarget;

			trace("Drag Complete (" + dragInitiator.name + ") to (" + dropTarget.name + ") " + dragEvent.delta);

			var data:AppDragData = dragSource.dataForFormat(AppDragData.DRAG_SOURCE_DATA_FORMAT) as AppDragData;
			var startRect:Rect;
			if (data != null)
			{
				startRect = new Rect();
				startRect.x = dragEvent.localX - data.mouseEvent.localX;
				startRect.y = dragEvent.localY - data.mouseEvent.localY;

			}
			this.dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this, startRect, null, "widget drag complete"));
		}

		public function dragExitHandler(dragEvent:DragEvent):void
		{
			var dragSource:DragSource = dragEvent.dragSource;
			var dragInitiator:IUIComponent = dragEvent.dragInitiator;
			var dropTarget:Object = dragEvent.currentTarget;

			trace("Drag Exit (" + dragInitiator.name + ") to (" + dropTarget.name + ")");
		}

		public function allowDrop(dragEvent:DragEvent):void
		{
			// the drop target
			var dropTarget:IUIComponent = dragEvent.currentTarget as IUIComponent;

			// signal to the drop manager that this will accept the item
			DragManager.acceptDragDrop(dropTarget);

			DragManager.showFeedback(DragManager.MOVE);
		}

		public function acceptDrop(dragEvent:DragEvent):void
		{
			var dragSource:DragSource = dragEvent.dragSource;
			var dragInitiator:IUIComponent = dragEvent.dragInitiator;
			var dropTarget:Object = dragEvent.currentTarget;

			trace("Dragged (" + dragInitiator.name + ") to (" + dropTarget.name + ") and Dropped");
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
				this.dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this, null, null, "widget double click"));
		}

		protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return isWorkstationMode || isTabletMode;
		}

		private function widgetClickHandler(event:MouseEvent):void
		{
			if (shouldShowFullViewOnWidgetClick && canShowFullView() && isShowFullViewClickEvent(event))
				this.dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this, null, null, "widget click"));
		}

		private function isShowFullViewClickEvent(event:MouseEvent):Boolean
		{
			// ignore all events for buttons (such as buttons in scroll bars)
			if (event.target is Button || event.target is mx.controls.Button)
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
			return _widgetContainer;
		}

		public function set parentContainer(value:IVisualElementContainer):void
		{
			_widgetContainer = value;
		}

		public function showWidget(left:Number = -1, top:Number = -1):Boolean
		{
			if (widgetView)
			{
				if (left != -1 && top != -1)
					widgetView.move(left, top);

				widgetView.visible = true;
				return true;
			}
			return false;
		}

		/**
		 * Converts from the local coordinate system of the "from" component to the local coordinate system of the "to" component.
		 * Will convert values correctly even if the two components are from different stages (different windows).
		 * @param from Component to use for the "from" the local coordinates
		 * @param to
		 * @return A point in the coordinate system of the "to" component.
		 *
		 */
		public static function localToLocal(from:UIComponent, to:UIComponent, fromPoint:Point = null):Point
		{
			if (fromPoint == null)
				fromPoint = new Point(0, 0);

			var globalPoint:Point = from.localToGlobal(fromPoint);

			// TODO: Determine why to.stage is null
			if (from.stage != to.stage && from.stage.nativeWindow)
			{
				globalPoint.x += from.stage.nativeWindow.x;
				globalPoint.y += from.stage.nativeWindow.y;
				globalPoint.x -= to.stage.nativeWindow.x;
				globalPoint.y -= to.stage.nativeWindow.y;
			}
			return to.globalToLocal(globalPoint);
		}

		private function applyShowFullViewEffects(parallel:Parallel, view:UIComponent, startRect:Rect,
												  shouldResize:Boolean):void
		{
			if (_traceEventHandlers)
				trace(this + ".applyShowFullViewEffects");

			const duration:Number = 1000;

			parallel.stop();

			// move to the front and make visible
			var viewParent:IVisualElementContainer = view.parent as IVisualElementContainer;
			if (viewParent != null)
				viewParent.setElementIndex(view, viewParent.numElements - 1);
			view.visible = true;

			parallel.target = view;
			parallel.children = new Array();

			var move:Move = new Move(view);
			parallel.addChild(move);
			var fromPosition:Point;

			if (startRect != null)
				fromPosition = localToLocal(widgetView, view, new Point(startRect.x, startRect.y));
			else
				fromPosition = localToLocal(widgetView, view);

			var startRectLocal:Rect = new Rect();
			startRectLocal.x = fromPosition.x;
			startRectLocal.y = fromPosition.y;

			if (shouldResize)
			{
				startRectLocal.width = widgetView.width;
				startRectLocal.height = widgetView.height;

				shrinkRectToAspectRatio(startRectLocal, fullView);
			}

			var toPosition:Point = localToLocal(_fullContainer as UIComponent, view);

			if (!shouldResize)
			{
				// make the toPosition centered on the _fullParentContainer
				toPosition.x += (_fullContainer as UIComponent).width / 2;
				toPosition.y += (_fullContainer as UIComponent).height / 2;

				toPosition.x -= view.width / 2;
				toPosition.y -= view.height / 2;
			}

			move.xFrom = startRectLocal.x;
			move.yFrom = startRectLocal.y;
			move.xTo = toPosition.x;
			move.yTo = toPosition.y;
			move.duration = duration;

			if (shouldResize)
			{
				var resize:Resize = new Resize(view);
				parallel.addChild(resize);
				resize.widthFrom = startRectLocal.width;
				resize.heightFrom = startRectLocal.height;
				resize.widthTo = (_fullContainer as UIComponent).width;
				resize.heightTo = (_fullContainer as UIComponent).height;
				resize.duration = duration;
//				resize.play();

				var scale:Scale = new Scale(view);
				parallel.addChild(scale);
				scale.scaleXFrom = resize.widthFrom / resize.widthTo;
				scale.scaleYFrom = resize.heightFrom / resize.heightTo;
				scale.scaleXTo = getEffectiveScaleX(_fullContainer as UIComponent);
				scale.scaleYTo = getEffectiveScaleY(_fullContainer as UIComponent);
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

		private function initializeShowFullViewParallelEffects():void
		{
			_primaryShowFullViewParallelEffect = new Parallel();
			_primaryShowFullViewParallelEffect.addEventListener(EffectEvent.EFFECT_END,
																primaryShowFullViewParallelEffect_effectEndHandler,
																false, 0, true);
			_secondaryShowFullViewParallelEffect = new Parallel();
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

		/**
		 * Shows the full view for this app, if possible.
		 * @param startRect the starting rect for showing the transition animation
		 * @return true if the full view was shown
		 */
		public function showFullView(startRect:Rect):Boolean
		{
			var result:Boolean;

			if (_fullContainer && fullView == null)
			{
				fullView = createFullView();
				this.prepareFullView();
			}

			if (canShowFullView())
			{
				showFullViewStart();

				showWidgetAsDraggable(false);
				showWidgetAsSelected(true);

				_primaryShowFullViewParallelEffect.stop();
				_secondaryShowFullViewParallelEffect.stop();

				if (isWorkstationMode)
				{
//					fullView.validateNow();
					var bitmapData:BitmapData = ImageSnapshot.captureBitmapData(fullView);

					topSpaceTransitionComponent = BitmapCopyComponent.createFromBitmap(bitmapData, fullView);
					centerSpaceTransitionComponent = BitmapCopyComponent.createFromBitmap(bitmapData, fullView);

					fullView.visible = false;
					var widgetTransitionComponentContainer:IVisualElementContainer = getTransitionComponentContainer(widgetView);

					if (topSpaceTransitionComponent != null)
					{
						widgetTransitionComponentContainer.addElement(topSpaceTransitionComponent);

						applyShowFullViewEffects(_primaryShowFullViewParallelEffect, topSpaceTransitionComponent,
												 startRect, true);
					}

					var fullTransitionComponentContainer:IVisualElementContainer = getTransitionComponentContainer(fullView);

					if (centerSpaceTransitionComponent != null && widgetTransitionComponentContainer != fullTransitionComponentContainer)
					{
						fullTransitionComponentContainer.addElement(centerSpaceTransitionComponent);

						applyShowFullViewEffects(_secondaryShowFullViewParallelEffect, centerSpaceTransitionComponent,
												 startRect, true);
					}
				}
				else
				{
					if (cacheFullView)
					{
						if (centerSpaceTransitionComponent == null)
						{
							takeFullViewSnapshot();
						}
						if (_viewNavigator)
						{
							prepareFullViewContainer(fullContainer as View);
							_viewNavigator.addEventListener("viewChangeComplete", viewNavigator_viewChangeCompleteHandler, false, 0, true);
						}
						fullContainer.addElement(centerSpaceTransitionComponent);
					}
					else
					{
						if (!fullView.parent)
						{
//						removeFromParent(fullView);
							fullContainer.addElement(fullView);
						}
						fullView.visible = true;
					}
					hideOtherFullViews();
					showFullViewComplete();
				}

				result = true;
			}
			return result;
		}

		private function viewNavigator_viewChangeCompleteHandler(event:Event):void
		{
			fullContainer.addElement(fullView);
			fullView.visible = true;
			fullView.includeInLayout = true;
			centerSpaceTransitionComponent = null;
			_viewNavigator.removeEventListener("viewChangeComplete", viewNavigator_viewChangeCompleteHandler);
		}

		protected function prepareFullViewContainer(view:View):void
		{

		}

		private function shrinkRectToAspectRatio(rect:Rect, targetView:UIComponent):void
		{
			if (rect.height > 0 && targetView.height > 0)
			{
				var rectRatio:Number = rect.width / rect.height;
				var targetRatio:Number = targetView.width / targetView.height;

				if (targetRatio > rectRatio)
				{
					// target is wider, so reduce rect height
					var newHeight:Number = rect.width / targetRatio;
					rect.y += (rect.height - newHeight) / 2;
					rect.height = newHeight;
				}
				else
				{
					// target is taller, so reduce rect width
					var newWidth:Number = rect.height * targetRatio;
					rect.x += (rect.width - newWidth) / 2;
					rect.width = newWidth;
				}
			}
		}

		private function getTransitionComponentContainer(widgetView:UIComponent):IVisualElementContainer
		{
			//TODO: Is there a simpler way than looping through all of the display hierarchy? can be be more explicit?
			var previousContainer:DisplayObjectContainer;
			var container:DisplayObjectContainer = widgetView.parent;
			if (!container)
				throw new Error("Failed to find a container to put the transition component in");

			while (container.parent != null && !(container is Window) && !(container is Application) && !(container.parent is ViewNavigatorApplication))
			{
				previousContainer = container;
				container = container.parent;
			}

			if (container is IVisualElementContainer)
				return container as IVisualElementContainer;
			else if (previousContainer is IVisualElementContainer)
				return previousContainer as IVisualElementContainer;
			else
				throw new Error("Failed to find a IVisualElementContainer to put the transition component in");
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

		public function primaryShowFullViewParallelEffect_effectEndHandler(event:EffectEvent):void
		{
			if (_traceEventHandlers)
				trace(this + ".primaryShowFullViewParallelEffect_effectEndHandler");

			fullView.alpha = 1;
			fullView.visible = true;

			hideOtherFullViews();

			removeFromParent(topSpaceTransitionComponent);
			topSpaceTransitionComponent = null;

			removeFromParent(centerSpaceTransitionComponent);
			centerSpaceTransitionComponent = null;

			showFullViewComplete();
		}

		private function hideOtherFullViews():void
		{
			var fullViewParent:IVisualElementContainer = (fullView.parent as IVisualElementContainer);
			if (fullViewParent)
			{
				for (var i:int = 0; i < fullViewParent.numElements; i++)
				{
					var child:IUIComponent = fullViewParent.getElementAt(i) as IUIComponent;
					if (child != null && child != fullView)
					{
						child.visible = false;
					}
				}
			}
		}

		public function hideFullView():Boolean
		{
			var result:Boolean;

			_primaryShowFullViewParallelEffect.stop();
			_secondaryShowFullViewParallelEffect.stop();

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

				// Use an effect to keep this fullView visible while showing the next full view (of another app)
				if (isWorkstationMode)
				{
					var fade:Fade = new Fade(fullView);
					fade.alphaFrom = 1;
					fade.alphaTo = 1;
					fade.duration = 1500;
					fade.play();
					fade.addEventListener(EffectEvent.EFFECT_END, hideFullViewFadeEndHandler, false, 0, true);
				}
				else
				{
					if (_viewNavigator)
					{
						// TODO: implement a more robust way of determining the correct navigation behavior
						if (_viewNavigator.length > 1)
							_viewNavigator.popToFirstView();
					}
					else
					{
						fullView.visible = false;
					}
					hideFullViewComplete();
				}
				result = true;
			}
			else
			{
				//trace("hideFullView() called but fullView is null");
			}
			return result;
		}

		public function hideFullViewFadeEndHandler(event:EffectEvent):void
		{
			fullView.visible = false;
			hideFullViewComplete();
		}

		/**
		 * Called after hiding the full view is complete. Override in subclasses to change behavior for hiding full view.
		 */
		protected function hideFullViewComplete():void
		{
		}

		/**
		 * Removes the widget and full views from their respective parents and sets the corresponding references to null
		 * to allow for garbage collection. This method is called when the view(s) for the app are no longer needed.
		 * Any model or view state data that this app needs (perhaps in user.appData) should NOT be removed here because
		 * the view(s) may be subsequently re-created and their state should be restored if this happens.
		 * <p>
		 * Subclasses may override this and provide additional cleanup if required
		 * before or after super.destroyViews().
		 *
		 */
		public function destroyViews():void
		{
			// TODO: ensure that the views are completely destructed and removed from memory (remove and references, event listeners)
			_primaryShowFullViewParallelEffect.stop();
			_secondaryShowFullViewParallelEffect.stop();

			destroyWidgetView();
			destroyFullView();
		}

		/**
		 * Hides (if cacheFullView is true) or destroys the full view.
		 */
		public function closeFullView():void
		{
			if (_cacheFullView)
			{
				takeFullViewSnapshot();
				hideFullView();
			}
			else
				destroyFullView();
		}

		protected function takeFullViewSnapshot():void
		{
			if (fullView)
			{
				_logger.debug("takeFullViewSnapshot " + fullView.className);
				centerSpaceTransitionComponent = BitmapCopyComponent.createFromComponent(fullView);
			}
		}

		public function destroyFullView():void
		{
			if (fullView != null && fullView.parent != null)
			{
				if (fullView.parent is IVisualElementContainer)
					(fullView.parent as IVisualElementContainer).removeElement(fullView);
				else
					fullView.parent.removeChild(fullView);
			}

			if (fullView)
			{
				fullView.accessibilityProperties = null;
				fullView = null;
			}

			_isFullViewPrepared = false;
		}

		public function destroyWidgetView():void
		{
			if (widgetView != null && widgetView.parent != null)
			{
				if (widgetView.parent is IVisualElementContainer)
					(widgetView.parent as IVisualElementContainer).removeElement(widgetView);
				else
					widgetView.parent.removeChild(widgetView);

			}

			if (widgetView)
			{
				widgetView.removeEventListener(MouseEvent.CLICK, widgetClickHandler);
				widgetView.removeEventListener(MouseEvent.MOUSE_DOWN, widgetMouseDownHandler);
				widgetView.accessibilityProperties = null;
				widgetView = null;
			}

			_isWidgetViewPrepared = false;
		}

		/**
		 * Initializes this instance of AppControllerBase (app), and if they have been created, the
		 * widgetView and/or fullView of this app. This method is called after the standard properties
		 * (healthRecordService, activeRecordAccount, etc) of the app are set so that the app can prepare itself for use.
		 * Subclasses should override this method to implement appropriate initialization. This method is only ever
		 * called once for each app instance.
		 */
		public function initialize():void
		{
		}

		/**
		 * Reloads or resets the model data that this app owns (if any). Note that this method is primarily used for
		 * changing the current demo time, so reloadUserData should reload the appropriate data on the record respecting
		 * the ICurrentDateSource.now() time.
		 * Subclasses should override this method to reload or reset any data that the view owns and then update
		 * the widgetView and fullView, if necessary.
		 */
		public function reloadUserData():void
		{
			if (widgetView)
				updateWidgetViewModel();

			if (fullView)
				updateFullViewModel();
		}

		/**
		 * Closes the any views the app owns and removes and data the app owns from the current record.
		 * Apps do not generally need to override this method, but should instead override removeUserData().
		 * Note that only data and views owned directly by this app should be affected by this method.
		 */
		public function close():void
		{
			destroyViews();
			removeUserData();
		}

		/**
		 * Removes any references to user data owned by this app on the Record object.
		 * This is called when closing the user/record and/or when closing or reloading the whole application.
		 * <p>
		 * Subclasses should override this method if they have added any data to the Record/Account, such as on Record.appData.
		 */
		protected function removeUserData():void
		{
			// to be implemented by subclasses
		}

		public function get appClassName():String
		{
			return getQualifiedClassName(this);
		}

		public function get activeAccount():Account
		{
			return _activeAccount;
		}

		public function set activeAccount(value:Account):void
		{
			_activeAccount = value;
		}

		public function get activeRecordAccount():Account
		{
			return _activeRecordAccount;
		}

		public function set activeRecordAccount(value:Account):void
		{
			_activeRecordAccount = value;
		}

		public function get isWidgetViewPrepared():Boolean
		{
			return _isWidgetViewPrepared;
		}

		public function get isFullViewPrepared():Boolean
		{
			return _isFullViewPrepared;
		}

		public function get modality():String
		{
			return _modality;
		}

		public function set modality(value:String):void
		{
			_modality = value;
		}

		public function get appId():String
		{
			return appClassName;
		}

		public function get fullContainer():IVisualElementContainer
		{
			return _fullContainer;
		}

		public function set fullContainer(value:IVisualElementContainer):void
		{
			_fullContainer = value;
		}

		public function get cacheFullView():Boolean
		{
			return _cacheFullView;
		}

		public function set cacheFullView(value:Boolean):void
		{
			_cacheFullView = value;
		}

		public function dispatchShowFullView(viaMechanism:String):void
		{
			dispatchEvent(new AppEvent(AppEvent.SHOW_FULL_VIEW, this, null, null, viaMechanism));
		}

		protected function listenForFullViewUpdateComplete():void
		{
			fullView.addEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler, false, 0, true);
		}

		private function fullView_updateCompleteHandler(event:FlexEvent):void
		{
			if (doneUpdating(fullView))
			{
				takeFullViewSnapshot();
				removeFromParent(fullView);
				fullView.visible = false;
				fullView.removeEventListener(FlexEvent.UPDATE_COMPLETE, fullView_updateCompleteHandler);
			}
		}

		private function doneUpdating(fullView:UIComponent):Boolean
		{
			if (fullView == null)
				return false;

			if (fullView.hasOwnProperty("doneUpdating"))
			{
				return fullView["doneUpdating"];
			}
			else
			{
				return true;
			}
		}

		protected function get shouldPreCreateFullView():Boolean
		{
			return !fullView && _createFullViewOnInitialize && cacheFullView && isFullViewSupported;
		}

		protected function doPrecreationForFullView():void
		{
			if (shouldPreCreateFullView)
			{
				createFullView();
				prepareFullView();

				// special handling to get a bitmap snapshot of the fullView so we can do a quick transition the first time it is shown
				if (isTabletMode)
				{
					listenForModelInitialized();
					if (_viewNavigator)
					{
						_viewNavigator.activeView.addElement(fullView);
					}
				}
			}
		}

		protected function listenForModelInitialized():void
		{
		}

		protected function get createFullViewOnInitialize():Boolean
		{
			return _createFullViewOnInitialize;
		}

		protected function set createFullViewOnInitialize(value:Boolean):void
		{
			_createFullViewOnInitialize = value;
		}

		protected function updateFullViewTitle():void
		{
			_fullViewTitle = name;
		}

		public function get fullViewTitle():String
		{
			return _fullViewTitle;
		}

		public function set fullViewTitle(value:String):void
		{
			_fullViewTitle = value;
		}
	}
}