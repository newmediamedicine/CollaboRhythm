package collaboRhythm.shared.model.healthRecord.document
{
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;

	[Bindable]
	public class MessagesModel
	{
		private var _inboxMessages:ArrayCollection = new ArrayCollection();
		private var _sentMessages:ArrayCollection = new ArrayCollection();
		private var _messages:ArrayCollection = new ArrayCollection();
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
			inboxMessages.addItem(message);
			messages.addItem(message);
		}

		public function addSentMessage(message:Message):void
		{
			sentMessages.addItem(message);
			messages.addItem(message);
		}

		public function get inboxMessages():ArrayCollection
		{
			return _inboxMessages;
		}

		public function set inboxMessages(value:ArrayCollection):void
		{
			_inboxMessages = value;
		}

		public function get sentMessages():ArrayCollection
		{
			return _sentMessages;
		}

		public function set sentMessages(value:ArrayCollection):void
		{
			_sentMessages = value;
		}

		public function get messages():ArrayCollection
		{
			return _messages;
		}

		public function set messages(value:ArrayCollection):void
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
