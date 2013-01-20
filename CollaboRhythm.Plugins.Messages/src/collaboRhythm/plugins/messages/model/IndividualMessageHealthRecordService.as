package collaboRhythm.plugins.messages.model
{
	import collaboRhythm.shared.messages.model.IIndividualMessageHealthRecordService;
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.healthRecord.document.MessageStatusCodes;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;
	import collaboRhythm.shared.model.services.ICurrentDateSource;
	import collaboRhythm.shared.model.services.WorkstationKernel;
	import collaboRhythm.shared.model.settings.Settings;

	import flash.net.URLVariables;

	import mx.utils.UIDUtil;

	public class IndividualMessageHealthRecordService extends PhaHealthRecordServiceBase implements IIndividualMessageHealthRecordService
	{
		private static const MESSAGE_SUBJECT_RE_TAG:String = "Re:";

		private var _messagesModel:MessagesModel;
		private var _activeRecordAccount:Account;
		private var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		private var _settings:Settings;

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
															 collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
															 settings:Settings)
		{
			super(oauthPhaConsumerKey, oauthPhaConsumerSecret, indivoServerBaseURL, activeAccount);

			_messagesModel = messagesModel;
			_activeRecordAccount = activeRecordAccount;
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_settings = settings;

			_currentDateSource = WorkstationKernel.instance.resolve(ICurrentDateSource) as ICurrentDateSource;
		}

		public function getMessage(message:Message):void
		{
			if (message.type == Message.INBOX)
			{
				getInboxMessage(activeAccount.accountId, message);
			}
			else if (message.type == Message.SENT)
			{
				getSentMessage(activeAccount.accountId, message);
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
			var message:Message;

			if (_settings.isPatientMode)
			{
				message = sendMessageToClinicianTeamMemberAccounts(body);
			}
			else
			{
				message = sendMessageToActiveRecordAccount(body);
				sendMessageToClinicianTeamMemberAccounts(body);
			}

			_messagesModel.addSentMessage(message);
		}

		private function createMessage(recipientAccountId:String, body:String):Message
		{
			var message:Message = new Message();
			// create a temporary unique id so that the message can be added to an OrderedMap; the id will be updated
			// after the message is sent and a response is received from the server
			message.id = UIDUtil.createUID();
			message.sender = _activeAccount.accountId;
			message.recipient = recipientAccountId;
			message.subject = _activeRecordAccount.accountId;
			message.type = Message.SENT;
			message.body = body;
			message.localStatus = MessageStatusCodes.SENDING;

			return message;
		}

		private function createParams(body:String):URLVariables
		{
			var params:URLVariables = new URLVariables();
			params["subject"] = _activeRecordAccount.accountId;
			params["body"] = body;

			return params;
		}

		private function sendMessageToActiveRecordAccount(body:String):Message
		{
			var message:Message = createMessage(_activeRecordAccount.accountId, body);

			sendMessage(_activeRecordAccount.accountId, createParams(body).toString(), message);

			return message;
		}

		private function sendMessageToClinicianTeamMemberAccounts(body:String):Message
		{
			var primaryMessage:Message;

			for each (var clinicianTeamMember:String in _settings.clinicianTeamMembers)
			{
				var message:Message = createMessage(clinicianTeamMember, body);

				sendMessage(clinicianTeamMember, createParams(body).toString(), message);

				if (clinicianTeamMember == _settings.primaryClinicianTeamMember)
				{
					primaryMessage = message;
				}
			}

			return primaryMessage;
		}

		override protected function sendMessageCompleteHandler(responseXml:XML,
															   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var message:Message = healthRecordServiceRequestDetails.message;

			message.id = responseXml.@id;
			message.received_at = DateUtil.parseW3CDTF(responseXml.received_at, true);
			message.localStatus = MessageStatusCodes.COMPLETE;

			_collaborationLobbyNetConnectionServiceProxy.sendMessage(message.recipient, message);
		}

		override protected function sendMessageErrorHandler(errorStatus:String,
															healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			var message:Message = healthRecordServiceRequestDetails.message;

			message.received_at = new Date();
			message.localStatus = MessageStatusCodes.FAILED;
		}
	}
}
