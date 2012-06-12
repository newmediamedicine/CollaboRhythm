package collaboRhythm.plugins.messages.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;

	import flash.net.URLVariables;

	public class IndividualMessageHealthRecordService extends PhaHealthRecordServiceBase
	{
		private var _messagesModel:MessagesModel;
		private var _activeRecordAccount:Account;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;

		public function IndividualMessageHealthRecordService(oauthPhaConsumerKey:String, oauthPhaConsumerSecret:String,
															 indivoServerBaseURL:String,
															 activeAccount:Account,
															 activeRecordAccount:Account,
															 messagesModel:MessagesModel,
															 collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			super(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL, activeAccount);

			_messagesModel = messagesModel;
			_activeRecordAccount = activeRecordAccount;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function getAllMessages():void
		{
			for each (var message:Message in _messagesModel.documents)
			{
				if (message.type == MessagesModel.RECEIVED)
				{
					getMessage(activeAccount.accountId, message);
				}
				else if (message.type == MessagesModel.SENT)
				{
					getSentMessage(activeAccount.accountId, message);
				}
			}
		}

		override protected function getMessageCompleteHandler(responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var message:Message = healthRecordServiceRequestDetails.message;

			message.body = responseXml.body;
			message.read_at = responseXml.read_at;
		}

		public function createAndSendMessage(text:String):Message
		{
			var subject:String;
			if (_activeRecordAccount == _activeAccount)
			{
				subject = "jking@records.media.mit.edu";
			}
			else
			{
				subject = _activeRecordAccount.accountId;
			}

			var params:URLVariables = new URLVariables();
			params["subject"] = subject;
			params["body"] = text;

			var message:Message = new Message();
			message.subject = subject;
			message.body = text;
			message.type = MessagesModel.SENT;
			message.sender = _activeAccount.accountId;
			message.received_at = new Date();

			_messagesModel.addMessage(message, MessagesModel.SENT);

			_collaborationLobbyNetConnectionServiceProxy.sendMessage(subject, message);

			sendMessage(subject, params.toString());

			return message;
		}
	}
}
