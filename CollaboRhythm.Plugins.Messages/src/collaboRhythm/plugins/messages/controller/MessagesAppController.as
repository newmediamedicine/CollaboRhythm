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
	import collaboRhythm.shared.collaboration.model.CollaborationModel;
	import collaboRhythm.shared.collaboration.model.CollaborationViewSynchronizationEvent;
	import collaboRhythm.shared.controller.apps.AppControllerBase;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.messages.model.IIndividualMessageHealthRecordService;
	import collaboRhythm.shared.model.healthRecord.document.MessagesModel;

	import flash.utils.getQualifiedClassName;

	import mx.core.UIComponent;

	public class MessagesAppController extends AppControllerBase
	{
		public static const DEFAULT_NAME:String = "Messages";

		private var _widgetView:MessagesButtonWidgetView;

		private var _messagesModel:MessagesModel;
		private var _individualMessagesHealthRecordService:IndividualMessageHealthRecordService;
		private var _collaborationLobbyNetConnectionServiceProxyLocal:CollaborationLobbyNetConnectionServiceProxy;

		public function MessagesAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);

			_collaborationLobbyNetConnectionServiceProxyLocal = _collaborationLobbyNetConnectionServiceProxy as
					CollaborationLobbyNetConnectionServiceProxy;
			_collaborationLobbyNetConnectionServiceProxyLocal.addEventListener(getQualifiedClassName(this),
					collaborationViewSynchronization_eventHandler);

			_individualMessagesHealthRecordService = new IndividualMessageHealthRecordService(_settings.oauthChromeConsumerKey,
					_settings.oauthChromeConsumerSecret, _settings.indivoServerBaseURL, _activeAccount,
					_activeRecordAccount, _activeRecordAccount.messagesModel,
					collaborationLobbyNetConnectionServiceProxy);

			_componentContainer.registerComponentInstance(ReflectionUtils.getClassInfo(IIndividualMessageHealthRecordService).name, IIndividualMessageHealthRecordService, _individualMessagesHealthRecordService);
		}

		private function collaborationViewSynchronization_eventHandler(event:CollaborationViewSynchronizationEvent):void
		{
			if (event.synchronizeData)
			{
				this[event.synchronizeFunction](CollaborationLobbyNetConnectionServiceProxy.REMOTE,
						event.synchronizeData);
			}
			else
			{
				this[event.synchronizeFunction](CollaborationLobbyNetConnectionServiceProxy.REMOTE);
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
		}

		public function showMessagesView(source:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxyLocal.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxyLocal.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"showMessagesView");
			}

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

		public function playVideoMessage(source:String, netStreamLocation:String):void
		{
			if (source == CollaborationLobbyNetConnectionServiceProxy.LOCAL &&
					_collaborationLobbyNetConnectionServiceProxyLocal.collaborationState ==
							CollaborationModel.COLLABORATION_ACTIVE)
			{
				_collaborationLobbyNetConnectionServiceProxyLocal.sendCollaborationViewSynchronization(getQualifiedClassName(this),
						"playVideoMessage", netStreamLocation);
			}

			var messagesModelAndController:MessagesModelAndController = new MessagesModelAndController(_activeRecordAccount.messagesModel,
					this, _collaborationLobbyNetConnectionServiceProxy, netStreamLocation);
			_viewNavigator.pushView(PlayVideoMessageView, messagesModelAndController);
		}
	}
}
