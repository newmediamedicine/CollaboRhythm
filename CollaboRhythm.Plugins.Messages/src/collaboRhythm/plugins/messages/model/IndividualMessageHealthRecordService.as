package collaboRhythm.plugins.messages.model
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.DateUtil;
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
															 indivoServerBaseURL:String, activeAccount:Account,
															 activeRecordAccount:Account, messagesModel:MessagesModel,
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
			for each (var message:Message in _messagesModel.messages)
			{
				if (message.read_at == null || message.body == null)
				{
					if (message.type == Message.INBOX)
					{
						getMessage(activeAccount.accountId, message);
					}
					else if (message.type == Message.SENT)
					{
						getSentMessage(activeAccount.accountId, message);
					}
				}
			}
		}

		override protected function getMessageCompleteHandler(responseXml:XML,
															  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var message:Message = healthRecordServiceRequestDetails.message;

			message.body = responseXml.body;
			message.read_at = DateUtil.parseW3CDTF(responseXml.read_at, true);
		}

		public function createAndSendMessage(body:String):Message
		{
			var subject:String = getMessageSubject();

			if (subject == null)
			{
				return null;
				// TODO: Log that no message was sent;
			}

			var message:Message = new Message();
			message.subject = subject;
			message.body = body;
			message.sender = _activeAccount.accountId;
			message.type = Message.SENT;

			_messagesModel.addSentMessage(message);

			var params:URLVariables = new URLVariables();
			params["subject"] = subject;
			params["body"] = body;

			sendMessage(subject, params.toString(), message);

			return message;
		}

		override protected function sendMessageCompleteHandler(responseXml:XML,
															   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var message:Message = healthRecordServiceRequestDetails.message;

			message.id = responseXml.@id;
			message.received_at = new Date();

			_collaborationLobbyNetConnectionServiceProxy.sendMessage(message.subject, message);
		}


		override protected function sendMessageErrorHandler(errorStatus:String,
														healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var message:Message = healthRecordServiceRequestDetails.message;

			message.received_at = new Date();
		}

		public function getMessageSubject():String
		{
			var subject:String;
			if (_activeRecordAccount == _activeAccount)
			{
				if (_activeAccount.recordShareAccounts.getIndex(0))
				{
					var recordShareAccount:Account = _activeAccount.recordShareAccounts.getIndex(0);
					subject = recordShareAccount.accountId;
				}
			}
			else
			{
				subject = _activeRecordAccount.accountId;
			}

			return subject;
		}
	}
}
