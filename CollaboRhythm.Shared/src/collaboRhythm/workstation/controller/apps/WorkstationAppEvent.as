package collaboRhythm.workstation.controller.apps
{
	import flash.events.Event;
	
	import spark.primitives.Rect;
	
	public class WorkstationAppEvent extends Event
	{
		public static const SHOW_FULL_VIEW:String = "ShowFullView";
		private var _workstationAppController:WorkstationAppControllerBase;
		private var _startRect:Rect;
		private var _applicationName:String;
		
		public function WorkstationAppEvent(type:String, workstationAppController:WorkstationAppControllerBase=null, startRect:Rect=null, applicationName:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_workstationAppController = workstationAppController;
			_startRect = startRect;
			_applicationName = applicationName;
		}

		public function get applicationName():String
		{
			return _applicationName;
		}

		public function set applicationName(value:String):void
		{
			_applicationName = value;
		}

		public function get startRect():Rect
		{
			return _startRect;
		}

		public function set startRect(value:Rect):void
		{
			_startRect = value;
		}

		public function get workstationAppController():WorkstationAppControllerBase
		{
			return _workstationAppController;
		}

		public function set workstationAppController(value:WorkstationAppControllerBase):void
		{
			_workstationAppController = value;
		}

	}
}