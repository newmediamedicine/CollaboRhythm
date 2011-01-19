package collaboRhythm.workstation.model.settings
{
	import j2as3.collection.HashMap;

	public class WindowSettings
	{
		private var _fullScreen:Boolean;
		private var _windowStates:Vector.<WindowState> = new Vector.<WindowState>();
		private var _zoom:Number = 0;
		
		public function WindowSettings()
		{
		}

		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}

		public function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
		}

		public function get windowStates():Vector.<WindowState>
		{
			return _windowStates;
		}

		public function set windowStates(value:Vector.<WindowState>):void
		{
			_windowStates = value;
		}

		public function get zoom():Number
		{
			return _zoom;
		}

		public function set zoom(value:Number):void
		{
			_zoom = value;
		}


//		/**
//		 * Each container has an id (corresponding to it's purpose) and a window mapping (corresponding to where it exists in the visual hierarchy).  
//		 */
//		public function get containerWindowMappings():HashMap
//		{
//			return _containerWindowMappings;
//		}
//
//		/**
//		 * @private
//		 */
//		public function set containerWindowMappings(value:HashMap):void
//		{
//			_containerWindowMappings = value;
//		}

	}
}