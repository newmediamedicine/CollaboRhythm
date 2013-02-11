package collaboRhythm.shared.model.healthRecord.document
{
	import com.theory9.data.types.OrderedMapCollection;

	import mx.events.CollectionEvent;

	[Bindable]
	public class MessagesModel
	{
		private var _inboxMessages:OrderedMapCollection = new OrderedMapCollection(null, "id");
		private var _sentMessages:OrderedMapCollection = new OrderedMapCollection(null, "id");
		private var _messages:OrderedMapCollection = new OrderedMapCollection(null, "id");
		private var _unreadMessageCount:int;

		public function MessagesModel()
		{
			inboxMessages.addEventListener(CollectionEvent.COLLECTION_CHANGE, inboxMessages_collectionChange);

			unreadMessageCount = 0;
		}

		private function inboxMessages_collectionChange(event:CollectionEvent):void
		{
			unreadMessageCount = 0;

			for each (var message:Message in inboxMessages)
			{
				if (message.read_at == null)
				{
					unreadMessageCount += 1;
				}
			}
		}

		public function addInboxMessage(message:Message):void
		{
			if (!inboxMessages.contains(message))
			{
				inboxMessages.addItem(message);
				messages.addItem(message);
			}
		}

		public function addSentMessage(message:Message):void
		{
			if (!sentMessages.contains(message))
			{
				sentMessages.addItem(message);
				messages.addItem(message);
			}
		}

		public function get inboxMessages():OrderedMapCollection
		{
			return _inboxMessages;
		}

		public function set inboxMessages(value:OrderedMapCollection):void
		{
			_inboxMessages = value;
		}

		public function get sentMessages():OrderedMapCollection
		{
			return _sentMessages;
		}

		public function set sentMessages(value:OrderedMapCollection):void
		{
			_sentMessages = value;
		}

		public function get messages():OrderedMapCollection
		{
			return _messages;
		}

		public function set messages(value:OrderedMapCollection):void
		{
			_messages = value;
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
