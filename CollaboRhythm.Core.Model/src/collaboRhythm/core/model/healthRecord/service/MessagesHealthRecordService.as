package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.services.DateUtil;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.healthRecord.document.MessageStatusCodes;
	import collaboRhythm.shared.model.settings.Settings;

	import org.indivo.client.IndivoClientEvent;

	public class MessagesHealthRecordService extends PhaHealthRecordServiceBase
	{
		public static const GET_INBOX_MESSAGES:String = "Get Inbox Messages";
		public static const GET_SENT_MESSAGES:String = "Get Sent Messages";

		private var _isGetInboxMessagesComplete:Boolean = false;
		private var _isGetSentMessagesComplete:Boolean = false;
		private var _settings:Settings;

		public function MessagesHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													account:Account,
													settings:Settings)
		{
			super(consumerKey, consumerSecret, baseURL, account);
			_settings = settings;
		}

		public function getMessages(accountId:String):void
		{
			getInboxMessages(accountId);
			getSentMessages(accountId);
		}

		public function getInboxMessages(accountId:String):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_INBOX_MESSAGES,
					_activeAccount);
			_pha.accounts_X_inboxGET(null, null, null, accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
		}

		public function getSentMessages(accountId:String):void
		{
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_SENT_MESSAGES,
					_activeAccount);
			_pha.accounts_X_sentGET(null, null, null, accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
		}

		protected override function handleResponse(indivoClientEvent:IndivoClientEvent, responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			if (healthRecordServiceRequestDetails.indivoApiCall == GET_INBOX_MESSAGES)
			{
				getInboxMessagesCompleteHandler(indivoClientEvent, responseXml, healthRecordServiceRequestDetails);
			}
			else if (healthRecordServiceRequestDetails.indivoApiCall == GET_SENT_MESSAGES)
			{
				getSentMessagesCompleteHandler(indivoClientEvent, responseXml, healthRecordServiceRequestDetails);
			}
		}

		override protected function handleError(event:IndivoClientEvent, errorStatus:String,
												healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):Boolean
		{
			var isRetrying:Boolean = super.handleError(event, errorStatus, healthRecordServiceRequestDetails);
			if (!isRetrying)
			{
				if (healthRecordServiceRequestDetails.indivoApiCall == GET_INBOX_MESSAGES)
				{
					_isGetInboxMessagesComplete = true;
				}
				else if (healthRecordServiceRequestDetails.indivoApiCall == GET_SENT_MESSAGES)
				{
					_isGetSentMessagesComplete = true;
				}
				isServiceComplete(event);
			}
			return isRetrying;
		}

		private function getInboxMessagesCompleteHandler(indivoClientEvent:IndivoClientEvent, responseXml:XML,
														 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			for each (var messageXml:XML in responseXml.Message)
			{
				var message:Message = createNewMessage(messageXml, Message.INBOX);
				_activeAccount.messagesModel.addInboxMessage(message);

				// We want to have a separate model of the messages regarding particular patient (one model for each patient's record).
				// For now we are achieving this by using the messagesModel property of the Account for each Account
				// in _activeAccount.allSharingAccounts. So the inbox on
				// allSharingAccounts["patient1@test"].messagesModel is not the inbox of patient1, but rather the subset
				// of messages from the inbox of the active account which are regarding patient1.

				// TODO: It appears that it is currently not possible to archive sent messages
				// There are some ill-formed messages (wrong subject) currently that need to be ignored
				if (_activeAccount.allSharingAccounts[message.subject])
				{
					var subjectAccount:Account = _activeAccount.allSharingAccounts[message.subject];
					subjectAccount.messagesModel.addInboxMessage(message);
				}
			}

			_logger.info("Get inbox messages COMPLETE");

			_isGetInboxMessagesComplete = true;
			isServiceComplete(indivoClientEvent);
		}

		private function getSentMessagesCompleteHandler(indivoClientEvent:IndivoClientEvent, responseXml:XML,
														healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			for each (var messageXml:XML in responseXml.Message)
			{
				var message:Message = createNewMessage(messageXml, Message.SENT);

				if (_settings.isPatientMode)
				{
					// TODO: this is a temporary fix to ensure that only one item is seen for each message that a
					// patient sends. Eventually an implementation that supports this on the server will likely be
					// preferable.
					if (message.recipient == _settings.primaryClinicianTeamMember && _activeAccount.allSharingAccounts[message.recipient])
					{
						_activeAccount.messagesModel.addSentMessage(message);
					}
				}
				else
				{
					_activeAccount.messagesModel.addSentMessage(message);

					// TODO: It appears that it is currently not possible to archive sent messages
					// There are some ill-formed messages (wrong subject) currently that need to be ignored
					if (message.recipient == message.subject && _activeAccount.allSharingAccounts[message.recipient])
					{
						var recipientAccount:Account = _activeAccount.allSharingAccounts[message.recipient];
						recipientAccount.messagesModel.addSentMessage(message);
					}
				}
			}

			_logger.info("Get sent messages COMPLETE");

			_isGetSentMessagesComplete = true;
			isServiceComplete(indivoClientEvent);
		}

		private function isServiceComplete(indivoClientEvent:IndivoClientEvent):void
		{
			if (_isGetInboxMessagesComplete && _isGetSentMessagesComplete)
			{
				dispatchEvent(new HealthRecordServiceEvent(HealthRecordServiceEvent.COMPLETE, indivoClientEvent));
			}
		}

		private function createNewMessage(messageXml:XML, type:String):Message
		{
			var message:Message = new Message();
			message.id = messageXml.@id;
			message.subject = messageXml.subject;
			message.sender = messageXml.sender;
			message.recipient = messageXml.recipient;
			message.read_at = DateUtil.parseW3CDTF(messageXml.read_at, true);
			message.received_at = DateUtil.parseW3CDTF(messageXml.received_at, true);
			message.type = type;
			message.localStatus = MessageStatusCodes.COMPLETE;

			return message;
		}
	}
}
