package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceEvent;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.PhaHealthRecordServiceBase;
	import collaboRhythm.shared.model.healthRecord.document.Message;

	import org.indivo.client.IndivoClientEvent;

	public class MessagesHealthRecordService extends PhaHealthRecordServiceBase
	{
		public static const GET_INBOX_MESSAGES:String = "Get Inbox Messages";
		public static const GET_SENT_MESSAGES:String = "Get Sent Messages";

		private var _isGetInboxMessagesComplete:Boolean = false;
		private var _isGetSentMessagesComplete:Boolean = false;

		public function MessagesHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													account:Account)
		{
			super(consumerKey, consumerSecret, baseURL, account);
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

		private function getInboxMessagesCompleteHandler(indivoClientEvent:IndivoClientEvent, responseXml:XML,
														 healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			for each (var messageXml:XML in responseXml.Message)
			{
				var message:Message = createNewMessage(messageXml, Message.INBOX);
				_activeAccount.messagesModel.addInboxMessage(message);

				// TODO: It appears that it is currently not possible to archive sent messages
				// There are some ill-formed messages (wrong subject) currently that need to be ignored
				if (_activeAccount.allSharingAccounts[message.sender])
				{
					var senderAccount:Account = _activeAccount.allSharingAccounts[message.sender];
					senderAccount.messagesModel.addInboxMessage(message);
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
				_activeAccount.messagesModel.addSentMessage(message);

				// TODO: It appears that it is currently not possible to archive sent messages
				// There are some ill-formed messages (wrong subject) currently that need to be ignored
				if (_activeAccount.allSharingAccounts[message.subject])
				{
					var recipientAccount:Account = _activeAccount.allSharingAccounts[message.subject];
					recipientAccount.messagesModel.addSentMessage(message);
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

//		override public function loadDocuments(record:Record):void
//		{
//
//			super.loadDocuments(record);
//			_record = record;
//
//			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_INBOX,
//					_activeRecordAccount, record);
//			_pha.accounts_X_inboxGET(null, null, null, _activeAccount.accountId, _activeAccount.oauthAccountToken,
//					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
//			_pendingReportRequests.put(PRIMARY_REPORT_REQUEST, PRIMARY_REPORT_REQUEST);
//			healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_SENT, _activeRecordAccount,
//					record);
//			_pha.accounts_X_sentGET(null, null, null, _activeAccount.accountId, _activeAccount.oauthAccountToken,
//					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
//			_pendingReportRequests.put(PRIMARY_REPORT_REQUEST, PRIMARY_REPORT_REQUEST);
//		}


//		override protected function handleGetInbox(responseXml:XML,
//												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//		{
//			for each (var messageXml:XML in responseXml.Message)
//			{
//				if (_activeAccount == _activeRecordAccount)
//				{
//					createNewMessage(messageXml, MessagesModel.RECEIVED);
//				}
//				else
//				{
//					if (messageXml.sender == _activeRecordAccount.accountId)
//					{
//						createNewMessage(messageXml, MessagesModel.RECEIVED)
//					}
//				}
//			}
//
//			_pendingReportRequests.remove(PRIMARY_REPORT_REQUEST);
//		}
//
//		override protected function handleGetSent(responseXml:XML,
//												  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
//		{
//			for each (var messageXml:XML in responseXml.Message)
//			{
//				if (_activeAccount == _activeRecordAccount)
//				{
//					createNewMessage(messageXml, MessagesModel.SENT);
//				}
//				else
//				{
//					if (messageXml.subject == _activeRecordAccount.accountId)
//					{
//						createNewMessage(messageXml, MessagesModel.SENT)
//					}
//				}
//			}
//
//			_pendingReportRequests.remove(PRIMARY_REPORT_REQUEST);
//		}

		private function createNewMessage(messageXml:XML, type:String):Message
		{
			var message:Message = new Message();
			message.id = messageXml.@id;
			message.subject = messageXml.subject;
			message.sender = messageXml.sender;
			message.read_at = DateUtil.parseW3CDTF(messageXml.read_at, true);
			message.received_at = DateUtil.parseW3CDTF(messageXml.received_at, true);
			message.type = type;

			return message;
		}
	}
}
