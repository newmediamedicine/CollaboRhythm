package collaboRhythm.plugins.messages.controller
{
	import castle.flexbridge.reflection.ReflectionUtils;

	import collaboRhythm.plugins.messages.model.IndividualMessageHealthRecordService;
	import collaboRhythm.plugins.messages.model.MessagesModelAndController;
	import collaboRhythm.plugins.messages.view.MessagesButtonWidgetView;
	import collaboRhythm.plugins.messages.view.MessagesView;
	import collaboRhythm.plugins.messages.view.PlayVideoMessageView;
	import collaboRhythm.plugins.messages.view.RecordVideoMessageView;
	import collaboRhythm.shared.collaboration.model.CollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.messages.model.IIndividualMessageHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.document.Message;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	import mx.core.UIComponent;

	public class MessagesAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Messages";

		private var _widgetView:MessagesButtonWidgetView;

		private var _messagesModel:MessagesModel;
		private var _individualMessagesHealthRecordService:IndividualMessageHealthRecordService;
		private var _collaborationLobbyNetConnectionServiceProxyLocal:CollaborationLobbyNetConnectionServiceProxy;
		private var _synchronizationService:SynchronizationService;
		private var _messagesViewed:Vector.<Message> = new Vector.<Message>();

		public function MessagesAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_collaborationLobbyNetConnectionServiceProxyLocal = _collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_synchronizationService = new SynchronizationService(this,
					_collaborationLobbyNetConnectionServiceProxyLocal);

			_individualMessagesHealthRecordService = new IndividualMessageHealthRecordService(_settings.oauthChromeConsumerKey,
					_settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _activeAccount,
					_activeRecordAccount, _activeRecordAccount.messagesModel,
					collaborationLobbyNetConnectionServiceProxy, _settings);

			registerIndividualMessageHealthRecordService();
		}

		private function registerIndividualMessageHealthRecordService():void
		{
			if (_individualMessagesHealthRecordService)
			{
				_componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(IIndividualMessageHealthRecordService).name,
								IIndividualMessageHealthRecordService, _individualMessagesHealthRecordService);
			}
		}

		override protected function createWidgetView():UIComponent
		{
			_widgetView = new MessagesButtonWidgetView();
			return _widgetView
		}

		override public function reloadUserData():void
		{
			removeUserData();
			registerIndividualMessageHealthRecordService();

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
			_componentContainer.unregisterServiceType(IIndividualMessageHealthRecordService);
		}

		public function showMessagesView():void
		{
			if (_synchronizationService.synchronize("showMessagesView"))
			{
				return;
			}

			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy);
			_viewNavigator.pushView(MessagesView, messagesModelAndController);
		}

		public function getMessage(message:Message):void
		{
			if (_messagesViewed.indexOf(message) == -1)
			{
				_messagesViewed.push(message);
				individualMessagesHealthRecordService.getMessage(message);
			}
		}

		public function createAndSendMessage(text:String):void
		{
			individualMessagesHealthRecordService.createAndSendMessage(text);
		}

		public function recordVideoMessage():void
		{
			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy);
			_viewNavigator.pushView(RecordVideoMessageView, messagesModelAndController);
		}

		public function playVideoMessage(netStreamLocation:String):void
		{
			if (_synchronizationService.synchronize("playVideoMessage", netStreamLocation))
			{
				return;
			}

			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy, netStreamLocation);
			_viewNavigator.pushView(PlayVideoMessageView, messagesModelAndController);
		}
	}
}
