package collaboRhythm.shared.collaboration.model
{
	import flash.events.Event;

	public class CollaborationPointerSynchronizationEvent extends Event
	{
		public static const SHOW_POINTER:String = "ShowPointer";
		public static const MOVE_POINTER:String = "MovePointer";
		public static const HIDE_POINTER:String = "HidePointer";

		private var _sourcePeerId:String;
		private var _passWord:String;
		private var _x:Number;
		private var _y:Number;

		public function CollaborationPointerSynchronizationEvent(type:String, x:Number, y:Number, sourcePeerId:String,
																 passWord:String)
		{
			super(type);

			_x = x;
			_y = y;
			_sourcePeerId = sourcePeerId;
			_passWord = passWord;
		}

		public function get x():Number
		{
			return _x;
		}

		public function get y():Number
		{
			return _y;
		}

		public function get sourcePeerId():String
		{
			return _sourcePeerId;
		}

		public function get passWord():String
		{
			return _passWord;
		}
	}
}
