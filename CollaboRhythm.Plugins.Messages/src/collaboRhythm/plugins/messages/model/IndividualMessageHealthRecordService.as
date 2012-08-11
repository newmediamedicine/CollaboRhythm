package collaboRhythm.plugins.messages.model
{
	import collaboRhythm.shared.messages.model.IIndividualMessageHealthRecordService;
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

	public class IndividualMessageHealthRecordService extends PhaHealthRecordServiceBase implements IIndividualMessageHealthRecordService
	{
		private var _messagesModel:MessagesModel;
		private var _activeRecordAccount:Account;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;

//		This service is currently separate from the MessagesHealthRecordService for several reasons. (An attempt was made to merge them.)
//		1. If an interface is created for MessagesHealthRecordService, this is problematic because it inherits from HealthRecordServiceBase
//		   and ApplicationControllerBase relies on its events.
//		2. If a plugin is responsible for registering an instance of the merged service with the componentContainer,
//		   issues arise because one cannot be sure that the plugin will be loaded by the time that the session is created
//		   and the service is needed. It is certainly possible that additional events can be tracked, but this will take more
//		   work and will require more intensive testing to ensure that all scenarios are properly handled.
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

		public function createAndSendMessage(body:String):void
		{
			var subjectsVector:Vector.<String> = getMessageSubjects();

			if (subjectsVector.length == 0)
			{
				// TODO: Log that no message was sent;
			}
			else
			{
				var message:Message = new Message();
				message.sender = _activeAccount.accountId;
				message.type = Message.SENT;
				message.body = body;

				var params:URLVariables = new URLVariables();
				params["body"] = body;

				for each (var subject:String in subjectsVector)
				{
					message.subject = subject;
					params["subject"] = subject;

					_messagesModel.addSentMessage(message);

					sendMessage(subject, params.toString(), message);
				}
			}
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

		/*
		* Returns all of the accounts that should receive a message. This includes all of the accounts with which the activeRecordAccount
		* is shared (except the sending account if the sending account is one of these accounts) and also the activeRecordAccount
		* if the sending account is not the activeRecordAccount.
		* */
		public function getMessageSubjects():Vector.<String>
		{
			var subjectsVector:Vector.<String> = new Vector.<String>();

			for each (var recordShareAccount:Account in _activeRecordAccount.recordShareAccounts)
			{
				if (recordShareAccount.accountId != _activeAccount.accountId)
				{
					subjectsVector.push(recordShareAccount.accountId);
				}
			}

			if (_activeRecordAccount != _activeAccount)
			{
				subjectsVector.push(_activeRecordAccount.accountId);
			}

			return subjectsVector;
		}
	}
}
