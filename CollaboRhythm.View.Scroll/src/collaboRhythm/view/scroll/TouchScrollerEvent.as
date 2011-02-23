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
	
	/**
	 * A <c>TouchScrollerEvent</c> object is dispatched into the event flow whenever scrolling by touch or mouse dragging starts.
	 * 
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public class TouchScrollerEvent extends Event
	{
		/**
		 * Indicates that touch scrolling has started.  
		 */
		public static const SCROLL_START:String = "scrollStart";
		/**
		 * Indicates that touch scrolling has completed normally (drag finished with no inertia, or inertia finished after a flick).  
		 */
		public static const SCROLL_STOP:String = "scrollStop";
		/**
		 * Indicates that touch scrolling has been aborted (such as when the component has moved, perhaps due to scrolling of some parent/container component). 
		 */
		public static const SCROLL_ABORT:String = "scrollAbort";
		
		private var _scrollTarget:Object;
		
		public function TouchScrollerEvent(type:String, scrollTarget:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_scrollTarget = scrollTarget
		}

		public function get scrollTarget():Object
		{
			return _scrollTarget;
		}

	}
}