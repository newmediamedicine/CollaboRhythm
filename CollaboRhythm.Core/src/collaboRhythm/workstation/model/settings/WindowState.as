package collaboRhythm.workstation.model.settings
{
	import flash.display.NativeWindowDisplayState;
	import flash.geom.Rectangle;
	
	import mx.core.Window;

	public class WindowState
	{
		private var _displayState:String;
		private var _bounds:Rectangle;
		private var _componentLayouts:Vector.<ComponentLayout> = new Vector.<ComponentLayout>();
		
		private var _spaces:Vector.<String> = new Vector.<String>();		
		
		public function WindowState()
		{
		}

		public function get componentLayouts():Vector.<ComponentLayout>
		{
			return _componentLayouts;
		}

		public function set componentLayouts(value:Vector.<ComponentLayout>):void
		{
			_componentLayouts = value;
		}

		public function get displayState():String
		{
			return _displayState;
		}

		public function set displayState(value:String):void
		{
			_displayState = value;
		}

		/**
		 * IDs of the spaces in this window. 
		 */
		public function get spaces():Vector.<String>
		{
			return _spaces;
		}

		public function set spaces(value:Vector.<String>):void
		{
			_spaces = value;
		}

		public function get isMinimized():Boolean
		{
			return _displayState == NativeWindowDisplayState.MINIMIZED;
		}
		
		public function get isMaximized():Boolean
		{
			return _displayState == NativeWindowDisplayState.MAXIMIZED;
		}
		
		public function get bounds():Rectangle
		{
			return _bounds;
		}

		public function set bounds(value:Rectangle):void
		{
			_bounds = value;
		}
	}
}