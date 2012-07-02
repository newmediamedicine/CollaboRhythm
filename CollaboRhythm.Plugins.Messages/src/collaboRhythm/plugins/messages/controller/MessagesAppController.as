package collaboRhythm.plugins.messages.controller
{
	import collaboRhythm.plugins.messages.model.IndividualMessageHealthRecordService;
	import collaboRhythm.plugins.messages.model.MessagesModelAndController;
	import collaboRhythm.plugins.messages.view.MessagesButtonWidgetView;
	import collaboRhythm.plugins.messages.view.MessagesView;
	import collaboRhythm.plugins.messages.view.PlayVideoMessageView;
	import collaboRhythm.plugins.messages.view.RecordVideoMessageView;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	import mx.core.UIComponent;

	public class MessagesAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Messages";

		private var _widgetView:MessagesButtonWidgetView;

		private var _messagesModel:MessagesModel;
		private var _individualMessagesHealthRecordService:IndividualMessageHealthRecordService;

		public function MessagesAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new MessagesButtonWidgetView();
			return _widgetView
		}

		override public function reloadUserData():void
		{
			removeUserData();

			super.reloadUserData();
		}

		override protected function updateWidgetViewModel():void
		{
			super.updateWidgetViewModel();

			if (_widgetView && _activeRecordAccount)
			{
				_widgetView.init(this, _activeRecordAccount.messagesModel);
			}
		}

		public override function get defaultName():String
		{
			return DEFAULT_NAME;
		}

		private function get individualMessagesHealthRecordService():IndividualMessageHealthRecordService
		{
			if (!_individualMessagesHealthRecordService)
			{
				_individualMessagesHealthRecordService = new IndividualMessageHealthRecordService(_settings.oauthChromeConsumerKey,
						_settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _activeAccount,
						_activeRecordAccount, _activeRecordAccount.messagesModel,
						collaborationLobbyNetConnectionServiceProxy);
			}
			return _individualMessagesHealthRecordService;
		}

		override public function get widgetView():UIComponent
		{
			return _widgetView;
		}

		override public function set widgetView(value:UIComponent):void
		{
			_widgetView = value as MessagesButtonWidgetView;
		}

		override public function get isFullViewSupported():Boolean
		{
			return false;
		}

		override protected function get shouldShowFullViewOnWidgetClick():Boolean
		{
			return false;
		}

		protected override function removeUserData():void
		{
			_messagesModel = null;
		}

		public function showMessagesView():void
		{
			individualMessagesHealthRecordService.getAllMessages();

			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy);
			_viewNavigator.pushView(MessagesView, messagesModelAndController);
		}

		public function createAndSendMessage(text:String):void
		{
			individualMessagesHealthRecordService.createAndSendMessage(text);
		}

		public function getAllMessages():void
		{
			individualMessagesHealthRecordService.getAllMessages();
		}

		public function recordVideoMessage():void
		{
			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy);
			_viewNavigator.pushView(RecordVideoMessageView, messagesModelAndController);
		}

		public function getMessageSubject():String
		{
			return individualMessagesHealthRecordService.getMessageSubject();
		}

		public function playVideoMessage(netStreamLocation:String):void
		{
			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy, netStreamLocation);
			_viewNavigator.pushView(PlayVideoMessageView, messagesModelAndController);
		}
	}
}
