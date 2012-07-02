package collaboRhythm.plugins.messages.model
{
	import collaboRhythm.plugins.messages.controller.MessagesAppController;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	public class MessagesModelAndController
	{
		private var _messagesModel:MessagesModel;
		private var _messagesAppController:MessagesAppController;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _netStreamLocation:String;

		public function MessagesModelAndController(messagesModel:MessagesModel,
												   messagesAppController:MessagesAppController,
												   collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy = null,
												   netStreamLocation:String = null)
		{
			_messagesModel = messagesModel;
			_messagesAppController = messagesAppController;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_netStreamLocation = netStreamLocation;
		}

		public function get messagesModel():MessagesModel
		{
			return _messagesModel;
		}

		public function get messagesAppController():MessagesAppController
		{
			return _messagesAppController;
		}

		public function get collaborationLobbyNetConnectionServiceProxy():ICollaborationLobbyNetConnectionServiceProxy
		{
			return _collaborationLobbyNetConnectionServiceProxy;
		}

		public function get netStreamLocation():String
		{
			return _netStreamLocation;
		}
	}
}
