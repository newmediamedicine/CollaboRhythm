package collaboRhythm.plugins.messages.view
{
	import collaboRhythm.shared.model.healthRecord.document.Message;

	import flash.events.Event;

	public class MessageItemRendererEvent extends Event
	{
		public static const MESSAGE_ITEM_RENDERER_VIEWED:String = "MessageItemRendererViewed";

		private var _message:Message;

		public function MessageItemRendererEvent(type:String, message:Message)
		{
			super(type, true);
			_message = message;
		}

		public function get message():Message
		{
			return _message;
		}
	}
}
