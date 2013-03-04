package collaboRhythm.shared.model.medications.controller
{
	import collaboRhythm.shared.collaboration.model.SynchronizationService;
	import collaboRhythm.shared.model.ICollaborationLobbyNetConnectionServiceProxy;
	import collaboRhythm.shared.model.medications.TitrationDecisionModelBase;

	import spark.components.ViewNavigator;

	public class TitrationDecisionPanelControllerBase
	{
		protected var _viewNavigator:ViewNavigator;
		protected var _collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy;
		protected var _synchronizationService:SynchronizationService;

		public function TitrationDecisionPanelControllerBase(collaborationLobbyNetConnectionServiceProxy:ICollaborationLobbyNetConnectionServiceProxy,
															 viewNavigator:ViewNavigator)
		{
			_collaborationLobbyNetConnectionServiceProxy = collaborationLobbyNetConnectionServiceProxy;
			_viewNavigator = viewNavigator;
			_synchronizationService = new SynchronizationService(this, collaborationLobbyNetConnectionServiceProxy);
		}

		public function get modelBase():TitrationDecisionModelBase
		{
			return null;
		}

		public function setInstructionsScrollPosition(instructionsScrollPosition:Number):void
		{
			if (_synchronizationService.synchronize("setInstructionsScrollPosition",
					instructionsScrollPosition, false))
			{
				return;
			}

			modelBase.instructionsScrollPosition = instructionsScrollPosition;
		}

		public function destroy():void
		{
			if (_synchronizationService)
			{
				_synchronizationService.removeEventListener(this);
				_synchronizationService = null;
			}
		}

		public function showFaq():void
		{

		}

		public function send():void
		{

		}
	}
}
