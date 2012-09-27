package collaboRhythm.plugins.insulinTitrationSupport.controller
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationFAQModel;
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;

	public class InsulinTitrationFAQController
	{
		private var _insulinTitrationFAQModel:InsulinTitrationFAQModel;
		private var _synchronizationService:SynchronizationService;

		public function InsulinTitrationFAQController(insulinTitrationFAQModel:InsulinTitrationFAQModel,
													  collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy)
		{
			_insulinTitrationFAQModel = insulinTitrationFAQModel;

			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy);
		}

		public function setFaqRichEditableTextScrollPosition(verticalScrollPosition:Number):void
		{
			if (_synchronizationService.synchronize("setFaqRichEditableTextScrollPosition",
					verticalScrollPosition, false))
			{
				return;
			}

			_insulinTitrationFAQModel.setFaqRichEditableTextScrollPosition(verticalScrollPosition);
		}

		public function removeSynchronizationServiceEventListener():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
			}
		}
	}
}
