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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ICollectionView;
	import mx.controls.DataGrid;
	import mx.core.UIComponent;
	import mx.events.ScrollEvent;
	import mx.events.ScrollEventDetail;
	import mx.events.ScrollEventDirection;
	
	/**
	 * DataGrid component with the addition of smooth scrolling (instead of the standard incremental scrolling).
	 * 
	 * <p>Based on code by Alex Harui found here:
	 * <a href="http://blogs.adobe.com/aharui/2008/03/smooth_scrolling_list.html">http://blogs.adobe.com/aharui/2008/03/smooth_scrolling_list.html</a></p> 
	 * 
	 * @author sgilroy
	 */
	public class SmoothScrollingDataGrid extends DataGrid
	{
		public function SmoothScrollingDataGrid()
		{
			super();
			offscreenExtraRowsOrColumns = 2;
		}
		
		override protected function configureScrollBars():void
		{
			super.configureScrollBars();
			
			if (verticalScrollBar != null)
			{
				//setScrollBarProperties(listContent.width, this.width, ((this.dataProvider as ICollectionView).length) * rowHeight, this.height);
				var contentHeight:Number = (this.dataProvider as ICollectionView).length * rowHeight;

				// if contentHeight < scrollAreaHeight (nowhere to scroll to) then max = 0
				var maxScrollPosition:Number = Math.max(0, (contentHeight - scrollAreaHeight) / rowHeight);
				
				// only update the maxScrollPosition
				verticalScrollBar.setScrollProperties(verticalScrollBar.pageSize, verticalScrollBar.minScrollPosition, maxScrollPosition, verticalScrollBar.pageScrollSize); 
			}
			
			// TODO: fix maxHorizontalScrollPosition
			
			if (verticalScrollBar)
				verticalScrollBar.lineScrollSize = .125;  // should be inverse power of 2
		}
		
		protected function get scrollAreaHeight():Number
		{
			// TODO: test with non-zero values of viewMetrics.top and listContent.topOffset (horizontal scroll bar?)
			
//			var scrollAreaHeight:Number = this.height - viewMetrics.top - listContent.topOffset;
			var scrollAreaHeight:Number = this.height - viewMetrics.top;
			if (header.visible)
				scrollAreaHeight -= header.height;
			
			return scrollAreaHeight;
		}

		override protected function scrollHandler(event:Event):void
		{           
			if (event is ScrollEvent)
			{
				var scrollEvent:ScrollEvent = ScrollEvent(event);
				if (scrollEvent.direction == ScrollEventDirection.HORIZONTAL)
				{
					if (horizontalScrollBar.numChildren == 4)
					{
						// Override the default scroll behavior to provide smooth horizontal scrolling and not the usual "snap-to-column" behavior
						// Get individual components of a scroll bar for measuring and get a horizontal position to use
						var rightArrow:DisplayObject = horizontalScrollBar.getChildAt(3);
						var horizontalThumb:DisplayObject = horizontalScrollBar.getChildAt(2);     
						// FIXME: I think we need to use x and width properties here, not y and height
						var hPos:Number = Math.round((horizontalThumb.y - rightArrow.height) / (rightArrow.y - horizontalThumb.height - rightArrow.height) * maxHorizontalScrollPosition);     
						
						// Inverse the position to scroll the content to the left for large reports
						listContent.move(hPos * -1, listContent.y);
					}
				}
				else
				{
					// Override the default scroll behavior to provide smooth vertical scrolling and not the usual "snap-to-row" behavior
					var vPos:Number;
					
					if (scrollEvent.detail == ScrollEventDetail.LINE_DOWN || scrollEvent.detail == ScrollEventDetail.LINE_UP)
					{
						vPos = this.fractionalVerticalScrollPosition;
						vPos += scrollEvent.delta;// * verticalScrollBar.lineScrollSize;
						vPos = Math.max(0, Math.min(maxVerticalScrollPosition, vPos));
					}
					else
					{
						if (verticalScrollBar.numChildren == 4)
						{
							// Get individual components of a scroll bar for measuring and get a vertical position to use
							var downArrow:DisplayObject = verticalScrollBar.getChildAt(3);
							var verticalThumb:DisplayObject = verticalScrollBar.getChildAt(2);     
							vPos = (verticalThumb.y - downArrow.height) / (downArrow.y - verticalThumb.height - downArrow.height) * maxVerticalScrollPosition;
						}
					}
					
					fractionalVerticalScrollPosition = vPos;
				}
			}
		}
		
		protected function set fractionalVerticalScrollPosition(newVerticalScrollPosition:Number):void
		{
			// Limit the value we use for the verticalScrollPosition to: 0 <= vsp <= max
			// Also, only use whole numbers for verticalScrollPosition because DataGrid does not handle fraction values.
			var wholeScroll:Number = Math.floor(Math.max(0, Math.min(newVerticalScrollPosition, maxVerticalScrollPosition)));
			
			if (verticalScrollPosition != wholeScroll)
				verticalScrollPosition = wholeScroll;
			
			var fraction:Number = -(newVerticalScrollPosition - verticalScrollPosition);
			fraction *= rowHeight;

			// round to avoid rendering artifacts which result from not snapping to pixel boundaries
			fraction = Math.round(fraction);
			
			var newY:Number = viewMetrics.top + listContent.topOffset + fraction;
			if (header.visible)
				newY += header.height;
			listContent.move(listContent.x, newY);
			
			if (verticalScrollBar != null)
				verticalScrollBar.scrollPosition = newVerticalScrollPosition;
			
			// We must ensure that a mask is used (instead of relying on the optimized conditional masking) if the listContent is moved.
			// Otherwise, the content may extend beyond the edges of the grid.
			if (fraction != 0)
				listContent.mask = maskShape;
		}
		
		protected function get fractionalVerticalScrollPosition():Number
		{
			var fractionalVerticalScrollPosition:Number;
			var fraction:Number = - listContent.y + viewMetrics.top + listContent.topOffset;

			if (header.visible)
				fraction += header.height;
			
			fraction /= rowHeight;
			fractionalVerticalScrollPosition = verticalScrollPosition + fraction;
			return fractionalVerticalScrollPosition;
		}

		private function getAncestorsInfo():String
		{
			var info:String = "";
			
			var component:UIComponent = listContent;
			while (component != null)
			{
				if (info.length > 0)
					info += ", ";
				
				info += component.className;
				component = component.parent as UIComponent;
			}
			return info;
		}
		
		override protected function mouseWheelHandler(event:MouseEvent):void
		{
			// A small lineScrollSize is required for smooth scrolling but is too small for the mouse wheel.
			// We divide by lineScrollSize here so that when the super.mouseWheelHandler multiplies by lineScrollSize we will be back at the original delta (usually 3, for 3 rows). 
			if (!event.isDefaultPrevented() && verticalScrollBar && verticalScrollBar.visible)
			{
				event.delta /= verticalScrollBar.lineScrollSize;
			}
			super.mouseWheelHandler(event);
		}
	}
}