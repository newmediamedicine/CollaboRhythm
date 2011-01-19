package collaboRhythm.workstation.controller.apps
{
	import flash.events.MouseEvent;

	public class WorkstationAppDragData
	{
		public static const DRAG_SOURCE_DATA_FORMAT:String = "WorkstationAppDragData";
		
		private var _mouseEvent:MouseEvent;
		
		public function WorkstationAppDragData(mouseEvent:MouseEvent)
		{
			_mouseEvent = mouseEvent;
		}

		public function get mouseEvent():MouseEvent
		{
			return _mouseEvent;
		}

		public function set mouseEvent(value:MouseEvent):void
		{
			_mouseEvent = value;
		}

	}
}