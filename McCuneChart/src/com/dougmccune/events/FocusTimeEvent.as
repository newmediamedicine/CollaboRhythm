package com.dougmccune.events
{
	import flash.events.Event;
	
	public class FocusTimeEvent extends Event
	{
		/**
		 * Indicates that the focus time of the chart has changed.  
		 */
		public static const FOCUS_TIME_CHANGE:String = "focusTimeChange";
		
		public function FocusTimeEvent(type:String=FOCUS_TIME_CHANGE, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}