package collaboRhythm.plugins.messages.model
{
	import collaboRhythm.plugins.messages.controller.MessagesAppController;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	public class MessagesModelAndController
	{
		private var _messagesModel:MessagesModel;
		private var _messagesAppController:MessagesAppController;

		public function MessagesModelAndController(messagesModel:MessagesModel,
												   messagesAppController:MessagesAppController)
		{
			_messagesModel = messagesModel;
			_messagesAppController = messagesAppController;
		}

		public function get messagesModel():MessagesModel
		{
			return _messagesModel;
		}

		public function get messagesAppController():MessagesAppController
		{
			return _messagesAppController;
		}
	}
}
