package collaboRhythm.core.model.healthRecord.service
{
	import collaboRhythm.shared.model.Account;
	import collaboRhythm.shared.model.DateUtil;
	import collaboRhythm.shared.model.Record;
	import collaboRhythm.shared.model.healthRecord.HealthRecordServiceRequestDetails;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	public class MessagesHealthRecordService extends DocumentStorageServiceBase
	{
		private var _activeRecordAccount:Account;
		private var _record:Record;

		public function MessagesHealthRecordService(consumerKey:String, consumerSecret:String, baseURL:String,
													account:Account, debuggingToolsEnabled:Boolean,
													targetDocumentType:String, targetClass:Class,
													targetDocumentSchema:Class)
		{
			super(consumerKey, consumerSecret, baseURL, account, debuggingToolsEnabled, targetDocumentType, targetClass,
					targetDocumentSchema);
		}

		public function set activeRecordAccount(activeRecordAccount:Account):void
		{
			_activeRecordAccount = activeRecordAccount;
		}

		override public function loadDocuments(record:Record):void
		{

			super.loadDocuments(record);
			_record = record;

//			var params:URLVariables = new URLVariables();
//			if (_orderByField)
//				params["order_by"] = _orderByField;
//			if (_limit >= 0)
//				params["limit"] = _limit;
			var healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_INBOX,
					_activeRecordAccount, record);
			_pha.accounts_X_inboxGET(null, null, null, _activeAccount.accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
			_pendingReportRequests.put(PRIMARY_REPORT_REQUEST, PRIMARY_REPORT_REQUEST);
			healthRecordServiceRequestDetails = new HealthRecordServiceRequestDetails(GET_SENT, _activeRecordAccount,
					record);
			_pha.accounts_X_sentGET(null, null, null, _activeAccount.accountId, _activeAccount.oauthAccountToken,
					_activeAccount.oauthAccountTokenSecret, healthRecordServiceRequestDetails);
			_pendingReportRequests.put(PRIMARY_REPORT_REQUEST, PRIMARY_REPORT_REQUEST);
		}


		override protected function handleGetInbox(responseXml:XML,
												   healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			for each (var messageXml:XML in responseXml.Message)
			{
				if (_activeAccount == _activeRecordAccount)
				{
					createNewMessage(messageXml, MessagesModel.RECEIVED);

				}
				else
				{
					if (messageXml.sender == _activeRecordAccount.accountId)
					{
						createNewMessage(messageXml, MessagesModel.RECEIVED)
					}
				}
			}

			_pendingReportRequests.remove(PRIMARY_REPORT_REQUEST);
		}

		override protected function handleGetSent(responseXml:XML,
												  healthRecordServiceRequestDetails:HealthRecordServiceRequestDetails):void
		{
			for each (var messageXml:XML in responseXml.Message)
			{
				if (_activeAccount == _activeRecordAccount)
				{
					createNewMessage(messageXml, MessagesModel.SENT);

				}
				else
				{
					if (messageXml.subject == _activeRecordAccount.accountId)
					{
						createNewMessage(messageXml, MessagesModel.SENT)
					}
				}
			}

			_pendingReportRequests.remove(PRIMARY_REPORT_REQUEST);
		}

		private function createNewMessage(messageXml:XML, type:String):void
		{
			var message:Message = new Message();
			message.id = messageXml.@id;
			message.subject = messageXml.subject;
			message.sender = messageXml.sender;
			message.read_at = messageXml.read_at;
			message.received_at = DateUtil.parseW3CDTF(messageXml.received_at);
			message.type = type;
			_record.messagesModel.addMessage(message, type);
		}
	}
}
