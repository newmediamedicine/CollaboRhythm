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
	import flash.display.Graphics;
	
	import mx.core.UIComponent;

	/**
	 * Adapter to enable touch scrolling for any scrollable component. The interface could be implemented by the
	 * component itself or by some other class which acts as an intermediary.
	 * 
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public interface ITouchScrollerAdapter
	{
		function ITouchScrollerAdapter();
		function get component():UIComponent;
		/**
		 * Returns the container to which child controls (such as the scroll indicators) can be added 
		 * @return 
		 */
		function get componentContainer():UIComponent;
		function get graphics():Graphics;
		/**
		 * Returns the width of the panel or visible area in which scrollable content is displayed. 
		 * @return 
		 */
		function get panelWidth():Number;
		/**
		 * Returns the height of the panel or visible area in which scrollable content is displayed. 
		 * @return 
		 */
		function get panelHeight():Number;
		/**
		 * Returns the width of the content which can be scrolled. 
		 * @return 
		 */
		function get scrollableAreaWidth():Number;
		/**
		 * Returns the height of the content which can be scrolled. 
		 * @return 
		 */
		function get scrollableAreaHeight():Number;
		function get contentPositionX():Number;
		function set contentPositionX(value:Number):void;
		function get contentPositionY():Number;
		function set contentPositionY(value:Number):void;
		function hideScrollBarV():void;
		function hideScrollBarH():void;
		function showScrollBarV():void;
		function showScrollBarH():void;
		
//		function get grabCursor():Class;
	}
}