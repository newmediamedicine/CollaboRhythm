package collaboRhythm.shared.model.healthRecord.document
{
	import collaboRhythm.shared.model.healthRecord.DocumentCollectionBase;

	import mx.events.CollectionEvent;

	[Bindable]
	public class MessagesModel extends DocumentCollectionBase
	{
		public static const RECEIVED:String = "received";
		public static const SENT:String = "sent";

		private var _unreadMessageCount:int;

		public function MessagesModel()
		{
			super(Message.DOCUMENT_TYPE);

			documents.addEventListener(CollectionEvent.COLLECTION_CHANGE, documents_collectionChange);

			unreadMessageCount = 0;
		}

		private function documents_collectionChange(event:CollectionEvent):void
		{
			unreadMessageCount = 0;

			for each (var message:Message in documents)
			{
				if ((message.read_at == "" || message.read_at == null) && message.type == RECEIVED)
				{
					unreadMessageCount += 1;
				}
			}
		}

		public function addMessage(message:Message, type:String):void
		{
			addDocument(message);
//
//			if (message.read_at == "" && type == RECEIVED)
//			{
//				unreadMessageCount += 1;
//			}
		}

		public function get unreadMessageCount():int
		{
			return _unreadMessageCount;
		}

		public function set unreadMessageCount(value:int):void
		{
			_unreadMessageCount = value;
		}
	}
}
